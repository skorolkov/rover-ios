//
//  Rover.h
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// Views
#import "RVCardView.h"
#import "RVCardBaseView.h"
#import "RVCardDeckView.h"
#import "RVCloseButton.h"
#import "RVModalView.h"

// Models
#import "RVModel.h"
#import "RVCustomer.h"
#import "RVVisit.h"
#import "RVCard.h"

// Controllers
#import "RVModalViewController.h"
#import "RVCardViewController.h"

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

/** This notification will be posted every time a new card is shown to the user. The card is available through the userInfo object.
 */
extern NSString *const kRoverDidDisplayCardNotification;

/** This notification will be posted every time the user swipes a card. The card is available through the userInfo object.
 */
extern NSString *const kRoverDidSwipeCardNotification;

@class RVConfig;

/** The Rover class it the primary interface to the SDK. All properties and methods are invoked on the class itself. There is no reason to instantiate a Rover instance.
 */
@interface Rover : NSObject <RVModalViewControllerDelegate>

/** Sets up the Rover framework with the configuration options for your app. You should call as soon as possible in your AppDelegate.
 */
+ (Rover *)setup:(RVConfig *)config;

/** The singleton instance of the Rover framework. You MUST call setup: before accessing this instance.
 */
+ (Rover *)shared;

/** After a customer enters a location a new RVVisit object will be retrieved from the Rover platform and can be accessed through this property.
 */
@property (readonly, strong, nonatomic) RVVisit *currentVisit;

/** The customer object. You can set the name, email and external customer ID for your customer and it will be persisted to the server on the next visit.
 */
@property (readonly, strong, nonatomic) RVCustomer *customer;

/** Retrieve a list of all cards the customer has saved.
 */
- (void)savedCards:(void (^)(NSArray *cards, NSString *error))block;

/** After the framework has been initialized call startMonitoring to begin monitoring for your beacons. You must call the setApplicationID:beaconUUIDs: method before you can start monitoring.
 */
- (void)startMonitoring;

/** If you need to stop monitoring for some reason, you can call the stop monitoring method.
 */
- (void)stopMonitoring;

/** Present the modal view controller.
 */
- (void)presentModal;

/** Present the modal view controller with a subset of cards. E.g. only show unread cards.
 */
- (void)presentModalForCardSet:(ModalViewCardSet)cardSet withOptions:(NSDictionary *)options;

/** You can use this method to simulate your app coming in range of a particular beacon.
 @warning **WARNING:** This method should only be used for testing purposes. Do not use in a production application.
 */
- (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major;

/** Convenience method to find the current view controller
 */

+ (UIViewController *)findCurrentViewController:(UIViewController *)vc;

@end



/** Contains all the configuration options used to initialize the Rover framework.
 */
@interface RVConfig : NSObject

/** The Application ID found on the settings page of the [Rover Admin Console](http://app.roverlabs.co/).
 */
@property (strong, nonatomic) NSString *applicationID;

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

/** Blur radius for the modal backdrop.
 */
@property (nonatomic) NSUInteger modalBackdropBlurRadius;

/** Tint color for the modal backdrop.
 */
@property (nonatomic, strong) UIColor *modalBackdropTintColor;

/** Don't change this.
 */
@property (strong, nonatomic) NSString *serverURL;

/** Create an RVConfig instance with the default values and override as necessary.
 */
+ (RVConfig *)defaultConfig;

/** Add a beacon UUID found on the settings page of the [Rover Admin Console](http://app.roverlabs.co/). Add a separate UUID for each organization your app is configured to serve content from. For the majority of applications there will only be one UUID.
 */
- (void)addBeaconUUID:(NSString *)UUIDString;

@end