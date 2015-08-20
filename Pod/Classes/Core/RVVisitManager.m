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
#import "RVVisit.h"
#import "RVTouchpoint.h"
#import "RVCustomer.h"
#import "RVLocation.h"

#import "RVRegionManager.h"
#import "RVCircularRegionManager.h"

NSString *const kApplicationInactiveWhileTimerValid = @"ApplicationInactiveWhileTimerValid";

@interface RVVisitManager () <RVRegionManagerDelegate, RVCircularRegionManagerDelegate>

@property (strong, nonatomic) RVVisit *latestVisit;
@property (strong, nonatomic) NSTimer *expirationTimer;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation RVVisitManager

// TODO: when beacons are interacted with, exit time should be based on keepalive

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        
        _regionManager = [RVRegionManager new];
        _regionManager.delegate = self;
        
        _circularRegionManager = [[RVCircularRegionManager alloc] init];
        _circularRegionManager.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
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
                

                
                // TODO: if geofence triggered and location has not beed entered then enter location here cause
                // user interacted with a beacon
                
                if (self.latestVisit.isGeofenceTriggered && !self.latestVisit.locationEntered) {
                    //[self enterLocation];
                    
                    self.latestVisit.locationEntered = YES;
                    
                    // Delegate
                    if ([self.delegate respondsToSelector:@selector(visitManager:didEnterLocation:visit:)]) {
                        [self executeOnMainQueue:^{
                            [self.delegate visitManager:self didEnterLocation:self.latestVisit.location visit:self.latestVisit];
                        }];
                    }
                    
                    // Enter all wildcard touchpoints
                    if (![self.latestVisit.currentTouchpoints containsObject:self.latestVisit.wildcardTouchpoints.anyObject]) {
                        // Enter all wildcard touchpoints
                        [self.latestVisit.wildcardTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
                            [self.latestVisit addToCurrentTouchpoints:touchpoint];
                        }];
                        
                        // Delegate
                        if ([self.delegate respondsToSelector:@selector(visitManager:didEnterTouchpoints:visit:)]) {
                            [self executeOnMainQueue:^{
                                [self.delegate visitManager:self didEnterTouchpoints:self.latestVisit.wildcardTouchpoints.allObjects visit:self.latestVisit];
                            }];
                        }
                    }
                }
                
                // Touchpoint check
                NSSet *newTouchpointRegions = [regions filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CLBeaconRegion *beaconRegion, NSDictionary *bindings) {
                    return ![self.latestVisit isInTouchpointRegion:beaconRegion];
                }]];
                if (newTouchpointRegions.count > 0) {
                    [self movedToRegions:newTouchpointRegions];
                }
                
                [self invalidateExpirationTimer];
                
                if (_regionManager.monitoredRegions.count < 2) {
                    [self startMonitoringForVisit:self.latestVisit];
                }
                
                return;
            }
            
            if (_expirationTimer) {
                [self invalidateExpirationTimer];
                [self expireVisit];
            }
            
            //_expirationTimer = nil;
            
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
                
                // TODO: again consider this check
                
                if (!self.latestVisit.isGeofenceTriggered) {
                
                    [self.latestVisit.wildcardTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
                        [self.latestVisit removeFromCurrentTouchpoints:touchpoint];
                        [exitedTouchpoints addObject:touchpoint];
                    }];
                    
                    [self stopMonitoringForVisit];
                    [self startExpirationTimerWithInterval:self.latestVisit.keepAlive force:NO];
                
                }
            }
            
            // Delegate
            if (exitedTouchpoints.count > 0 && [self.delegate respondsToSelector:@selector(visitManager:didExitTouchpoints:visit:)]) {
                
                [self executeOnMainQueue:^{
                    [self.delegate visitManager:self didExitTouchpoints:exitedTouchpoints visit:self.latestVisit];
                }];
            }
            if (manager.currentRegions.count == 0 && !self.latestVisit.isGeofenceTriggered) {
                if ([self.delegate respondsToSelector:@selector(visitManager:didPotentiallyExitLocation:visit:)]) {
                    
                    [self executeOnMainQueue:^{
                        [self.delegate visitManager:self didPotentiallyExitLocation:self.latestVisit.location visit:self.latestVisit];
                    }];
                }
            }
            
            
        }
    }];
}

#pragma mark - RVCircularRegionManagerDelegate

- (void)circularRegionManager:(RVCircularRegionManager *)manager didEnterRegion:(CLCircularRegion *)region {
    [_operationQueue addOperationWithBlock:^{
        if (self.latestVisit && self.latestVisit.isAlive) {
            if ([self.latestVisit isInLocationWithIdentifier:region.identifier]) {
                return;
            }
            
            
            // Exit and expire the old visit
            
            // TODO: exit all touchpoints
            
            if ([self.delegate respondsToSelector:@selector(visitManager:didPotentiallyExitLocation:visit:)]) {
                [self executeOnMainQueue:^{
                    [self.delegate visitManager:self didPotentiallyExitLocation:self.latestVisit.location visit:self.latestVisit];
                }];
            }
            
            [self expireVisit];
        }
        
        [self createVisitWithCircularRegion:region];
    }];
}

- (void)circularRegionManager:(RVCircularRegionManager *)manager didExitRegion:(CLCircularRegion *)region {
    [_operationQueue addOperationWithBlock:^{
        
        // TOOD: if the location was never entered, should delete that visit so when the user opens
        // their app they dont enter that location/trigger the visit
        if (self.latestVisit && self.latestVisit.isAlive && [self.latestVisit isInLocationWithIdentifier:region.identifier] && self.latestVisit.locationEntered) {
            
            // TODO: exit all touchpoints
            
            NSArray *touchpointsExitedArray = self.latestVisit.currentTouchpoints.allObjects;
            
            for (RVTouchpoint *touchpoint in self.latestVisit.touchpoints) {
                [self.latestVisit removeFromCurrentTouchpoints:touchpoint];
            }
            
            // TODO: maybe need to do a check to see if this was already called,
            // CASE: beacon and geofence
            
            if ([self.delegate respondsToSelector:@selector(visitManager:didExitTouchpoints:visit:)]) {
                [self executeOnMainQueue:^{
                    [self.delegate visitManager:self didExitTouchpoints:touchpointsExitedArray visit:self.latestVisit];
                }];
            }
            
            // exit location
            
            if ([self.delegate respondsToSelector:@selector(visitManager:didPotentiallyExitLocation:visit:)]) {
                [self executeOnMainQueue:^{
                    [self.delegate visitManager:self didPotentiallyExitLocation:self.latestVisit.location visit:self.latestVisit];
                }];
            }
            
            [self stopMonitoringForVisit];
            
            // expire visit
            [self expireVisit];
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
        
        //[self enterLocation];
        
        self.latestVisit.locationEntered = YES;
        
        // Delegate
        if ([self.delegate respondsToSelector:@selector(visitManager:didEnterLocation:visit:)]) {
            [self executeOnMainQueue:^{
                [self.delegate visitManager:self didEnterLocation:newVisit.location visit:newVisit];
            }];
        }
        
        [self startMonitoringForVisit:self.latestVisit];
        
        [self movedToRegions:beaconRegions];
        
        [RVVisit setLatestVisit:newVisit];
    }
}

- (void)createVisitWithCircularRegion:(CLCircularRegion *)region {
    RVVisit *newVisit = [RVVisit new];
    newVisit.locationIdentifier = region.identifier;
    newVisit.customer = [RVCustomer cachedCustomer];
    newVisit.timestamp = [NSDate date];
    newVisit.isGeofenceTriggered = YES;
    
    BOOL shouldCreateVisit = YES;
    if ([self.delegate respondsToSelector:@selector(visitManager:shouldCreateVisit:)]) {
        shouldCreateVisit = [self.delegate visitManager:self shouldCreateVisit:newVisit];
    }
    
    if (shouldCreateVisit) {
        // Set UUID and Major after response
        newVisit.UUID = _regionManager.beaconUUIDs[0];
        newVisit.majorNumber = newVisit.location.majorNumber;
        
        self.latestVisit = newVisit;
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            //[self enterLocation];
            
            self.latestVisit.locationEntered = YES;
            
            // Delegate
            if ([self.delegate respondsToSelector:@selector(visitManager:didEnterLocation:visit:)]) {
                [self executeOnMainQueue:^{
                    [self.delegate visitManager:self didEnterLocation:self.latestVisit.location visit:self.latestVisit];
                }];
            }
            
            // Enter all wildcard touchpoints
            if (![self.latestVisit.currentTouchpoints containsObject:self.latestVisit.wildcardTouchpoints.anyObject]) {
                // Enter all wildcard touchpoints
                [self.latestVisit.wildcardTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
                    [self.latestVisit addToCurrentTouchpoints:touchpoint];
                }];
                
                // Delegate
                if ([self.delegate respondsToSelector:@selector(visitManager:didEnterTouchpoints:visit:)]) {
                    [self executeOnMainQueue:^{
                        [self.delegate visitManager:self didEnterTouchpoints:self.latestVisit.wildcardTouchpoints.allObjects visit:self.latestVisit];
                    }];
                }
            }
            
        }
    
        [self startMonitoringForVisit:self.latestVisit];
        
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
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [self executeOnMainQueue:^{
            _expirationTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(expireVisit) userInfo:nil repeats:NO];
        }];
    }
}

- (void)invalidateExpirationTimer {
    [_expirationTimer invalidate];
    _expirationTimer = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kApplicationInactiveWhileTimerValid];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)expireVisit {
    [self stopMonitoringForVisit];
    
    if ([self.delegate respondsToSelector:@selector(visitManager:didExpireVisit:)]) {
        [self executeOnMainQueue:^{
            [self.delegate visitManager:self didExpireVisit:self.latestVisit];
        }];
    }
    //_expirationTimer = nil;
    [self invalidateExpirationTimer];
}

- (void)startMonitoringForVisit:(RVVisit *)visit {
    // Stop monitoring for all geofences except for the fence for current location
    // So that exiting the fence is still monitored by the os.
    
    [_circularRegionManager stopMonitoring];
    
    [_regionManager stopMonitoringForAllSpecificRegions];
    
    
    [_circularRegionManager startMonitoringForRegion:visit.location.circularRegion];
    
    // Monitor for all known touchpoint specific beacons so app can wake up when
    // device comes in range during visit
    
    [_regionManager startMonitoringForRegions:self.latestVisit.observableRegions];
}

- (void)stopMonitoringForVisit {
    [_regionManager stopMonitoringForAllSpecificRegions];
    [_circularRegionManager stopMonitoring];
    [_circularRegionManager startMonitoring];
}

#pragma mark - UIApplicationStateNotifications

- (void)applicationDidEnterBackground:(NSNotification *)note {
    if (_expirationTimer) {
        // cancel timer
        [self invalidateExpirationTimer];
        // store the last beacon detection timestamp
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kApplicationInactiveWhileTimerValid];
        [[NSUserDefaults standardUserDefaults] synchronize];

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
    // TODO: CLEAN ALL OF THIS UP
    // Geofence triggered visits
    if (self.latestVisit && self.latestVisit.isGeofenceTriggered && !self.latestVisit.locationEntered /* && still in the fence */) {
        return;
    }
    
    // Bring back another keep alive timer and account for the time spent suspended
    
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

- (void)applicationDidBecomeActive:(NSNotification *)note {
    // Geofence triggered visits
    if (self.latestVisit && self.latestVisit.isGeofenceTriggered && !self.latestVisit.locationEntered /* && still in the fence */) {
        self.latestVisit.locationEntered = YES;
        
        // Delegate
        if ([self.delegate respondsToSelector:@selector(visitManager:didEnterLocation:visit:)]) {
            [self.delegate visitManager:self didEnterLocation:self.latestVisit.location visit:self.latestVisit];
        }
        
        
        // Enter all wildcard touchpoints
        if (![self.latestVisit.currentTouchpoints containsObject:self.latestVisit.wildcardTouchpoints.anyObject]) {
            // Enter all wildcard touchpoints
            [self.latestVisit.wildcardTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
                [self.latestVisit addToCurrentTouchpoints:touchpoint];
            }];
            
            // Delegate
            if ([self.delegate respondsToSelector:@selector(visitManager:didEnterTouchpoints:visit:)]) {
                [self.delegate visitManager:self didEnterTouchpoints:self.latestVisit.wildcardTouchpoints.allObjects visit:self.latestVisit];
            }
        }
        
        [RVVisit setLatestVisit:self.latestVisit];
    }
}

@end