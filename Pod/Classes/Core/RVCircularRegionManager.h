//
//  RVCircularRegionManager.h
//  Pods
//
//  Created by Ata Namvari on 2015-08-06.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol RVCircularRegionManagerDelegate;
@protocol RVCircularRegionManagerDataSource;

@interface RVCircularRegionManager : NSObject

@property (nonatomic, weak) id<RVCircularRegionManagerDelegate> delegate;
@property (nonatomic, weak) id<RVCircularRegionManagerDataSource> dataSource;
@property (nonatomic, readonly) NSSet *monitoredRegions;
@property (nonatomic, readonly) CLLocation *lastUpdatedLocation;
@property (nonatomic, readonly) CLCircularRegion *currentRegion;

- (void)startMonitoring;
- (void)stopMonitoring;
- (void)restartMonitoring;

- (void)startMonitoringForRegion:(CLCircularRegion *)region;

- (void)simulateMovingToCoordinates:(CLLocationCoordinate2D)coordinates;


@end


@protocol RVCircularRegionManagerDelegate <NSObject>

- (void)circularRegionManager:(RVCircularRegionManager *)manager didEnterRegion:(CLCircularRegion *)region;
- (void)circularRegionManager:(RVCircularRegionManager *)manager didExitRegion:(CLCircularRegion *)region;

@end


@protocol RVCircularRegionManagerDataSource <NSObject>

- (NSArray *)circularRegionManager:(RVCircularRegionManager *)manager regionsNearCoordinates:(CLLocationCoordinate2D)coordinates;

@optional
- (void)circularRegionManager:(RVCircularRegionManager *)manager didUpdateLocation:(CLLocation *)location;

@end