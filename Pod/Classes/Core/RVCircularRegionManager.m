//
//  RVCircularRegionManager.m
//  Pods
//
//  Created by Ata Namvari on 2015-08-06.
//
//

#import "RVCircularRegionManager.h"

// TODO: do a check when user opens the app to see if we are currently in a region
// TODO: can use the same check to see if we missed an exit event

static NSString *const RVGeofenceManagerCurrentRegionIDsKey = @"RVGeofenceManagerCurrentRegionIDsKey";
static NSString *const RVGeofenceManagerLastUpdatedLocationKey = @"RVGeofenceManagerLastUpdatedLocationKey";


@interface RVCircularRegionManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastUpdatedLocation;

@property (nonatomic, assign) BOOL isMonitoring;

@property (nonatomic, assign) BOOL isProcessing;

@property (nonatomic, strong) NSMutableOrderedSet *currentRegions;
@property (nonatomic, strong) NSMutableArray *currentRegionIds;

@end

@implementation RVCircularRegionManager

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
        
        
        
        // TODO: somehow make this persistent
        _currentRegions = [NSMutableOrderedSet orderedSet];
        // if currentRegions.count == 0 ->
        [_locationManager startMonitoringSignificantLocationChanges];

        
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

- (NSMutableArray *)currentRegionIds {
    if (_currentRegionIds) {
        return _currentRegionIds;
    }
    
    _currentRegionIds = [[[NSUserDefaults standardUserDefaults] objectForKey:RVGeofenceManagerCurrentRegionIDsKey] mutableCopy];
    if (!_currentRegionIds) {
        _currentRegionIds = [NSMutableArray array];
    }
    
    return _currentRegionIds;
}

// TODO: start background task when processing so we can get be sure to get atleast 10 seconds of processing time

//- (NSMutableOrderedSet *)currentRegions {
//    if (_currentRegions) {
//        return _currentRegions;
//    }
//    
//    NSArray *currentRegionsArray = [[NSUserDefaults standardUserDefaults] objectForKey:RVGeofenceManagerCurrentRegionIDsKey];
//    if (currentRegionsArray) {
//        _currentRegions = [NSMutableOrderedSet orderedSetWithArray:currentRegionsArray];
//    } else {
//        _currentRegions = [NSMutableOrderedSet orderedSet];
//    }
//    
//    return _currentRegions;
//}

//- (CLLocation *)lastUpdatedLocation {
//    if (_lastUpdatedLocation) {
//        return _lastUpdatedLocation;
//    }
//    
//    //_lastUpdatedLocation = [[NSUserDefaults standardUserDefaults] objectForKey:RVGeofenceManagerLastUpdatedLocationKey];
//    if (!_lastUpdatedLocation) {
//        _lastUpdatedLocation = _locationManager.location;
//    }
//    
//    return _lastUpdatedLocation;
//}

#pragma mark - Instance Methods

- (void)startMonitoringForRegion:(CLCircularRegion *)region {
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    [_locationManager startMonitoringForRegion:region];
    NSLog(@"selfmonitoredfences: %@", _locationManager.monitoredRegions);
}

- (void)startMonitoring {
    NSArray *orderedRegions = [self.dataSource circularRegionManager:self regionsNearCoordinates:_lastUpdatedLocation.coordinate];
    NSOrderedSet *regionsToMonitor = [NSOrderedSet orderedSetWithArray:orderedRegions range:NSMakeRange(0, MIN(18, orderedRegions.count)) copyItems:NO];
    for (CLCircularRegion *region in regionsToMonitor) {
        [self startMonitoringForRegion:region];
    }

    
    //[_locationManager startMonitoringSignificantLocationChanges];
    
    //NSLog(@"Now monitoring for regions: %@", self.monitoredRegions);
    
    _isMonitoring = YES;
}

- (void)stopMonitoring {
    for (CLCircularRegion *region in self.monitoredRegions) {
        [_locationManager stopMonitoringForRegion:region];
    }
    
    //[_locationManager stopMonitoringSignificantLocationChanges];
    
    NSLog(@"stopped monitoring for regions: %@", self.monitoredRegions);
    
    _isMonitoring = NO;
}

- (void)restartMonitoring {
    if (_isMonitoring) {
        [self stopMonitoring];
        [self startMonitoring];
    }
}

- (void)process {
    //self.processingTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(failedProcessingGeofencesWithError:) userInfo:nil repeats:NO];
    
    if (!_isProcessing) {
        return;
    }
    
    CLLocation *currentLocation = _locationManager.location;
    
    for (CLCircularRegion *region in [self monitoredRegions]) {
        if (region.radius < _locationManager.maximumRegionMonitoringDistance) {
            CLLocation *regionCenter = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:region.center.longitude];
            CLLocationDistance d_r = [currentLocation distanceFromLocation:regionCenter] - MAX(region.radius, 200);
            
            int roundedDelta = (int)d_r;
            roundedDelta -= roundedDelta % 10;
            
            if (d_r < 0 || roundedDelta <= 0) {
                [self.currentRegions addObject:region];
                [self.currentRegionIds addObject:region.identifier];
            }
        }
    }
    
    // finish
    
    [_locationManager stopUpdatingLocation];
    
    
    // Sort the currently entered regions by distance
    [self.currentRegions sortUsingComparator:^NSComparisonResult(CLCircularRegion *region1, CLCircularRegion *region2) {
        CLLocation *region1Center = [[CLLocation alloc] initWithLatitude:region1.center.latitude longitude:region1.center.longitude];
        CLLocationDistance region1Distance = [currentLocation distanceFromLocation:region1Center];
        
        CLLocation *region2Center = [[CLLocation alloc] initWithLatitude:region2.center.latitude longitude:region2.center.longitude];
        CLLocationDistance region2Distance = [currentLocation distanceFromLocation:region2Center];
        
        if (region1Distance < region2Distance) {
            return NSOrderedAscending;
        } else if (region1Distance > region2Distance) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    // Delegate
    for (CLCircularRegion *region in self.currentRegions) {
        NSLog(@"Entered Region: %@", region);
        
        [self.delegate circularRegionManager:self didEnterRegion:region];
        
        [_locationManager stopMonitoringSignificantLocationChanges];
    }
    
    // store enteredRegions
    [[NSUserDefaults standardUserDefaults] setObject:self.currentRegionIds forKey:RVGeofenceManagerCurrentRegionIDsKey];
    
    NSLog(@"currentRegionIds: %@", self.currentRegionIds);
    
    _isProcessing = NO;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        if (![self.currentRegions containsObject:region] && !_isProcessing) {

            [_locationManager stopUpdatingLocation];
            
            //[self stopMonitoring];
            
            NSArray *orderedRegions = [self.dataSource circularRegionManager:self regionsNearCoordinates:_lastUpdatedLocation.coordinate];
            if (orderedRegions.count > 0) {
                // set state to processing
                _isProcessing = YES;
                
                
                
                NSTimeInterval timeToLockCoordinates = 10 - 6;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeToLockCoordinates * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self process];
                });

                // Turn on location updates for accuracy and so processing can happen in the background.
                [_locationManager startUpdatingLocation];
                
                //        // Turn on significant location changes to help monitor the current region.
                //        [_locationManager startMonitoringSignificantLocationChanges];
            }
            
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        
        for (CLCircularRegion *currentRegion in self.currentRegions) {
            if ([region.identifier isEqualToString:currentRegion.identifier]) {
                NSLog(@"Exited Region: %@", region);
                
                [self.currentRegionIds removeObject:region.identifier];
                [self.currentRegions removeObject:currentRegion];
                [self.delegate circularRegionManager:self didExitRegion:(CLCircularRegion *)region];
                
                if (self.currentRegions.count == 0) {
                    [_locationManager startMonitoringSignificantLocationChanges];
                }
            }
        }
        
        // Finish
        // store current regions
        [[NSUserDefaults standardUserDefaults] setObject:self.currentRegionIds forKey:RVGeofenceManagerCurrentRegionIDsKey];
        
        NSLog(@"currentRegionsIds: %@", self.currentRegionIds);
        
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    // TODO: check the error and see if its not due to full slots then we must set _isMonitoring = NO;
    NSLog(@"ROVER - WARNING: Geofence monitoring failed - probably because you have run out of slots - : %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (manager == _locationManager && !_isProcessing) { // Make sure this is called due to significantLocationMonitoring
        
//        // Telling the dataSource we updated location can restart monitoring and we dont want to do that if we are already in a location
//        if (self.currentRegions.count > 0) {
//            return;
//        }
        
        // TODO: do a better check here with location age and distance from previous location so we call our data source less often
        if (nil != self.lastUpdatedLocation && [manager.location isEqual:self.lastUpdatedLocation]) {
            return;
        }
        
        // TOOD: should store this on disk also
        self.lastUpdatedLocation = manager.location;
        
        // Update monitored regions
        if ([self.dataSource respondsToSelector:@selector(circularRegionManager:didUpdateLocation:)]) {
            [self.dataSource circularRegionManager:self didUpdateLocation:manager.location];
        }
    }
}

@end
