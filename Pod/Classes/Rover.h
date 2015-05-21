//
//  Rover.h
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "RVConfig.h"
//#import "RoverDelegate.h"

// Core
#import "RVLog.h"
#import "RVRegionManager.h"
#import "RVVisitManager.h"

// Model
#import "RVModel.h"
#import "RVCustomer.h"
#import "RVVisit.h"
#import "RVCard.h"
#import "RVTouchpoint.h"
#import "RVLocation.h"
#import "RVOrganization.h"

// UI
#import "RXVisitViewController.h"
#import "RXDetailViewController.h"
#import "RXModalViewController.h"
#import "RXCardViewCell.h"
#import "RXBlockView.h"

// Networking
#import "RVNetworkingManager.h"
#import "RVImagePrefetcher.h"

// Experience
#import "RVRetailExperience.h" // for convenience
#import "RVSimpleExperience.h" // for convenience

@protocol RoverDelegate;

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

/** The Rover experience manager. An NSObject conforming to the RVExperienceManager protocol.
 */
@property (nonatomic, weak) id <RoverDelegate> delegate;

/** After a customer enters a location a new RVVisit object will be retrieved from the Rover platform and can be accessed through this property.
 */
@property (readonly, strong, nonatomic) RVVisit *currentVisit;

/** The customer object. You can set the name, email and external customer ID for your customer and it will be persisted to the server on the next visit.
 */
@property (readonly, strong, nonatomic) RVCustomer *customer;

/** A reference to the modal view controller if present. Returns nil if the modal is not currently presented.
 */
@property (nonatomic, readonly) UIViewController *modalViewController;

/** After the framework has been initialized call startMonitoring to begin monitoring for your beacons. You must call the setApplicationID:beaconUUIDs: method before you can start monitoring.
 */
- (void)startMonitoring;

/** If you need to stop monitoring for some reason, you can call the stop monitoring method.
 */
- (void)stopMonitoring;

/** Returns the configuration value for the given key.
 */
- (id)configValueForKey:(NSString *)key;

/** Convenience method to present a UILocalNotification.
 
 @param message The body of the UILocalNotification.
 */
- (void)presentLocalNotification:(NSString *)message;
 
/** Present the modal view controller.
 
 @param touchpoints An array of RVTouchpoint objects to display in the modal.
 */
- (void)presentModalWithTouchpoints:(NSArray *)touchpoints;

/** You can use this method to simulate your app coming in range of a particular beacon.
 @warning **WARNING:** This method should only be used for testing purposes. Do not use in a production application.
 */
- (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;

/** Convenience method to find the current view controller
 */
+ (UIViewController *)findCurrentViewController:(UIViewController *)vc;

@end

