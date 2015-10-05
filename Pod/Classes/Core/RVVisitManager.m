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
#import "RVRegionManager.h"
#import "RVVisit.h"
#import "RVTouchpoint.h"
#import "RVBeaconRegion.h"
#import "RVCustomer.h"

NSString *const kApplicationInactiveWhileTimerValid = @"ApplicationInactiveWhileTimerValid";

@interface RVVisitManager () <RVRegionManagerDelegate>

@property (strong, nonatomic) RVVisit *latestVisit;
@property (strong, nonatomic) NSTimer *expirationTimer;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation NSSet (Contains)
- (BOOL)containsAnyOfObjects:(NSArray *)objects {
    for (id obj in objects) {
        if ([self containsObject:obj]) {
            return YES;
        }
    }
    return NO;
}
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

- (void)regionManager:(RVRegionManager *)manager didEnterRegion:(CLBeaconRegion *)region {
    [_operationQueue addOperationWithBlock:^{
        if (self.latestVisit && [self.latestVisit respondsToRegion:region] && (self.latestVisit.currentTouchpoints.count > 0 || self.latestVisit.isAlive)) {
            NSArray *touchpoints = [self.latestVisit touchpointsForRegion:region];
            NSArray *newTouchpoints = [touchpoints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVTouchpoint *touchpoint, NSDictionary<NSString *,id> * _Nullable bindings) {
                return ![self.latestVisit.currentTouchpoints containsObject:touchpoint];
            }]];
            
            [self movedToTouchpoints:newTouchpoints];
            
            [RVVisit setLatestVisit:self.latestVisit];
                
            return;
            
        }
        
        RVVisit *newVisit = [self visitWithBeaconRegion:region];
        if (newVisit) {
            if (_expirationTimer) {
                [self invalidateExpirationTimer];
                [self expireVisit];
            }
            
            self.latestVisit = newVisit;
            
            NSArray *touchpoints = [newVisit touchpointsForRegion:region];
            [self movedToTouchpoints:touchpoints];
            
            [RVVisit setLatestVisit:newVisit];
            
            // TODO: move this logic somewhere else
            // Start Monitoring
            [_regionManager stopMonitoringForAllSpecificRegions];
            [_regionManager startMonitoringForRegions:self.latestVisit.observableRegions.array];
        }
    }];
}

- (void)regionManager:(RVRegionManager *)manager didExitRegion:(CLBeaconRegion *)region {
    NSSet *currentRegions = [manager.currentRegions copy];
    // TODO: maybe need to copy the region too
    
    [_operationQueue addOperationWithBlock:^{
        if (self.latestVisit && [self.latestVisit respondsToRegion:region]) {
            NSArray *touchpoints = [self.latestVisit touchpointsForRegion:region];
            for (RVTouchpoint *touchpoint in touchpoints) {
                if (![currentRegions containsAnyOfObjects:touchpoint.beaconRegions]) {
                    
                    [self.latestVisit removeFromCurrentTouchpoints:touchpoint];
                    
                    // Delegate
                    if ([self.delegate respondsToSelector:@selector(visitManager:didExitTouchpoints:visit:)]) {
                        [self executeOnMainQueue:^{
                            // TODO: single touchpoint at a time
                            [self.delegate visitManager:self didExitTouchpoints:@[touchpoint] visit:self.latestVisit];
                        }];
                    }
                    
                }
            }
            
            if (self.latestVisit.currentTouchpoints.count == 0) {
                // Reset the keepAlive timer
                self.latestVisit.beaconLastDetectedAt = [NSDate date];
                [RVVisit setLatestVisit:self.latestVisit];
                
                [self startExpirationTimerWithInterval:self.latestVisit.keepAlive force:NO];
                
                // Delegate
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

- (RVVisit *)visitWithBeaconRegion:(CLBeaconRegion *)region {
    RVVisit *newVisit = [RVVisit new];
    newVisit.beaconRegion = [RVBeaconRegion beaconRegionWithCLBeaconRegion:region];
    newVisit.customer = [RVCustomer cachedCustomer];
    newVisit.timestamp = [NSDate date];
    
    BOOL shouldCreateVisit = YES;
    if ([self.delegate respondsToSelector:@selector(visitManager:shouldCreateVisit:)]) {
        shouldCreateVisit = [self.delegate visitManager:self shouldCreateVisit:newVisit];
    }
    
    if (shouldCreateVisit) {
        return newVisit;
    }
    
    return nil;
}

#pragma mark - Helper Methods

- (void)executeOnMainQueue:(void(^)())block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void)movedToTouchpoints:(NSArray *)touchpoints {
    for (RVTouchpoint *touchpoint in touchpoints) {
        if (!self.latestVisit.locationEntered) {
            self.latestVisit.locationEntered = YES;
            
            // Delegate
            if ([self.delegate respondsToSelector:@selector(visitManager:didEnterLocation:visit:)]) {
                [self executeOnMainQueue:^{
                    [self.delegate visitManager:self didEnterLocation:self.latestVisit.location visit:self.latestVisit];
                }];
            }
        }
        
        [self.latestVisit addToCurrentTouchpoints:touchpoint];
        
        // Delegate
        if ([self.delegate respondsToSelector:@selector(visitManager:didEnterTouchpoints:visit:)]) {
            [self executeOnMainQueue:^{
                [self.delegate visitManager:self didEnterTouchpoints:@[touchpoint] visit:self.latestVisit];
            }];
        }
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
    if ([self.delegate respondsToSelector:@selector(visitManager:didExpireVisit:)]) {
        [self executeOnMainQueue:^{
            [self.delegate visitManager:self didExpireVisit:self.latestVisit];
        }];
    }
    //_expirationTimer = nil;
    [self invalidateExpirationTimer];
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