//
//  RVVisitManager.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-29.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVVisitManager.h"

#import "RVCard.h"
#import "RVCustomer.h"
#import "RVLog.h"
#import "RVRegionManager.h"
#import "RVVisit.h"
#import "RVTouchpoint.h"
#import "RVCustomer.h"

NSString *const kApplicationInactiveWhileTimerValid = @"ApplicationInactiveWhileTimerValid";

@interface RVVisitManager () <RVRegionManagerDelegate>

@property (strong, nonatomic) RVVisit *latestVisit;
@property (strong, nonatomic) NSTimer *expirationTimer;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation RVVisitManager

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        
        _regionManager = [RVRegionManager new];
        _regionManager.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return  self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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


#pragma mark - RVRegionManagerDelegate

- (NSPredicate *)predicateForDistinctMajorNumbers {
    __block NSMutableSet *set = [NSMutableSet set];
    return [NSPredicate predicateWithBlock:^BOOL(CLBeaconRegion *beaconRegion, NSDictionary *bindings) {
        BOOL contained = [set containsObject:beaconRegion.major];
        if (!contained) {
            [set addObject:beaconRegion.major];
        }
        return !contained;
    }];
}

- (void)regionManager:(RVRegionManager *)manager didEnterRegions:(NSSet *)regions {
    NSSet *majorDistinctRegions = [manager.currentRegions filteredSetUsingPredicate:[self predicateForDistinctMajorNumbers]];
    if (majorDistinctRegions.count > 1) {
        NSLog(@"ROVER - ERROR: Rover has stopped because it has detected beacons with different major numbers (locations). Ensure that your beacons at this location have the same major number.");
    } else {
        CLBeaconRegion *aRegion = regions.anyObject;
        [_operationQueue addOperationWithBlock:^{
            if (self.latestVisit && [self.latestVisit isInLocationRegion:aRegion] && (self.latestVisit.currentTouchpoints.count > 0 || self.latestVisit.isAlive)) {
                
                // Touchpoint check
                NSSet *newTouchpointRegions = [regions filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CLBeaconRegion *beaconRegion, NSDictionary *bindings) {
                    return ![self.latestVisit isInTouchpointRegion:beaconRegion];
                }]];
                if (newTouchpointRegions.count > 0) {
                    [self movedToRegions:newTouchpointRegions];
                }
                
                [_expirationTimer invalidate];
                
                return;
            }
            
            if (_expirationTimer) {
                [_expirationTimer invalidate];
                [self expireVisit];
            }
            
            _expirationTimer = nil;
            
            [self createVisitWithBeaconRegions:regions];
        }];
    }
}

- (void)regionManager:(RVRegionManager *)manager didExitRegions:(NSSet *)regions {
    CLBeaconRegion *aBeaconRegion = regions.anyObject;
    
    [_operationQueue addOperationWithBlock:^{
        if (self.latestVisit && [self.latestVisit isInLocationRegion:aBeaconRegion]) {
            NSMutableArray *exitedTouchpoints = [NSMutableArray array];
            
            [regions enumerateObjectsUsingBlock:^(CLBeaconRegion *beaconRegion, BOOL *stop) {
                RVTouchpoint *touchpoint = [self.latestVisit touchpointForRegion:beaconRegion];
                if (touchpoint) {
                    [self.latestVisit removeFromCurrentTouchpoints:touchpoint];
                    [exitedTouchpoints addObject:touchpoint];
                }
            }];
            
            if (manager.currentRegions.count == 0) {
                // Reset the keepAlive timer
                self.latestVisit.beaconLastDetectedAt = [NSDate date];
                [RVVisit setLatestVisit:self.latestVisit];
                
                // Exit all wildcard touchpoints
                [self.latestVisit.wildcardTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
                    [self.latestVisit removeFromCurrentTouchpoints:touchpoint];
                    [exitedTouchpoints addObject:touchpoint];
                }];
                
                //[self performSelectorOnMainThread:@selector(startExpirationTimerWithInterval:) withObject:[NSNumber numberWithDouble:self.latestVisit.keepAlive] waitUntilDone:NO];
                [self startExpirationTimerWithInterval:self.latestVisit.keepAlive force:NO];
            }
            
            // Delegate
            if (exitedTouchpoints.count > 0 && [self.delegate respondsToSelector:@selector(visitManager:didExitTouchpoints:visit:)]) {
                
                [self executeOnMainQueue:^{
                    [self.delegate visitManager:self didExitTouchpoints:exitedTouchpoints visit:self.latestVisit];
                }];
            }
            if (manager.currentRegions.count == 0) {
                if ([self.delegate respondsToSelector:@selector(visitManager:didPotentiallyExitLocation:visit:)]) {
                    
                    [self executeOnMainQueue:^{
                        [self.delegate visitManager:self didPotentiallyExitLocation:self.latestVisit.location visit:self.latestVisit];
                    }];
                }
            }
            
            
        }
    }];
}

#pragma mark - Visit Creation

- (void)createVisitWithBeaconRegions:(NSSet *)beaconRegions {
    CLBeaconRegion *beaconRegion = beaconRegions.anyObject;
    
    RVVisit *newVisit = [RVVisit new];
    newVisit.UUID = beaconRegion.proximityUUID;
    newVisit.majorNumber = beaconRegion.major;
    newVisit.customer = [RVCustomer cachedCustomer];
    newVisit.timestamp = [NSDate date];
    
    BOOL shouldCreateVisit = YES;
    if ([self.delegate respondsToSelector:@selector(visitManager:shouldCreateVisit:)]) {
        shouldCreateVisit = [self.delegate visitManager:self shouldCreateVisit:newVisit];
    }
    
    if (shouldCreateVisit) {
        self.latestVisit = newVisit;
        
        NSLog(@"Touchpoints: %@", newVisit.touchpoints);
        
        // Delegate
        if ([self.delegate respondsToSelector:@selector(visitManager:didEnterLocation:visit:)]) {
            [self executeOnMainQueue:^{
                [self.delegate visitManager:self didEnterLocation:newVisit.location visit:newVisit];
            }];
        }
        
        // Start Monitoring
        [_regionManager stopMonitoringForAllSpecificRegions];
        [_regionManager startMonitoringForRegions:self.latestVisit.observableRegions];
        
        [self movedToRegions:beaconRegions];
        
        [RVVisit setLatestVisit:newVisit];
    }
}

#pragma mark - Helper Methods

- (void)executeOnMainQueue:(void(^)())block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void)movedToRegions:(NSSet *)beaconRegions {
    NSMutableArray *enteredTouchpoints = [NSMutableArray array];
    
    if (![self.latestVisit.currentTouchpoints containsObject:self.latestVisit.wildcardTouchpoints.anyObject]) {
        // Enter all wildcard touchpoints
        [self.latestVisit.wildcardTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
            [self.latestVisit addToCurrentTouchpoints:touchpoint];
            [enteredTouchpoints addObject:touchpoint];
        }];
    }
    
    [beaconRegions enumerateObjectsUsingBlock:^(CLBeaconRegion *beaconRegion, BOOL *stop) {
        RVTouchpoint *touchpoint = [self.latestVisit touchpointForRegion:beaconRegion];
        if (touchpoint) {
            
            // TODO: do we need to do a currentTouchpoints.contains check? in case of missfires
            
            [self.latestVisit addToCurrentTouchpoints:touchpoint];
            [enteredTouchpoints addObject:touchpoint];
            
        } else {
            NSLog(@"ROVER: Invalid touchpoint (minorNumber: %@)", beaconRegion.minor);
        }
    }];
    
    // Delegate
    if (enteredTouchpoints.count > 0 && [self.delegate respondsToSelector:@selector(visitManager:didEnterTouchpoints:visit:)]) {
        
        [self executeOnMainQueue:^{
            [self.delegate visitManager:self didEnterTouchpoints:enteredTouchpoints visit:self.latestVisit];
        }];
    }
}

- (void)startExpirationTimerWithInterval:(NSTimeInterval)timeInterval force:(BOOL)force {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground && !force) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kApplicationInactiveWhileTimerValid];
    } else {
        [self executeOnMainQueue:^{
            _expirationTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(expireVisit) userInfo:nil repeats:NO];
        }];
    }
}

- (void)invalidateExpirationTimer {
    [_expirationTimer invalidate];
    _expirationTimer = nil;
}

- (void)expireVisit {
    if ([self.delegate respondsToSelector:@selector(visitManager:didExpireVisit:)]) {
        [self executeOnMainQueue:^{
            [self.delegate visitManager:self didExpireVisit:self.latestVisit];
        }];
    }
    _expirationTimer = nil;
}

#pragma mark - UIApplicationStateNotifications

- (void)applicationDidEnterBackground:(NSNotification *)note {
    if (_expirationTimer) {
        // store the last beacon detection timestamp
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kApplicationInactiveWhileTimerValid];
        // cancel timer
        [self invalidateExpirationTimer];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kApplicationInactiveWhileTimerValid];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)note {
    [self applicationDidOpen];
}

- (void)applicationWillEnterForeground:(NSNotification *)note {
    [self applicationDidOpen];
}

- (void)applicationDidOpen {
    BOOL applicationExitedWhileTimerValid = [[[NSUserDefaults standardUserDefaults] objectForKey:kApplicationInactiveWhileTimerValid] boolValue];
    
    if (applicationExitedWhileTimerValid && self.latestVisit) {
        // read the last beacon detection date
        NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:self.latestVisit.beaconLastDetectedAt];
        NSTimeInterval remainingTime = MAX(2, self.latestVisit.keepAlive - elapsedTime);
        // start the timer back up
        // TOOD: consider what can happen if the visit is long gone, app terminated/or not, and the user comes back
        //       with 0 time remaining and expireVisit is called immedietely 

        [self startExpirationTimerWithInterval:remainingTime force:YES];
    }
}

@end