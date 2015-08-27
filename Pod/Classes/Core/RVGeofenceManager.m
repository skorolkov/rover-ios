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
    
    
    NSLog(@"Now monitoring for (%lu) regions", (unsigned long)self.monitoredRegions.count);
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
        [self startProcessing];
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

- (void)startProcessing {
//    if (_isProcessing) {
//        return;
//    }
    
    NSLog(@"Processing started");
    
    __block UIBackgroundTaskIdentifier processingTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background task expired");
        self.isProcessing = NO;
        [_locationManager stopUpdatingLocation];
        [_locationManager startMonitoringSignificantLocationChanges];
        [[UIApplication sharedApplication] endBackgroundTask:processingTask];
    }];
    
    // set state to processing
    _isProcessing = YES;
    
    // Turn off significant location change monitoring so it doesnt wake app over the didEnter thread that may be already started and in process
    [_locationManager stopMonitoringSignificantLocationChanges];
    
    // Turn on location updates for accuracy and so processing can happen in the background.
    [_locationManager startUpdatingLocation];
    
    NSTimeInterval timeToLockCoordinates = 10 - 6;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeToLockCoordinates * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self process];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_locationManager startMonitoringSignificantLocationChanges];
            [[UIApplication sharedApplication] endBackgroundTask:processingTask];
        });
    });
}

- (void)process {
    //self.processingTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(failedProcessingGeofencesWithError:) userInfo:nil repeats:NO];
    
    if (!_isProcessing) {
        return;
    }
    
    NSLog(@"processing...");
    
    CLLocation *currentLocation = _locationManager.location;
    
    NSMutableOrderedSet *mutableCurrentRegions = [self.currentRegions mutableCopy];
    
    // Check for exited regions
    
    for (CLCircularRegion *region in self.currentRegions) {
        if (![self location:currentLocation isInsideRegion:region generosity:0]) {
            NSLog(@"Exited Region: %@", region);

            [mutableCurrentRegions removeObject:region];
            
            // Delegate
            [self.delegate geofenceManager:self didExitRegion:(CLCircularRegion *)region];
        }
    }
    
    // Check for entered regions
    
    NSArray *orderedRegions = [self.dataSource geofenceManager:self regionsNearCoordinates:_lastUpdatedLocation.coordinate];
    
    for (CLCircularRegion *region in orderedRegions) {
        if ([self location:currentLocation isInsideRegion:region generosity:200] && ![self.currentRegions containsObject:region]) {
            NSLog(@"Entered Region: %@", region);
            
            NSUInteger index = [self indexOfRegion:region location:currentLocation inSet:mutableCurrentRegions];
            [mutableCurrentRegions insertObject:region atIndex:index];
            
            // Delegate
            [self.delegate geofenceManager:self didEnterRegion:region];
        }
    }
    
    // finish
    
    [_locationManager stopUpdatingLocation];
    
    self.currentRegions = [NSOrderedSet orderedSetWithOrderedSet:mutableCurrentRegions];
    [self persistCurrentRegions];
    NSLog(@"processing ended");
    _isProcessing = NO;
}

- (void)simulateMovingToCoordinate:(CLLocationCoordinate2D)coordinate {
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//    
//    // Check for exited regions
//    
//    for (CLCircularRegion *region in self.currentRegions) {
//        if (![self location:location isInsideRegion:region generosity:0]) {
//            NSLog(@"Exited Region: %@", region);
//            
//            [self.currentRegions removeObject:region];
//            
//            // Delegate
//            [self.delegate geofenceManager:self didExitRegion:(CLCircularRegion *)region];
//        }
//    }
//    
//    // Check for entered regions
//    
//    NSArray *orderedRegions = [self.dataSource geofenceManager:self regionsNearCoordinates:_lastUpdatedLocation.coordinate];
//    
//    for (CLCircularRegion *region in orderedRegions) {
//        if ([self location:location isInsideRegion:region generosity:200] && ![self.currentRegions containsObject:region]) {
//            NSLog(@"Entered Region: %@", region);
//            
//            NSUInteger index = [self indexOfRegion:region location:location inSet:];
//            [self.currentRegions insertObject:region atIndex:index];
//            
//            // Delegate
//            [self.delegate geofenceManager:self didEnterRegion:region];
//        }
//    }
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
        NSLog(@"woke up due to enter");
        if (/*![self.currentRegions containsObject:region] &&*/ !_isProcessing) {
            [_locationManager stopUpdatingLocation];
            
            NSArray *orderedRegions = [self.dataSource geofenceManager:self regionsNearCoordinates:_lastUpdatedLocation.coordinate];
            if (orderedRegions.count == 0) {
                return;
            }
            
            [self startProcessing];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        NSLog(@"woke up due to exit");
        [_locationManager stopUpdatingLocation];
        
        if (self.currentRegions.count == 0) {
            return;
        }
        
        [self startProcessing];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    // TODO: check the error and see if its not due to full slots then we must set _isMonitoring = NO;
    NSLog(@"ROVER - WARNING: Geofence monitoring failed - probably because you have run out of slots - : %@", error);
    //[_locationManager performSelectorInBackground:@selector(startMonitoringForRegion:) withObject:region];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (/*manager == _locationManager &&*/ !_isProcessing) { // Make sure this is called due to significantLocationMonitoring
        
        NSLog(@"Woke up due to significant change");
        
        // Telling the dataSource we updated location can restart monitoring and we dont want to do that if we are already in a location
        if (self.currentRegions.count > 0) {
            [self startProcessing];
            return;
        }
//  TODO: this logic should be moved to the data source
//        // Send updates every 10 KM
//        if (nil != self.lastUpdatedLocation && [manager.location distanceFromLocation:self.lastUpdatedLocation] < 10000) {
//            return;
//        }
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
}

@end
