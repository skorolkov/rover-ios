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

@property (strong, nonatomic) NSMutableArray *beaconRegions;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeacon *nearestBeacon;
@property (strong, nonatomic) NSDate *beaconDetectedAt;

@property (readonly, nonatomic) NSTimeInterval timeSinceBeaconDetected;

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
    [self stopMonitoring];
    [self.beaconRegions removeAllObjects];
    
    [beaconUUIDs enumerateObjectsUsingBlock:^(NSUUID *UUID, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:UUID identifier:UUID.UUIDString];
        beaconRegion.notifyEntryStateOnDisplay = YES;
        [self.beaconRegions addObject:beaconRegion];
    }];
    
    _beaconUUIDs = beaconUUIDs;
}

- (NSTimeInterval)timeSinceBeaconDetected {
    if (!self.beaconDetectedAt) {
        return 0;
    }
    
    NSDate *now = [NSDate date];
    return [now timeIntervalSinceDate:self.beaconDetectedAt];
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        self.beaconRegions = [[NSMutableArray alloc] initWithCapacity:20];
        
        self.locationManager = [[CLLocationManager alloc] init];
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        self.locationManager.delegate = self;
    }
    return  self;
}

#pragma mark - Utility methods

- (BOOL)isCurrentRegion:(CLBeacon *)beacon {
    return [self.nearestBeacon.proximityUUID.UUIDString isEqualToString:beacon.proximityUUID.UUIDString]
            && [self.nearestBeacon.major isEqualToNumber:beacon.major];
}

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

#pragma mark - Notifications

- (void)postEnterNotification:(CLBeacon *)beacon {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID major:beacon.major.integerValue identifier:beacon.proximityUUID.UUIDString];
    
    [[RVNotificationCenter defaultCenter] postNotificationName:kRVRegionManagerDidEnterRegionNotification object:self userInfo:@{ @"beaconRegion": beaconRegion }];
}

- (void)postExitNotification:(CLBeacon *)beacon {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID major:beacon.major.integerValue identifier:beacon.proximityUUID.UUIDString];
    
    [[RVNotificationCenter defaultCenter] postNotificationName:kRVRegionManagerDidExitRegionNotification object:self userInfo:@{ @"beaconRegion": beaconRegion }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLRegion *)region {
    RVLog(kRoverDidRangeBeaconsNotification, @{ @"count": [NSNumber numberWithUnsignedInteger:[beacons count]] });

    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    CLBeacon *currentBeacon = [beacons lastObject];
    
    if (currentBeacon) {
        if (self.nearestBeacon && [self isCurrentRegion:currentBeacon] && self.timeSinceBeaconDetected < TWO_HOURS) {
            return;
        }
        
        self.nearestBeacon = currentBeacon;
        self.beaconDetectedAt = [NSDate date];
        [self postEnterNotification:currentBeacon];
    } else if (self.nearestBeacon && [self.nearestBeacon.proximityUUID.UUIDString isEqualToString:beaconRegion.proximityUUID.UUIDString]) {
        CLBeacon *temp = self.nearestBeacon;
        self.nearestBeacon = nil;
        self.beaconDetectedAt = nil;
        [self postExitNotification:temp];        
    }
}

@end