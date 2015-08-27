//
//  RVCircularRegionManager.h
//  Pods
//
//  Created by Ata Namvari on 2015-08-06.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol RVGeofenceManagerDelegate;
@protocol RVGeofenceManagerDataSource;

@interface RVGeofenceManager : NSObject

/** Delegate that gets notified of region events.
 */
@property (nonatomic, weak) id<RVGeofenceManagerDelegate> delegate;

/** DataSource to supply the manager with geofences to monitor for.
 */
@property (nonatomic, weak) id<RVGeofenceManagerDataSource> dataSource;

/** An NSSet of CLCircularRegions the OS is currently monitoring for.
 */
@property (nonatomic, readonly) NSSet *monitoredRegions;


@property (nonatomic, strong) NSOrderedSet *currentRegions;

/** Starts monitoring for geofences. Invokes a DataSource method when called.
 */
- (void)startMonitoring;

/** Stops monitoring for geofences.
 */
- (void)stopMonitoring;

/** Stops and starts monitoring for geofences. Invokes a DataSource method when called.
 */
- (void)restartMonitoring;

/** Start monitoring for a specific region. Does not invoke DataSource.
 
 @param region The CLCircularRegion to monitor.
 */
- (void)startMonitoringForRegion:(CLCircularRegion *)region;

/** Simulates moving to a coordinate. Will invoke delegate methods if necessary.
 */
- (void)simulateMovingToCoordinate:(CLLocationCoordinate2D)coordinate;

@end


@protocol RVGeofenceManagerDelegate <NSObject>

/** Called when the user enters a region.
 */
- (void)geofenceManager:(RVGeofenceManager *)manager didEnterRegion:(CLCircularRegion *)region;

/** Called when the user enters a region.
 */
- (void)geofenceManager:(RVGeofenceManager *)manager didExitRegion:(CLCircularRegion *)region;

@end


@protocol RVGeofenceManagerDataSource <NSObject>

/** Must return an NSArray of CLCircularRegions for the manager to monitor for. Called everytime monitoring is about to start.
 */
- (NSArray *)geofenceManager:(RVGeofenceManager *)manager regionsNearCoordinates:(CLLocationCoordinate2D)coordinates;

@optional

/** Called when the user has a significant location change. This is a good spot for reallocating monitoring resources.
 */
- (void)geofenceManager:(RVGeofenceManager *)manager didUpdateLocation:(CLLocation *)location;

@end