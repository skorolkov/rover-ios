//
//  RVCircularRegionManager.m
//  Pods
//
//  Created by Ata Namvari on 2015-08-06.
//
//

#import "RVGeofenceManager.h"
@import UIKit;

// TODO: do a check when user opens the app to see if we are currently in a region

static NSString *const RVGeofenceManagerCurrentRegionsKey = @"RVGeofenceManagerCurrentRegionsKey";
static NSString *const RVGeofenceManagerLastUpdatedLocationKey = @"RVGeofenceManagerLastUpdatedLocationKey";


@interface RVGeofenceManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, assign) BOOL isMonitoring;
@property (nonatomic, assign) BOOL isProcessing;

//@property (nonatomic, strong) NSMutableOrderedSet *currentRegions;
@property (nonatomic, strong) CLLocation *lastUpdatedLocation;

@end

@implementation RVGeofenceManager

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationManager requestAlwaysAuthorization];
        }
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        [_locationManager startMonitoringSignificantLocationChanges];
        
        
        //[[NSUserDefaults standardUserDefaults] removeObjectForKey:RVGeofenceManagerCurrentRegionsKey];
    }
    return self;
}

#pragma mark - Properties

- (NSSet *)monitoredRegions {
    NSPredicate *circularRegionPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[CLCircularRegion class]];
    }];
    return [_locationManager.monitoredRegions filteredSetUsingPredicate:circularRegionPredicate];
}

- (NSOrderedSet *)currentRegions {
    if (_currentRegions) {
        return _currentRegions;
    }
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:RVGeofenceManagerCurrentRegionsKey];
    _currentRegions = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!_currentRegions) {
        _currentRegions = [NSMutableOrderedSet orderedSet];
    }
    
    return _currentRegions;
}

- (void)persistCurrentRegions {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_currentRegions];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:RVGeofenceManagerCurrentRegionsKey];
}

- (CLLocation *)lastUpdatedLocation {
    if (_lastUpdatedLocation) {
        return _lastUpdatedLocation;
    }
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:RVGeofenceManagerLastUpdatedLocationKey];
    _lastUpdatedLocation = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!_lastUpdatedLocation) {
        _lastUpdatedLocation = _locationManager.location;
    }
    
    return _lastUpdatedLocation;
}

- (void)persistLastUpdatedLocation {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_lastUpdatedLocation];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:RVGeofenceManagerLastUpdatedLocationKey];
}

#pragma mark - Instance Methods

- (void)startMonitoringForRegion:(CLCircularRegion *)region {
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    [_locationManager startMonitoringForRegion:region];
}

- (void)startMonitoring {
    NSArray *orderedRegions = [self.dataSource geofenceManager:self regionsNearCoordinates:_lastUpdatedLocation.coordinate];
    NSOrderedSet *regionsToMonitor;
    if (self.currentRegions.count > 0) {
        regionsToMonitor = self.currentRegions;
    } else {
        regionsToMonitor = [NSOrderedSet orderedSetWithArray:orderedRegions range:NSMakeRange(0, MIN(18, orderedRegions.count)) copyItems:NO];
    }
    
    for (CLCircularRegion *region in regionsToMonitor) {
        [self startMonitoringForRegion:region];
    }
    
    NSLog(@"Now monitoring for (%lu) regions", (unsigned long)self.monitoredRegions.count);
    
    _isMonitoring = YES;
    
    // Check to see if we have exited or entered any regions
    if (regionsToMonitor.count > 0) {
        
    } else {
        if ([self.dataSource respondsToSelector:@selector(geofenceManager:didUpdateLocation:)]) {
            [self.dataSource geofenceManager:self didUpdateLocation:_locationManager.location];
        }
    }
}

- (void)stopMonitoring {
    for (CLCircularRegion *region in self.monitoredRegions) {
        [_locationManager stopMonitoringForRegion:region];
    }
    
    _isMonitoring = NO;
}

- (void)restartMonitoring {
    if (_isMonitoring) {
        [self stopMonitoring];
        [self startMonitoring];
        NSLog(@"restarted monitoring");
    }
}

#pragma mark - Helpers

- (BOOL)location:(CLLocation *)location isInsideRegion:(CLCircularRegion *)region generosity:(CLLocationDistance)generosity {
    if (region.radius < _locationManager.maximumRegionMonitoringDistance) {
        CLLocation *regionCenter = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:region.center.longitude];
        CLLocationDistance d_r = [location distanceFromLocation:regionCenter] - MAX(region.radius, generosity);
        
        int roundedDelta = (int)d_r;
        roundedDelta -= roundedDelta % 10;
        
        if (d_r < 0 || roundedDelta <= 0) {
            return YES;
        }
    }
    return NO;
}

- (NSUInteger)indexOfRegion:(CLCircularRegion *)region location:(CLLocation *)location inSet:(NSOrderedSet *)regions {
    return [regions      indexOfObject:region
                         inSortedRange:NSMakeRange(0, regions.count)
                               options:NSBinarySearchingInsertionIndex
                       usingComparator:^NSComparisonResult(CLCircularRegion *region1, CLCircularRegion *region2) {
                           
                           CLLocation *region1Center = [[CLLocation alloc] initWithLatitude:region1.center.latitude longitude:region1.center.longitude];
                           CLLocationDistance region1Distance = [location distanceFromLocation:region1Center];
                           
                           CLLocation *region2Center = [[CLLocation alloc] initWithLatitude:region2.center.latitude longitude:region2.center.longitude];
                           CLLocationDistance region2Distance = [location distanceFromLocation:region2Center];
                           
                           if (region1Distance < region2Distance) {
                               return NSOrderedAscending;
                           } else if (region1Distance > region2Distance) {
                               return NSOrderedDescending;
                           } else {
                               return NSOrderedSame;
                           }
                       }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        
        NSLog(@"entered with accuracy: %@", manager.location);
        NSLog(@"region: %@", region);
        
        NSMutableOrderedSet *mutableCurrentRegions = [self.currentRegions mutableCopy];
        [mutableCurrentRegions insertObject:region atIndex:[self indexOfRegion:region location:_locationManager.location inSet:mutableCurrentRegions]];
        self.currentRegions = [NSOrderedSet orderedSetWithOrderedSet:mutableCurrentRegions];
        [self.delegate geofenceManager:self didEnterRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        
        NSLog(@"exited with accuracy: %@", manager.location);
        NSLog(@"region: %@", region);
        
        NSMutableOrderedSet *mutableCurrentRegions = [self.currentRegions mutableCopy];
        [mutableCurrentRegions removeObject:region];
        self.currentRegions = [NSOrderedSet orderedSetWithOrderedSet:mutableCurrentRegions];
        [self.delegate geofenceManager:self didExitRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    // TODO: check the error and see if its not due to full slots then we must set _isMonitoring = NO;
    NSLog(@"ROVER - WARNING: Geofence monitoring failed - probably because you have run out of slots - : %@", error);
    //[_locationManager performSelectorInBackground:@selector(startMonitoringForRegion:) withObject:region];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    // Telling the dataSource we updated location can restart monitoring and we dont want to do that if we are already in a location
    if (self.currentRegions.count > 0) {
        return;
    }

    if (nil != self.lastUpdatedLocation && [manager.location isEqual:self.lastUpdatedLocation]) {
        return;
    }
    
    self.lastUpdatedLocation = manager.location;
    
    // Update monitored regions
    if ([self.dataSource respondsToSelector:@selector(geofenceManager:didUpdateLocation:)]) {
        [self.dataSource geofenceManager:self didUpdateLocation:manager.location];
    }
    
    [self persistLastUpdatedLocation];
}

@end
