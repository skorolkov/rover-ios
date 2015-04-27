//
//  Rover.h
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "RVConfig.h"

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


/** This notification will be posted before the modal view controller is presented.
 */
extern NSString *const kRoverWillPresentModalNotification;

/** This notification will be posted after the modal view controller is presented.
 */
extern NSString *const kRoverDidPresentModalNotification;


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

/** The Rover delegate.
 */
@property (nonatomic, weak) id <RoverDelegate> delegate;

/** After a customer enters a location a new RVVisit object will be retrieved from the Rover platform and can be accessed through this property.
 */
@property (readonly, strong, nonatomic) RVVisit *currentVisit;

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

/** You can use this method to simulate your app coming in range of a particular beacon.
 @warning **WARNING:** This method should only be used for testing purposes. Do not use in a production application.
 */
- (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;

/** Convenience method to find the current view controller
 */
+ (UIViewController *)findCurrentViewController:(UIViewController *)vc;

@end


@protocol RoverDelegate <NSObject>

@optional
/** Called when the user enters a location.
 */
- (void)roverVisit:(RVVisit *)visit didEnterLocation:(RVLocation *)location;

/** Called when the user enters a touchpoint.
 */
- (void)roverVisit:(RVVisit *)visit didEnterTouchpoint:(RVTouchpoint *)touchpoint;

/** Called when the user exits a touchpoint.
 */
- (void)roverVisit:(RVVisit *)visit didExitTouchpoint:(RVTouchpoint *)touchpoint;

/** Called when the user is no longer in range of any beacons.
 */
- (void)roverVisit:(RVVisit *)visit didPotentiallyExitLocation:(RVLocation *)location aliveForAnother:(NSTimeInterval)keepAlive;

/** Called when the user has not been in range of any beacons for `keepAlive` minutes.
 */
- (void)roverVisitDidExpire:(RVVisit *)visit;

/** Called before the `roverVisit:didEnterLocation:` delegate. At this point you have a chance to prevent the visit from registering. You can also alter the visit object if need be.
 */
- (BOOL)roverShouldCreateVisit:(RVVisit *)visit;

/** Called after `roverShouldCreateVisit:` and if the visit is registered successfully with the Rover platform. This method isn't called if `roverShouldCreateVisit:` returns NO.
 */
- (void)roverDidCreateVisit:(RVVisit *)visit;

/** Called once a card is displayed for the first time.
 */
- (void)roverVisit:(RVVisit *)visit didDisplayCard:(RVCard *)card;

/** Called when card is discarded.
 */
- (void)roverVisit:(RVVisit *)visit didDiscardCard:(RVCard *)card;

/** Called when a card is clicked.
 */
- (void)roverVisit:(RVVisit *)visit didClickCard:(RVCard *)card withURL:(NSURL *)url;

/** Called before the modal view controller is presented.
 */
- (void)roverWillDisplayModalViewController;

/** Called after the modal view controller is presented.
 */
- (void)roverDidDisplayModalViewController;

@end

