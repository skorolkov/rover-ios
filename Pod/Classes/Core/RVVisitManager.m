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
#import "RVNotificationCenter.h"
#import "RVRegionManager.h"
#import "RVVisit.h"
#import "RVTouchpoint.h"
#import "RVCustomer.h"

NSString *const kRVVisitManagerDidEnterTouchpointNotification = @"RVVisitManagerDidEnterTouchpointNotification";
NSString *const kRVVisitManagerDidExitTouchpointNotification = @"RVVisitManagerDidExitTouchpointNotification";
NSString *const kRVVisitManagerDidEnterLocationNotification = @"RVVisitManagerDidEnterLocationNotification";
NSString *const kRVVisitManagerDidPotentiallyExitLocationNotification = @"RVVisitManagerDidPotentiallyExitLocationNotification";
NSString *const kRVVisitManagerDidExpireVisitNotification = @"RVVisitManagerDidExpireVisitNotification";

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
    
    _latestVisit = [RVVisit latestVisit];
    return _latestVisit;
}


#pragma mark - Region Manager Notifications

- (void)regionManagerDidEnterRegion:(NSNotification *)note {
    CLBeaconRegion *beaconRegion = [note.userInfo objectForKey:@"beaconRegion"];
    
    [_operationQueue addOperationWithBlock:^{
        if (self.latestVisit && [self.latestVisit isInLocationRegion:beaconRegion] && (self.latestVisit.currentTouchpoints.count > 0 || self.latestVisit.isAlive)) {
            
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
        
        [self createVisitWithBeaconRegion:beaconRegion];
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
                
                [self postNotificationName:kRVVisitManagerDidExitTouchpointNotification userInfo:@{ @"touchpoint": touchpoint, @"visit": self.latestVisit}];

            }
            
            if (regions.count == 0) {
                // Reset the keep-alive timer
                // TODO: Should this happen everytime?
                // TODO: may actually have to persist at any change
                self.latestVisit.beaconLastDetectedAt = [NSDate date];
                [RVVisit setLatestVisit:self.latestVisit];
                
                
                [self exitAllWildcardTouchpoints];
                
                
                [self postNotificationName:kRVVisitManagerDidPotentiallyExitLocationNotification userInfo:@{ @"visit": self.latestVisit }];
                
                [self startExpirationTimer];
            }
            
        }
    }];

}

#pragma mark - Networking

- (void)createVisitWithBeaconRegion:(CLBeaconRegion *)beaconRegion {
    
    RVVisit *newVisit = [RVVisit new];
    newVisit.UUID = beaconRegion.proximityUUID;
    newVisit.majorNumber = beaconRegion.major;
    newVisit.customer = [Rover shared].customer;
    newVisit.simulate = [[[Rover shared] configValueForKey:@"sandboxMode"] boolValue];
    newVisit.timestamp = [NSDate date];
    newVisit.valid = YES; // New visit is valid by default

    RVLog(kRoverWillPostVisitNotification, nil);
    
    [newVisit postNewVisitCreatedNotification];
    
    if (newVisit.valid) {

        RVLog(kRoverDidPostVisitNotification, nil);
        self.latestVisit = newVisit;
        
        NSLog(@"touchpoint: %@", newVisit.touchpoints);
        
        [self postNotificationName:kRVVisitManagerDidEnterLocationNotification userInfo:@{ @"visit": self.latestVisit }];
        
        // START MONITORING
        RVRegionManager *regionManager = [RVRegionManager sharedManager];
        [regionManager stopMonitoringForAllSpecificRegions];
        [regionManager startMonitoringForRegions:self.latestVisit.observableRegions];
        
        
        [self movedToRegion:beaconRegion];
        
        [RVVisit setLatestVisit:newVisit];
        
    } else {
        RVLog(kRoverPostVisitFailedNotification, nil);
    }
}

#pragma mark - Helper Methods

- (void)postNotificationName:(NSString *)notificationName userInfo:(NSDictionary *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RVNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
    });
}

// NOTE: this method should always be called from the main thread

- (void)movedToRegion:(CLBeaconRegion *)beaconRegion {
    if (![self.latestVisit.currentTouchpoints containsObject:self.latestVisit.wildcardTouchpoints.anyObject]) {
        // Enter all wildcard touchpoints
        [self.latestVisit.wildcardTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
            [self.latestVisit addToCurrentTouchpoints:touchpoint];
            //[[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidEnterTouchpointNotification object:self userInfo:@{ @"touchpoint": touchpoint,
            //                                                                                                                                 @"visit": self.latestVisit}];
            [self postNotificationName:kRVVisitManagerDidEnterTouchpointNotification userInfo:@{ @"touchpoint": touchpoint,
                                                                                                @"visit": self.latestVisit}];
        }];
    }
    
    RVTouchpoint *touchpoint = [self.latestVisit touchpointForRegion:beaconRegion];
    if (touchpoint) {
        
        // TODO: do we need to do a currentTouchpoints.contains check? in case of missfires
        
        [self.latestVisit addToCurrentTouchpoints:touchpoint];
        [self postNotificationName:kRVVisitManagerDidEnterTouchpointNotification userInfo:@{ @"touchpoint": touchpoint,
                                                                                             @"visit": self.latestVisit}];
        //[[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidEnterTouchpointNotification object:self
        //                                                  userInfo:@{ @"touchpoint": touchpoint,
        //                                                              @"visit": self.latestVisit}];
        
        
    } else {
        NSLog(@"Invalid touchpoint: %@", beaconRegion.minor);
    }
}

- (void)exitAllWildcardTouchpoints {
    [self.latestVisit.wildcardTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
        [self.latestVisit removeFromCurrentTouchpoints:touchpoint];

        [self postNotificationName:kRVVisitManagerDidExitTouchpointNotification userInfo:@{ @"touchpoint": touchpoint,
                                                                                            @"visit": self.latestVisit }];
    }];
}

- (void)startExpirationTimer {
    _expirationTimer = [NSTimer scheduledTimerWithTimeInterval:self.latestVisit.keepAlive target:self selector:@selector(expireVisit) userInfo:nil repeats:NO];
}

- (void)expireVisit {
    [self postNotificationName:kRVVisitManagerDidExpireVisitNotification userInfo:@{@"visit": self.latestVisit}];
}

@end