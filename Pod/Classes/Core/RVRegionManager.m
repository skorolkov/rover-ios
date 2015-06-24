//
//  RVLocationService.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-23.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVRegionManager.h"
#import "RVLog.h"


@interface RVRegionManager ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocationManager *specificLocationManager;
@property (strong, nonatomic) NSDate *beaconDetectedAt;
@property (nonatomic, strong) NSSet *currentRegions;

@end

@implementation RVRegionManager

#pragma mark - Instance Methods

// TODO: fix current Region stuff here

- (void)simulateRegionEnterWithBeaconUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:UUID major:major minor:minor identifier:[self identifierForUUID:UUID major:major minor:minor]];
    
    NSMutableSet *tempCurrentRegions = [NSMutableSet setWithSet:self.currentRegions];
    [tempCurrentRegions addObject:beaconRegion];
    self.currentRegions = [NSSet setWithSet:tempCurrentRegions];
    
    [self.delegate regionManager:self didEnterRegions:[NSSet setWithObject:beaconRegion]];
}

- (void)simulateRegionExitWithBeaconUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:UUID major:major minor:minor identifier:[self identifierForUUID:UUID major:major minor:minor]];
    
    NSMutableSet *tempCurrentRegions = [NSMutableSet setWithSet:self.currentRegions];
    [tempCurrentRegions removeObject:beaconRegion];
    self.currentRegions = [NSSet setWithSet:tempCurrentRegions];
    
    [self.delegate regionManager:self didExitRegions:[NSSet setWithObject:beaconRegion]];
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

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        _beaconRegions = [[NSMutableArray alloc] initWithCapacity:20];
        
        _currentRegions = [NSSet set];
        
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

- (NSString *)identifierForUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor {
    return [NSString stringWithFormat:@"%@-%u-%u", UUID.UUIDString, major, minor];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLRegion *)region {
    // TODO: remove this to make more efficient
    //RVLog(kRoverDidRangeBeaconsNotification, @{ @"count": [NSNumber numberWithUnsignedInteger:[beacons count]] });
    
    NSMutableSet *regions = [NSMutableSet set];
    [beacons enumerateObjectsUsingBlock:^(CLBeacon *beacon, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID major:beacon.major.integerValue minor:beacon.minor.integerValue identifier:[self identifierForUUID:beacon.proximityUUID major:beacon.major.integerValue minor:beacon.minor.integerValue]];
        [regions addObject:beaconRegion];
    }];
    
    if ([regions isEqualToSet:self.currentRegions]) {
        return;
    } else {
        NSMutableSet *enteredRegions = [NSMutableSet setWithSet:regions];
        [enteredRegions minusSet:self.currentRegions];
        
        NSMutableSet *exitedRegions = [NSMutableSet setWithSet:self.currentRegions];
        [exitedRegions minusSet:regions];
        
        self.currentRegions = regions;

        if (exitedRegions.count > 0) {
            [self.delegate regionManager:self didExitRegions:exitedRegions];
        }
        
        if (enteredRegions.count > 0) {
            [self.delegate regionManager:self didEnterRegions:enteredRegions];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
#if TARGET_IPHONE_SIMULATOR
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"ROVER - WARNING: The iOS Simulator does not support monitoring for beacons. To simulate a beacon use the [Rover simulateBeaconWithUUID:major:minor:] method. See http://dev.roverlabs.co/v1.0/docs/getting-started#simulate-a-beacon for more details.");
    });
#else
    NSLog(@"ROVER - WARNING: Monitoring failed - probably because you have run out of slots - : %@", error);
#endif
}

@end