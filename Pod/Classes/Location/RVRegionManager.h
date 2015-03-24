//
//  RVLocationService.h
//  Rover
//
//  Created by Sean Rucker on 2014-06-23.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const kRVRegionManagerDidEnterRegionNotification;
extern NSString *const kRVRegionManagerDidExitRegionNotification;

@interface RVRegionManager : NSObject <CLLocationManagerDelegate>

+ (id)sharedManager;

@property (strong, nonatomic) NSArray *beaconUUIDs;
@property (strong, nonatomic) NSMutableArray *beaconRegions;
@property (nonatomic, readonly) NSSet *currentRegions;
//@property (nonatomic, readonly)

- (void)startMonitoring;
- (void)stopMonitoring;
- (void)startMonitoringForRegions:(NSArray *)regions;
- (void)stopMonitoringForAllSpecificRegions;

@end