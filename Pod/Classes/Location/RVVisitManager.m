//
//  RVVisitManager.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-29.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "Rover.h"
#import "RVVisitManager.h"

#import "RVCardProject.h"
#import "RVCustomerProject.h"
#import "RVLog.h"
#import "RVNetworkingManager.h"
#import "RVNotificationCenter.h"
#import "RVRegionManager.h"
#import "RVVisit.h"
#import "RVTouchpoint.h"
#import "RVCustomer.h"

NSString *const kRVVisitManagerDidEnterTouchpointNotification = @"RVVisitManagerDidEnterTouchpointNotification";
NSString *const kRVVisitManagerDidExitTouchpointNotification = @"RVVisitManagerDidExitTouchpointNotification";
NSString *const kRVVisitManagerDidEnterLocationNotification = @"RVVisitManagerDidEnterLocationNotification";
NSString *const kRVVisitManagerDidExitLocationNotification = @"RVVisitManagerDidExitLocationNotification";

NSString *const kRVVisitManagerLatestVisitPersistenceKey = @"_roverLatestVisit";

@interface RVVisitManager ()

@property (strong, nonatomic) RVVisit *latestVisit;
@property (strong, nonatomic) NSTimer *expirationTimer;

@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation RVVisitManager

#pragma mark - Class Methods

+ (id)sharedManager {
    static RVVisitManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        
        [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(regionManagerDidEnterRegion:) name:kRVRegionManagerDidEnterRegionNotification object:nil];
        
        [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(regionManagerDidExitRegion:) name:kRVRegionManagerDidExitRegionNotification object:nil];
    }
    return  self;
}

- (void)dealloc {
    [[RVNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Instance methods

- (RVVisit *)latestVisit
{
    if (_latestVisit) {
        return _latestVisit;
    }
    
    // TODO: need to do versioning for this! Users may have an old visit object from an older SDK
    
    NSUserDefaults *standardDefault = [NSUserDefaults standardUserDefaults];
    _latestVisit = [NSKeyedUnarchiver unarchiveObjectWithData:[standardDefault objectForKey:kRVVisitManagerLatestVisitPersistenceKey]];
    return _latestVisit;
}


#pragma mark - Region Manager Notifications

- (void)regionManagerDidEnterRegion:(NSNotification *)note {
    CLBeaconRegion *beaconRegion = [note.userInfo objectForKey:@"beaconRegion"];
    
    [_operationQueue addOperationWithBlock:^{
        if (self.latestVisit && [self.latestVisit isInLocationRegion:beaconRegion] && self.latestVisit.isAlive) {
            
            // Touchpoint check
            if (![self.latestVisit isInTouchpointRegion:beaconRegion]) {
                [self performSelectorOnMainThread:@selector(movedToRegion:) withObject:beaconRegion waitUntilDone:YES];
            }
            
            NSDate *now = [NSDate date];
            NSTimeInterval elapsed = [now timeIntervalSinceDate:self.latestVisit.timestamp];
            
            [_expirationTimer invalidate];
            
            
            RVLog(kRoverAlreadyVisitingNotification, @{ @"elapsed": [NSNumber numberWithDouble:elapsed],
                                                        @"keepAlive": [NSNumber numberWithDouble:self.latestVisit.keepAlive] });
            return;
        }
        
        _expirationTimer = nil;
        
        // Need a synchronous call so that the queue behaves like a queue
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [self createVisitWithBeaconRegion:beaconRegion completionBlock:^{
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];

}

- (void)regionManagerDidExitRegion:(NSNotification *)note {
    CLBeaconRegion *beaconRegion = [note.userInfo objectForKey:@"beaconRegion"];
    NSSet *regions = [note.userInfo objectForKey:@"allRegions"];
    
    [_operationQueue addOperationWithBlock:^{
        if (self.latestVisit && [self.latestVisit isInLocationRegion:beaconRegion]) {
            
            RVTouchpoint *touchpoint = [self.latestVisit touchpointForRegion:beaconRegion];
            if (touchpoint) {
                [self.latestVisit removeFromCurrentTouchpoints:touchpoint];
                
                [[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidExitTouchpointNotification object:self
                                                                  userInfo:@{ @"touchpoint": touchpoint,
                                                                              @"visit": self.latestVisit}];
                NSLog(@"EXITING TOUCHPOINT: %@", touchpoint);
            }
            
            if (regions.count == 0) {
                // Reset the keep-alive timer
                // TODO: Should this happen everytime?
                // TODO: may actually have to persist at any change
                self.latestVisit.beaconLastDetectedAt = [NSDate date];
                [self.latestVisit persistToDefaults];
                
                
                [self exitAllWildcardTouchpoints];
                
                NSLog(@"EXITING LOCATION");
                
                // Reset region monitoring
                //        RVRegionManager *regionManager = [RVRegionManager sharedManager];
                //        [regionManager setBeaconUUIDs:[Rover shared].config.beaconUUIDs];
                //        [regionManager startMonitoring];
                
                
                [self updateVisitExitTime];
                //[self startExpirationTimer];
            }
            
        }
    }];

}

#pragma mark - Networking

- (void)createVisitWithBeaconRegion:(CLBeaconRegion *)beaconRegion completionBlock:(void (^)())completionBlock {
    RVLog(kRoverWillPostVisitNotification, nil);
    
    self.latestVisit = [RVVisit new];
    self.latestVisit.UUID = beaconRegion.proximityUUID;
    self.latestVisit.majorNumber = beaconRegion.major;
    self.latestVisit.customer = [Rover shared].customer;
    self.latestVisit.customer.name = @"The Phantom";
    self.latestVisit.customer.email = nil;
    self.latestVisit.timestamp = [NSDate date];
    
    [self.latestVisit save:^{
        RVLog(kRoverDidPostVisitNotification, nil);
        // TODO: should make sure this happens on the main thread
        [[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidEnterLocationNotification object:self userInfo:@{ @"visit": self.latestVisit }];
        NSLog(@"touchpoints: %@", self.latestVisit.touchpoints); //DELETE
        
        
        // START MONITORING
        RVRegionManager *regionManager = [RVRegionManager sharedManager];
        [regionManager setBeaconRegions:self.latestVisit.observableRegions];
        [regionManager startMonitoring];
        

        
        [self movedToRegion:beaconRegion];
        
        if (completionBlock) {
            completionBlock();
        }
    } failure:^(NSString *reason) {
        RVLog(kRoverPostVisitFailedNotification, nil);
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)updateVisitExitTime {
    if (!self.latestVisit) return;
    
    RVLog(kRoverWillUpdateExitTimeNotification, nil);
    
    
    // TOOD: move this stuff out to the Rover class
    [self.latestVisit trackEvent:@"location.exit" params:nil];
    
//    //self.latestVisit.exitedAt = [NSDate date];
//    [self.latestVisit save:^{
//        RVLog(kRoverDidUpdateExitTimeNotification, nil);
//    } failure:^(NSString *reason) {
//        RVLog(kRoverUpdateExitTimeFailedNotification, nil);
//    }];
}

// TODO: consider if this should happen in the succes block ^

#pragma mark - Helper Methods

- (void)movedToRegion:(CLBeaconRegion *)beaconRegion {
    if (![self.latestVisit.currentTouchpoints containsObject:self.latestVisit.wildcardTouchpoints.anyObject]) {
        // Enter all wildcard touchpoints
        [self.latestVisit.wildcardTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
            NSLog(@"ENTERING WILDCARD TOUCHPOINT: %@", touchpoint);
            [self.latestVisit addToCurrentTouchpoints:touchpoint];
            [[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidEnterTouchpointNotification object:self userInfo:@{ @"touchpoint": touchpoint,
                                                                                                                                             @"visit": self.latestVisit}];
        }];
    }
    
    RVTouchpoint *touchpoint = [self.latestVisit touchpointForRegion:beaconRegion];
    if (touchpoint) {
        
        NSLog(@"Entered touchpoint: %@", touchpoint);
        
//        if (![self.latestVisit.visitedTouchpoints containsObject:touchpoint]) {
//            [self.latestVisit addToCurrentTouchpoints:touchpoint];
//            [[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidEnterTouchpointNotification object:self
//                                                              userInfo:@{ @"touchpoint": touchpoint,
//                                                                          @"visit": self.latestVisit}];
//            return;
//        }
        
        [self.latestVisit addToCurrentTouchpoints:touchpoint];
        [[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidEnterTouchpointNotification object:self
                                                          userInfo:@{ @"touchpoint": touchpoint,
                                                                      @"visit": self.latestVisit}];
        
        
    } else { // dont need the else and move this guy up
        NSLog(@"Invalid touchpoint: %@", beaconRegion.minor);
    }
}

- (void)exitAllWildcardTouchpoints {
    [self.latestVisit.wildcardTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
        [self.latestVisit removeFromCurrentTouchpoints:touchpoint];
        [[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidExitTouchpointNotification object:self userInfo:@{ @"touchpoint": touchpoint,
                                                                                                                                        @"visit": self.latestVisit }];
    }];
}

- (void)startExpirationTimer {
    _expirationTimer = [NSTimer scheduledTimerWithTimeInterval:self.latestVisit.keepAlive target:self selector:@selector(expireVisit) userInfo:nil repeats:NO];
}

- (void)expireVisit {
    [[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidExitLocationNotification object:self userInfo:@{@"visit": self.latestVisit}];
}

@end