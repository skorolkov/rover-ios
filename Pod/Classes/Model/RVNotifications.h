//
//  RVNotifications.h
//  Pods
//
//  Created by Ata Namvari on 2015-04-08.
//
//

/** This notification will be posted when there are no more beacons in range.
 */

extern NSString *const kRoverDidPotentiallyExitLocationNotification;

/** This notification will be posted when the customer's visit has expired. A visit expires if no beacons are detected for keepAlive time after the kRoverDidPotentiallyExitLocationNotification notification.
 */

extern NSString *const kRoverDidExpireVisitNotification;

/** This notification will be posted when the customer exits a touchpoint region.
 */
extern NSString *const kRoverDidExitTouchpointNotification;

/** This notification will be posted when the customer enters a touchpoint region.
 */
extern NSString *const kRoverDidEnterTouchpointNotification;

/** This notification will be posted when the customer enters a location.
 */
extern NSString *const kRoverDidEnterLocationNotification;

/** This notification will be posted before the modal view controller is presented.
 */
extern NSString *const kRoverWillPresentModalNotification;

/** This notification will be posted after the modal view controller is presented.
 */
extern NSString *const kRoverDidPresentModalNotification;

/** This notification will be posted before the modal view controller is dismissed.
 */
extern NSString *const kRoverWillDismissModalNotification;

/** This notification will be posted after the modal view controller is dismissed.
 */
extern NSString *const kRoverDidDismissModalNotification;



