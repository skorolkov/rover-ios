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
                
                [self performSelectorOnMainThread:@selector(startExpirationTimer) withObject:nil waitUntilDone:NO];
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