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

/** This class is responsible for monitoring and ranging for beacons.
 */
@interface RVRegionManager : NSObject <CLLocationManagerDelegate>

/** Delegate that gets notified of region events.
 */
@property (nonatomic, weak) id <RVRegionManagerDelegate> delegate;

/** The array of NSUUIDs to monitor for.
 */
@property (strong, nonatomic) NSArray *beaconUUIDs;

/** The beacons regions that are always monitored and ranged for. For the most part this set should only include one beacon reagon identified
 only by the UUID.
 */
@property (strong, nonatomic) NSMutableArray *beaconRegions;

/** An NSSet of CLBeaconRegions the user is currently in.
 */
@property (nonatomic, readonly) NSSet *currentRegions;

/** An NSArray of specific CLBeaconRegions the manager is currenly monitoring for.
 */
@property (nonatomic, readonly, strong) NSArray *specificRegions;

/** Begin monitoring for beacon regions with set UUID.
 */
- (void)startMonitoring;

/** Stop monitoring for beacon regions.
 */
- (void)stopMonitoring;

/** Begin monitoring for specific CLBeaconRegions within one location.
 */
- (void)startMonitoringForRegions:(NSArray *)regions;

/** Stop monitoring for all specific CLBeaconRegions. Calling this does not stop monitoring for the set UUIDs.
 */
- (void)stopMonitoringForAllSpecificRegions;

/** Convenience method to simulate going in and then out of a CLBeaconRegion.
 */
- (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;

@end


@protocol RVRegionManagerDelegate <NSObject>

/** Called when the user enters a region.
 
 @param manager The region manager instance thats calling the delegate method.
 @param region An NSSet of CLRegions the user has entered.
 */
- (void)regionManager:(RVRegionManager *)manager didEnterRegions:(NSSet *)regions;

/** Called when the user exits a region.
 
 @param manager The region manager instance thats calling the delegate method.
 @oaram region An NSSet of CLRegions the user has exited.
 */
- (void)regionManager:(RVRegionManager *)manager didExitRegions:(NSSet *)regions;

@end