//
//  RVLocationService.h
//  Rover
//
//  Created by Sean Rucker on 2014-06-23.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol RVRegionManagerDelegate;

@interface RVRegionManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id <RVRegionManagerDelegate> delegate;
@property (strong, nonatomic) NSArray *beaconUUIDs;
@property (strong, nonatomic) NSMutableArray *beaconRegions;
@property (nonatomic, readonly) NSSet *currentRegions;
@property (nonatomic, readonly, strong) NSArray *specificRegions;

- (void)startMonitoring;
- (void)stopMonitoring;
- (void)startMonitoringForRegions:(NSArray *)regions;
- (void)stopMonitoringForAllSpecificRegions;

- (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;

@end


@protocol RVRegionManagerDelegate <NSObject>

- (void)regionManager:(RVRegionManager *)manager didEnterRegion:(CLRegion *)region totalRegions:(NSSet *)regions;
- (void)regionManager:(RVRegionManager *)manager didExitRegion:(CLRegion *)region totalRegions:(NSSet *)regions;

@end