//
//  RVTouchpoint.h
//  Pods
//
//  Created by Ata Namvari on 2014-12-23.
//
//

#import <Foundation/Foundation.h>
#import "RVModel.h"
#import "RVVisitController.h"

@class CLBeaconRegion;

typedef NS_ENUM(NSInteger, RVTouchpointTrigger) {
    RVTouchpointTriggerMinorNumber = 1,
    RVTouchpointTriggerVisit = 2
};

@interface RVTouchpoint : RVModel <RVVisitTouchpointInfo>

/** The trigger for the touchpoint. Could be one of RVTouchpointTriggerMinorNumber, RVTouchpointTriggerAnyBeacon, RVTouchpointTriggerGeofence.
 */
@property (nonatomic, assign) RVTouchpointTrigger trigger;

/** The minor number for the touchpoint
 */
@property (nonatomic, strong) NSNumber *minorNumber;

/** The notification for the touchpoint
 */
@property (nonatomic, strong) NSString *notification;

/** The title for the touchpoint
 */
@property (nonatomic, strong) NSString *title;

/** The cards for touchpoint
 */
@property (nonatomic, strong) NSArray *cards;

/** Returns YES if the CLBeaconRegion corresponds to this touchpoint. Returns NO if trigger type is RVTouchpointTriggerAnyBeacon.
 */
- (BOOL)isInRegion:(CLBeaconRegion *)beaconRegion;

/** Boolean flag indicating if the touchpoint has been engaged with during current visit.
 */
// TODO: should be readonly
@property (nonatomic, assign) BOOL isVisited;

/** Boolean flag indicating if the notification message has been sent for this touchpoint. You're responsible for setting this attributed if you manually deliver the notification (And also checking against to make sure not to send a notification twice).
 */
@property (nonatomic, assign) BOOL notificationDelivered;

@end


