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
@class CLBeaconRegion;

/** Represents a vist to a real-world physical location by a customer. A visit object will be created by the Rover Platform and delivered to the SDK when a customer enters a location.
 */
@interface RVVisit : RVModel

/** When the customer enters a location while their phone is asleep, the app should deliver a push notification. The welcomeMessage property should be used for the text property of the notification.
 */
@property (strong, nonatomic) NSString *welcomeMessage;

@property (strong, nonatomic) NSString *organizationName;
@property (strong, nonatomic) NSString *organizationId;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSString *locationAddress;

@property (strong, nonatomic) NSDate *beaconLastDetectedAt;

/** The location which the customer has entered.
 */
@property (strong, nonatomic) RVLocation *location;

/** The date and time the customer entered the location.
 */
@property (strong, nonatomic) NSDate *enteredAt;

/** The date and time the customer exited the location.
 */
@property (strong, nonatomic) NSDate *exitedAt;

/** The date and time the customer *first* opened the **app** during this visit. Note, this does not mean the customer viewed any of the cards.
 */
@property (strong, nonatomic) NSDate *openedAt;

/** Only the cards the customer has not viewed during *the current visit*. I.e. the customer may have seen these card before on a different visit but could still be unread for this visit.
 */
@property (readonly, nonatomic) NSArray *unreadCards;

/** Only the cards the customer has saved to their list. 
 */
@property (readonly, nonatomic) NSArray *savedCards;

/** All touchpoints at current location
 */
@property (strong, nonatomic) NSArray *touchpoints;

/** The current Touchpoint
 */
@property (strong, nonatomic) RVTouchpoint *currentTouchpoint;

/** All visited touchpoints
 */
@property (nonatomic, readonly) NSArray *visitedTouchpoints;

- (BOOL)isInRegion:(CLBeaconRegion *)beaconRegion;

- (void)persistToDefaults;

- (RVTouchpoint *)touchpointForRegion:(CLBeaconRegion *)beaconRegion;
- (RVTouchpoint *)touchpointForMinor:(NSNumber *)minor;



@end
