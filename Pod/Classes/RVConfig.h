//
//  RVConfig.h
//  Pods
//
//  Created by Ata Namvari on 2015-04-15.
//
//

@import UIKit;

typedef NS_ENUM(NSInteger, RVExperience) {
    RVExperienceSimple,
    RVExperienceRetail
};

/** Contains all the configuration options used to initialize the Rover framework.
 */
@interface RVConfig : NSObject

/** The Application Token found on the settings page of the [Rover Admin Console](http://app.roverlabs.co/).
 */
@property (strong, nonatomic) NSString *applicationToken;

/** Use the addBeaconUUID: to add a beacon uuid to this array.
 */
@property (strong, nonatomic, readonly) NSArray *beaconUUIDs;

/** Set the notification types required for the app (optional). This value defaults to badge, alert and sound, so it's only necessary to set it if you want to add or remove types.
 */
@property (nonatomic) UIUserNotificationType allowedUserNotificationTypes;

/** The sound used for notifications. By default this is set to UILocalNotificationDefaultSoundName.
 */
@property (nonatomic, copy) NSString *notificationSoundName;

/** Blur radius for the modal backdrop.
 */
@property (nonatomic) NSUInteger modalBackdropBlurRadius;

/** Tint color for the modal backdrop.
 */
@property (nonatomic, strong) UIColor *modalBackdropTintColor;

/** Don't change this.
 */
@property (strong, nonatomic) NSString *serverURL;

/** Sandbox mode. Visits will not be tracked when set to YES.
 */
@property (nonatomic, assign) BOOL sandboxMode;

/** Register a UIViewController subclass to launch on RoverDidEnterLocationNotification.
 */
@property (nonatomic, strong, setter=registerModalViewControllerClass:) Class modalViewControllerClass;

/** The experience to use when in proximity.
 */
@property (nonatomic, assign) RVExperience experience;

/** Create an RVConfig instance with the default values and override as necessary.
 */
+ (RVConfig *)defaultConfig;

/** Add a beacon UUID found on the settings page of the [Rover Admin Console](http://app.roverlabs.co/). Add a separate UUID for each organization your app is configured to serve content from. For the majority of applications there will only be one UUID.
 */
- (void)addBeaconUUID:(NSString *)UUIDString;


@end