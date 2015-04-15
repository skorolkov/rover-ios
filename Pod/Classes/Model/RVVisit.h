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

extern NSString *const kRoverDidCreateVisitNotification;
extern NSString *const kRoverDidVisitTouchpointNotification;

/** Represents a vist to a real-world physical location by a customer. A visit object will be created by the Rover Platform and delivered to the SDK when a customer enters a location.
 */
@interface RVVisit : RVModel


@property (readonly) BOOL isAlive;


@property (nonatomic, assign) BOOL valid;

//_____REQUEST ______

@property (nonatomic, strong) NSUUID *UUID;

@property (nonatomic, strong) NSNumber *majorNumber;

@property (nonatomic, strong) NSDate *timestamp;

@property (nonatomic, assign) BOOL simulate;

// _____ RESPONSE_____

// TODO: make private
@property (nonatomic) NSTimeInterval keepAlive;

/** The organization the visited location belongs to.
 */
@property (strong, nonatomic) RVOrganization *organization;

/** The location which the customer has entered.
 */
@property (strong, nonatomic) RVLocation *location;

/** The customer visiting the location.
 */
@property (strong, nonatomic) RVCustomer *customer;

/** All touchpoints at current location
 */
@property (strong, nonatomic) NSArray *touchpoints;

/** All touchpoints with trigger set to RVTouchpointTriggerAnyBeacon
 */
@property (nonatomic, readonly) NSSet *wildcardTouchpoints;

// _____ TODO:  private ____



@property (strong, nonatomic) NSDate *beaconLastDetectedAt;

/** The current touchpoints
 */
@property (strong, nonatomic) NSMutableSet *currentTouchpoints;

/** All visited touchpoints
 */
@property (nonatomic, readonly) NSArray *visitedTouchpoints;

/** All the image urls for this visit
 */
@property (nonatomic, readonly) NSArray *allImageUrls;

/** Valid regions for monitoring (i.e. touchpoints with a notification message
 */
@property (nonatomic, readonly) NSArray *observableRegions;

+ (instancetype)latestVisit;
+ (void)setLatestVisit:(RVVisit *)visit;
+ (void)clearLatestVisit;

- (BOOL)isInLocationRegion:(CLBeaconRegion *)beaconRegion;
- (BOOL)isInTouchpointRegion:(CLBeaconRegion *)beaconRegion;

- (RVTouchpoint *)touchpointForRegion:(CLBeaconRegion *)beaconRegion;
- (RVTouchpoint *)touchpointForMinor:(NSNumber *)minor;

- (void)addToCurrentTouchpoints:(RVTouchpoint *)touchpoint;
- (void)removeFromCurrentTouchpoints:(RVTouchpoint *)touchpoint;

- (void)postNewVisitCreatedNotification;

@end
