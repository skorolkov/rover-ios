//
//  Rover.h
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// Models
#import "RVModel.h"
#import "RVCustomer.h"
#import "RVVisit.h"
#import "RVCard.h"
#import "RVTouchpoint.h"
#import "RVNotifications.h"

// Controllers
#import "RVVisitController.h"




@class RVConfig;

/** The Rover class it the primary interface to the SDK. All properties and methods are invoked on the class itself. There is no reason to instantiate a Rover instance.
 */
@interface Rover : NSObject

/** Sets up the Rover framework with the configuration options for your app. You should call as soon as possible in your AppDelegate.
 */
+ (Rover *)setup:(RVConfig *)config;

/** The singleton instance of the Rover framework. You MUST call setup: before accessing this instance.
 */
+ (Rover *)shared;

/** A boolean flag indicating weather user is currently visiting one of your locations.
 */
@property (nonatomic, readonly) BOOL isCurrentlyVisiting;

/** After a customer enters a location a new RVVisit object will be retrieved from the Rover platform and can be accessed through this property.
 */
@property (readonly, strong, nonatomic) RVVisit *currentVisit DEPRECATED_ATTRIBUTE;

/** The customer object. You can set the name, email and external customer ID for your customer and it will be persisted to the server on the next visit.
 */
@property (readonly, strong, nonatomic) RVCustomer *customer;

/** After the framework has been initialized call startMonitoring to begin monitoring for your beacons. You must call the setApplicationID:beaconUUIDs: method before you can start monitoring.
 */
- (void)startMonitoring;

/** If you need to stop monitoring for some reason, you can call the stop monitoring method.
 */
- (void)stopMonitoring;

/** Returns the configuration value for the given key.
 */
- (id)configValueForKey:(NSString *)key;

/** Present the modal view controller.
 */
- (void)presentModal;

/** Present the modal view controller with a subset of cards. E.g. only show unread cards.
 */
//- (void)presentModalForCardSet:(ModalViewCardSet)cardSet withOptions:(NSDictionary *)options;

/** You can use this method to simulate your app coming in range of a particular beacon.
 @warning **WARNING:** This method should only be used for testing purposes. Do not use in a production application.
 */
- (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;

/** Convenience method to find the current view controller
 */

+ (UIViewController *)findCurrentViewController:(UIViewController *)vc;

@end



/** Contains all the configuration options used to initialize the Rover framework.
 */
@interface RVConfig : NSObject

/** Use the addBeaconUUID: to add a beacon uuid to this array.
 */
@property (strong, nonatomic, readonly) NSArray *beaconUUIDs;

/** Set the notification types required for the app (optional). This value defaults to badge, alert and sound, so it's only necessary to set it if you want to add or remove types.
 */
@property (nonatomic) UIUserNotificationType allowedUserNotificationTypes;

/** The sound used for notifications. By default this is set to UILocalNotificationDefaultSoundName.
 */
@property (nonatomic, copy) NSString *notificationSoundName;

/** Indicates whether Rover should automatically display the modal dialog when the customer visits a location. The default value is YES.
 */
@property (nonatomic) BOOL autoPresentModal;

/** Sandbox mode. Visits will not be tracked when set to YES.
 */
@property (nonatomic, assign) BOOL sandboxMode;

/** Register a UIViewController subclass to launch on RoverDidEnterLocationNotification.
 */
@property (nonatomic, strong, setter=registerModalViewControllerClass:) Class modalViewControllerClass;

/** Create an RVConfig instance with the default values and override as necessary.
 */
+ (RVConfig *)defaultConfig;

/** Add a beacon UUID found on the settings page of the [Rover Admin Console](http://app.roverlabs.co/). Add a separate UUID for each organization your app is configured to serve content from. For the majority of applications there will only be one UUID.
 */
- (void)addBeaconUUID:(NSString *)UUIDString;


@end