//
//  RVVisitManager.h
//  Rover
//
//  Created by Sean Rucker on 2014-07-29.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString *const kRVVisitManagerDidEnterLocationNotification;
//extern NSString *const kRVVisitManagerDidPotentiallyExitLocationNotification;
//extern NSString *const kRVVisitManagerDidExpireVisitNotification;
//extern NSString *const kRVVisitManagerDidEnterTouchpointNotification;
//extern NSString *const kRVVisitManagerDidExitTouchpointNotification;

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

@class RVVisit;

@interface RVVisitManager : NSObject

+ (id)sharedManager;

@property (strong, nonatomic, readonly) RVVisit *latestVisit;

@end