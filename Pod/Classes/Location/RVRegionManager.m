//
//  RVLocationService.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-23.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVRegionManager.h"
#import "RVNotificationCenter.h"
#import "RVLog.h"

#define TWO_HOURS 7200

NSString *const kRVRegionManagerDidEnterRegionNotification = @"RVRegionManagerDidEnterRegionNotification";
NSString *const kRVRegionManagerDidExitRegionNotification = @"RVRegionManagerDidExitRegionNotification";

@interface RVRegionManager ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocationManager *specificLocationManager;
@property (strong, nonatomic) NSDate *beaconDetectedAt;

@property (readonly, nonatomic) NSTimeInterval timeSinceBeaconDetected; // This may not be needed anymore.

@property (nonatomic, strong) NSSet *currentRegions;

@end

@implementation RVRegionManager

#pragma mark - Class Methods

+ (id)sharedManager {
    static RVRegionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Properties

- (void)setBeaconUUIDs:(NSArray *)beaconUUIDs {
    _beaconUUIDs = beaconUUIDs;
    [self stopMonitoring];
    [self setupBeaconRegionsForUUIDs:beaconUUIDs];
}

- (void)setBeaconRegions:(NSMutableArray *)beaconRegions {
    _beaconRegions = beaconRegions;
    [self stopMonitoring];
    [self setupBeaconRegions];
}

//- (NSTimeInterval)timeSinceBeaconDetected {
//    if (!self.beaconDetectedAt) {
//        return 0;
//    }
//    
//    NSDate *now = [NSDate date];
//    return [now timeIntervalSinceDate:self.beaconDetectedAt];
//}


#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        _beaconRegions = [[NSMutableArray alloc] initWithCapacity:20];
        
        _locationManager = [[CLLocationManager alloc] init];
        _specificLocationManager = [[CLLocationManager alloc] init];
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationManager requestAlwaysAuthorization];
            [_specificLocationManager requestAlwaysAuthorization];
        }
        _locationManager.delegate = self;
        _specificLocationManager.delegate = self;
    }
    return  self;
}

// TODO: to save battery life, should only start ranging after monitoring has entered a location, then stop when exited the visit (keepalive?)

#pragma mark - Region monitoring

- (void)startMonitoring {
    [self.beaconRegions enumerateObjectsUsingBlock:^(CLBeaconRegion *beaconRegion, NSUInteger idx, BOOL *stop) {
        [self.locationManager startMonitoringForRegion:beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    }];
}

- (void)stopMonitoring {
    [self.beaconRegions enumerateObjectsUsingBlock:^(CLBeaconRegion *beaconRegion, NSUInteger idx, BOOL *stop) {
        [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
        [self.locationManager stopMonitoringForRegion:beaconRegion];
    }];
}

- (void)startMonitoringForRegions:(NSArray *)regions {
    _specificRegions = regions;
    [_specificRegions enumerateObjectsUsingBlock:^(CLBeaconRegion *beaconRegion, NSUInteger idx, BOOL *stop) {
        beaconRegion.notifyEntryStateOnDisplay = YES;
        [_specificLocationManager startMonitoringForRegion:beaconRegion];
    }];
}

- (void)stopMonitoringForAllSpecificRegions {
    [_specificRegions enumerateObjectsUsingBlock:^(CLBeaconRegion *beaconRegion, NSUInteger idx, BOOL *stop) {
        [_specificLocationManager stopMonitoringForRegion:beaconRegion];
    }];
    _specificRegions = nil;
}

#pragma mark - Notifications

- (void)postEnterNotification:(CLBeaconRegion *)beaconRegion {
    [[RVNotificationCenter defaultCenter] postNotificationName:kRVRegionManagerDidEnterRegionNotification object:self userInfo:@{ @"beaconRegion": beaconRegion}];
}

- (void)postExitNotification:(CLBeaconRegion *)beaconRegion {
    [[RVNotificationCenter defaultCenter] postNotificationName:kRVRegionManagerDidExitRegionNotification object:self userInfo:@{ @"beaconRegion": beaconRegion,
                                                                                                                                 @"allRegions": self.currentRegions}];
}

#pragma mark - Helper Methods

- (void)setupBeaconRegionsForUUIDs:(NSArray *)UUIDs {
    [self.beaconRegions removeAllObjects];
    
    [UUIDs enumerateObjectsUsingBlock:^(NSUUID *UUID, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:UUID identifier:UUID.UUIDString];
        beaconRegion.notifyEntryStateOnDisplay = YES;
        [self.beaconRegions addObject:beaconRegion];
    }];
}

- (void)setupBeaconRegions {
    [self.beaconRegions enumerateObjectsUsingBlock:^(CLBeaconRegion *beaconRegion, NSUInteger idx, BOOL *stop) {
        beaconRegion.notifyEntryStateOnDisplay = YES;
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLRegion *)region {
    RVLog(kRoverDidRangeBeaconsNotification, @{ @"count": [NSNumber numberWithUnsignedInteger:[beacons count]] });
    
    NSMutableArray *wrappedBeacons = [NSMutableArray arrayWithCapacity:beacons.count];
    [beacons enumerateObjectsUsingBlock:^(CLBeacon *beacon, NSUInteger idx, BOOL *stop) {
        [wrappedBeacons insertObject:[[CLBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID major:beacon.major.integerValue minor:beacon.minor.integerValue identifier:[NSString stringWithFormat:@"%@-%@-%@", beacon.proximityUUID.UUIDString, beacon.major, beacon.minor]] atIndex:idx];
    }];
    
    NSSet *regions = [NSSet setWithArray:wrappedBeacons];
    
    // TODO: investigate if we still need that self.timeSinceLastBeaconDetected < TWO_HOURS condition.
    if ([regions isEqualToSet:self.currentRegions]) {
        return;
    } else {
        NSMutableSet *enteredRegions = [NSMutableSet setWithSet:regions];
        [enteredRegions minusSet:self.currentRegions];
        
        NSMutableSet *exitedRegions = [NSMutableSet setWithSet:self.currentRegions];
        [exitedRegions minusSet:regions];
        
        [exitedRegions enumerateObjectsUsingBlock:^(CLBeaconRegion *beaconRegion, BOOL *stop) {
            [self postExitNotification:beaconRegion];
        }];
        
        [enteredRegions enumerateObjectsUsingBlock:^(CLBeaconRegion *beaconRegion, BOOL *stop) {
            [self postEnterNotification:beaconRegion];
        }];
        
        self.currentRegions = regions;
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Monitoring failed - probably because you have run out of slots - : %@", error);
}

@end