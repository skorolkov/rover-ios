//
//  RVVisit.h
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVModel.h"

@class RVTouchpoint;
@class RVLocation;
@class RVOrganization;
@class RVCustomer;
@class CLBeaconRegion;

@interface RVVisit : RVModel


@property (readonly) BOOL isAlive;



//_____REQUEST ______

@property (nonatomic, strong) NSUUID *UUID;
@property (nonatomic, strong) NSNumber *majorNumber;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, assign) BOOL simulate;
@property (nonatomic, strong) NSString *locationIdentifier;

// _____ RESPONSE_____

// TODO: make private
@property (nonatomic) NSTimeInterval keepAlive;
@property (strong, nonatomic) RVOrganization *organization;
@property (strong, nonatomic) RVLocation *location;
@property (strong, nonatomic) RVCustomer *customer;
@property (strong, nonatomic) NSArray *touchpoints;
@property (nonatomic, readonly) NSSet *wildcardTouchpoints;
@property (nonatomic, readonly) NSSet *geofenceTouchpoints;

@property (nonatomic, assign) BOOL locationEntered;
@property (nonatomic, assign) BOOL isGeofenceTriggered;

// _____ TODO:  private ____

@property (strong, nonatomic) NSDate *beaconLastDetectedAt;
@property (strong, nonatomic) NSMutableSet *currentTouchpoints;
@property (nonatomic, readonly) NSArray *visitedTouchpoints;
@property (nonatomic, readonly) NSArray *allImageUrls;
@property (nonatomic, readonly) NSArray *observableRegions;

+ (instancetype)latestVisit;
+ (void)setLatestVisit:(RVVisit *)visit;
+ (void)clearLatestVisit;

// TODO: use a category
+ (instancetype)cachedVisitWithIdentifier:(id<NSCopying>)identifier;
+ (void)setCachedVisit:(RVVisit *)visit withIdentifier:(id<NSCopying>)identifier;
+ (void)deleteCachedVisitWithIdentifier:(id<NSCopying>)identifier;
+ (void)clearCache;

- (BOOL)isInLocationRegion:(CLBeaconRegion *)beaconRegion;
- (BOOL)isInTouchpointRegion:(CLBeaconRegion *)beaconRegion;
- (BOOL)isInLocationWithIdentifier:(NSString *)identifier;

- (RVTouchpoint *)touchpointForRegion:(CLBeaconRegion *)beaconRegion;
- (RVTouchpoint *)touchpointForMinor:(NSNumber *)minor;
- (RVTouchpoint *)touchpointWithID:(NSString *)identifier;

- (void)addToCurrentTouchpoints:(RVTouchpoint *)touchpoint;
- (void)removeFromCurrentTouchpoints:(RVTouchpoint *)touchpoint;

@end

// TODO: persist new flags to disk
