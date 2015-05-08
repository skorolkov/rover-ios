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
    }
    return  self;
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

- (void)regionManager:(RVRegionManager *)manager didEnterRegion:(CLRegion *)region totalRegions:(NSSet *)regions {
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    
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

- (void)regionManager:(RVRegionManager *)manager didExitRegion:(CLRegion *)region totalRegions:(NSSet *)regions {
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    
    [_operationQueue addOperationWithBlock:^{
        if (self.latestVisit && [self.latestVisit isInLocationRegion:beaconRegion]) {
            
            RVTouchpoint *touchpoint = [self.latestVisit touchpointForRegion:beaconRegion];
            if (touchpoint) {
                [self.latestVisit removeFromCurrentTouchpoints:touchpoint];
                
                // Delegate
                if ([self.delegate respondsToSelector:@selector(visitManager:didExitTouchpoint:visit:)]) {
//                    dispatch_sync(dispatch_get_main_queue(), ^{
//                        [self.delegate visitManager:self didExitTouchpoint:touchpoint visit:self.latestVisit];
//                    });
                    [self executeOnMainQueue:^{
                        [self.delegate visitManager:self didExitTouchpoint:touchpoint visit:self.latestVisit];
                    }];
                }
                
            }
            
            if (regions.count == 0) {
                // Reset the keep-alive timer
                // TODO: Should this happen everytime?
                // TODO: may actually have to persist at any change
                self.latestVisit.beaconLastDetectedAt = [NSDate date];
                [RVVisit setLatestVisit:self.latestVisit];
                
                
                [self exitAllWildcardTouchpoints];
                
                // Delegate
                if ([self.delegate respondsToSelector:@selector(visitManager:didPotentiallyExitLocation:visit:)]) {
//                    dispatch_sync(dispatch_get_main_queue(), ^{
//                        [self.delegate visitManager:self didPotentiallyExitLocation:self.latestVisit.location visit:self.latestVisit];
//                    });
                    [self executeOnMainQueue:^{
                        [self.delegate visitManager:self didPotentiallyExitLocation:self.latestVisit.location visit:self.latestVisit];
                    }];
                }
                
                [self performSelectorOnMainThread:@selector(startExpirationTimer) withObject:nil waitUntilDone:NO];
            }
            
        }
    }];
}

#pragma mark - Networking

- (void)createVisitWithBeaconRegion:(CLBeaconRegion *)beaconRegion {
    
    RVVisit *newVisit = [RVVisit new];
    newVisit.UUID = beaconRegion.proximityUUID;
    newVisit.majorNumber = beaconRegion.major;
    newVisit.customer = [RVCustomer cachedCustomer]; //[Rover shared].customer;
    //newVisit.simulate = [[[Rover shared] configValueForKey:@"sandboxMode"] boolValue];
    newVisit.timestamp = [NSDate date];
    
    BOOL shouldCreateVisit;
    
    if ([self.delegate respondsToSelector:@selector(visitManager:shouldCreateVisit:)]) {
        shouldCreateVisit = [self.delegate visitManager:self shouldCreateVisit:newVisit];
    } else {
        shouldCreateVisit = YES;
    }
    
    if (shouldCreateVisit) {
        self.latestVisit = newVisit;
        
        NSLog(@"touchpoints: %@", newVisit.touchpoints);
        
        // Delegate
        if ([self.delegate respondsToSelector:@selector(visitManager:didEnterLocation:visit:)]) {
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                [self.delegate visitManager:self didEnterLocation:newVisit.location visit:newVisit];
//            });
            [self executeOnMainQueue:^{
                [self.delegate visitManager:self didEnterLocation:newVisit.location visit:newVisit];
            }];
        }

        // START MONITORING
        [_regionManager stopMonitoringForAllSpecificRegions];
        [_regionManager startMonitoringForRegions:self.latestVisit.observableRegions];
        
        
        [self movedToRegion:beaconRegion];
        
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

- (void)movedToRegion:(CLBeaconRegion *)beaconRegion {
    if (![self.latestVisit.currentTouchpoints containsObject:self.latestVisit.wildcardTouchpoints.anyObject]) {
        // Enter all wildcard touchpoints
        [self.latestVisit.wildcardTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
            [self.latestVisit addToCurrentTouchpoints:touchpoint];
            
            // Delegate
            if ([self.delegate respondsToSelector:@selector(visitManager:didEnterTouchpoint:visit:)]) {
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    [self.delegate visitManager:self didEnterTouchpoint:touchpoint visit:self.latestVisit];
//                });
                [self executeOnMainQueue:^{
                    [self.delegate visitManager:self didEnterTouchpoint:touchpoint visit:self.latestVisit];
                }];
            }
        }];
    }
    
    RVTouchpoint *touchpoint = [self.latestVisit touchpointForRegion:beaconRegion];
    if (touchpoint) {
        
        // TODO: do we need to do a currentTouchpoints.contains check? in case of missfires
        
        [self.latestVisit addToCurrentTouchpoints:touchpoint];
        
        // Delegate
        if ([self.delegate respondsToSelector:@selector(visitManager:didEnterTouchpoint:visit:)]) {
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                [self.delegate visitManager:self didEnterTouchpoint:touchpoint visit:self.latestVisit];
//            });
            [self executeOnMainQueue:^{
                [self.delegate visitManager:self didEnterTouchpoint:touchpoint visit:self.latestVisit];
            }];
        }
        
    } else {
        NSLog(@"ROVER: Invalid touchpoint (minorNumber: %@)", beaconRegion.minor);
    }
}

- (void)exitAllWildcardTouchpoints {
    [self.latestVisit.wildcardTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
        [self.latestVisit removeFromCurrentTouchpoints:touchpoint];

        // Delegate
        if ([self.delegate respondsToSelector:@selector(visitManager:didExitTouchpoint:visit:)]) {
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                [self.delegate visitManager:self didExitTouchpoint:touchpoint visit:self.latestVisit];
//            });
            [self executeOnMainQueue:^{
                [self.delegate visitManager:self didExitTouchpoint:touchpoint visit:self.latestVisit];
            }];
        }
    }];
}

- (void)startExpirationTimer {
    _expirationTimer = [NSTimer scheduledTimerWithTimeInterval:self.latestVisit.keepAlive target:self selector:@selector(expireVisit) userInfo:nil repeats:NO];
}

- (void)expireVisit {
    if ([self.delegate respondsToSelector:@selector(visitManager:didExpireVisit:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate visitManager:self didExpireVisit:self.latestVisit];
        });
    }
}

@end