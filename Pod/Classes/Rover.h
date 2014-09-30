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
#import "RVCard.h"
#import "RVVisit.h"

// Controllers
#import "RVModalViewController.h"
#import "RVCardViewController.h"

/** This notification will be posted when the customer enters a location.
 */
extern NSString *const kRoverDidEnterLocationNotification;

/** The Rover class it the primary interface to the SDK. All properties and methods are invoked on the class itself. There is no reason to instantiate a Rover instance.
 */
@interface Rover : NSObject

/** Initialize the Rover framework with the Application ID and Beacon UUID found on the settings page of the [Rover Marketing Console](http://app.roverlabs.co/).
The beaconUUIDs array should contain a uniuqe UUID for each organization your app is configured to serve content from. For the majority of applications there will only be one UUID.
 */
+ (void)setApplicationID:(NSString *)applicationID beaconUUIDs:(NSArray *)UUIDs;

/** After a customer enters a location a new RVVisit object will be retrieved from the Rover platform and can be accessed through this property.
 */
+ (RVVisit *)currentVisit;

/** You can use this property to uniquely identify your customers. The customer represents the current user of your application. If you do not set this property a unique ID will be automatically generated for you.
 */
+ (void)setCustomerID:(NSString *)customerID;

/** You can set additional properties of your customer, such as name and email, by loading the customer object. After setting properties on the customer object, you should call the save method to persist those properties to the Marketing Console.
 */
+ (void)getCustomer:(void (^)(RVCustomer *customer, NSString *error))block;

/** Retrieve a list of all cards the customer has saved.
 */
+ (void)getCards:(void (^)(NSArray *cards, NSString *error))block;

/** After the framework has been initialized call startMonitoring to begin monitoring for your beacons. You must call the setApplicationID:beaconUUIDs: method before you can start monitoring.
 */
+ (void)startMonitoring;

/** If you need to stop monitoring for some reason, you can call the stop monitoring method.
 */
+ (void)stopMonitoring;

/** You can use this method to simulate your app coming in range of a particular beacon.
 @warning **WARNING:** This method should only be used for testing purposes. Do not use in a production application.
 */
+ (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major;

@end
