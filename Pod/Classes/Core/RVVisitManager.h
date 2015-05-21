//
//  RVVisitManager.h
//  Rover
//
//  Created by Sean Rucker on 2014-07-29.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RVVisit;
@class RVLocation;
@class RVTouchpoint;
@class RVRegionManager;
@protocol RVVisitManagerDelegate;

/** This class does the heavy lifting of managing a journey through beacon regions.
 */
@interface RVVisitManager : NSObject

/** Delegate that gets notified of location and touchpoint events.
 */
@property (nonatomic, weak) NSObject <RVVisitManagerDelegate> *delegate;

/** The region manager that is responsible for monitoring and ranging for beacons.
 */
@property (strong, nonatomic, readonly) RVRegionManager *regionManager;

/** The latest visit object seen by the visit manager.
 */
@property (strong, nonatomic, readonly) RVVisit *latestVisit;

@end

@protocol RVVisitManagerDelegate <NSObject>

@optional
/** Called before the a visit is created. Return NO to prevent the visit from being created.
 This is a good place to change any values on the visit object. (i.e. post to server)
 
 @warning This method is NOT called on the main thread. You should refrain from making UI changes in this method.
 If you absolutely must, make sure your code is wrapped around a dispatch call that executes on the main queue.
 
 @param manager The visit manager instance thats calling the delegate method.
 @param visit The visit instance that is to be created.
 */
- (BOOL)visitManager:(RVVisitManager *)manager shouldCreateVisit:(RVVisit *)visit;

/** Called when the user enters the location.
 
 @param manager The visit manager instance thats calling the delegate method.
 @param location The location that was just entered.
 @param visit The visit instance assocciated with user's visit to this location.
 */
- (void)visitManager:(RVVisitManager *)manager didEnterLocation:(RVLocation *)location visit:(RVVisit *)visit;

/** Called when the user is no longer in range of any beacons.
 
 @param manager The visit manager instance thats calling the delegate method.
 @param location The location that was potentially exited.
 @param visit The visit instance assocciated with the user's potential exit.
 */
- (void)visitManager:(RVVisitManager *)manager didPotentiallyExitLocation:(RVLocation *)location visit:(RVVisit *)visit;

/** Called when the user has not been in range of any beacons for `visit.keepAlive` minutes.
 
 @param manager The visit manager instance thats calling the delegate method.
 @param visit The visit instance assocciated with the user's expired visit.
 */
- (void)visitManager:(RVVisitManager *)manager didExpireVisit:(RVVisit *)visit;

/** Called when the user enters a touchpoint.
 
 @param manager The visit manager instance thats calling the delegate method.
 @param touchpoints An NSArray of RVTouchpoints the user entered.
 @param visit The visit instance assocciated with the user's enter touchpoint event.
 */
- (void)visitManager:(RVVisitManager *)manager didEnterTouchpoints:(NSArray *)touchpoints visit:(RVVisit *)visit;

/** Called when the user exits a touchpoint.
 
 @param manager The visit manager instance thats calling the delegate method.
 @param touchpoints An NSArray of RVTouchpoints the user exited.
 @param visit The visit instance assocciated with the user's exit touchpoint event.
 */
- (void)visitManager:(RVVisitManager *)manager didExitTouchpoints:(NSArray *)touchpoints visit:(RVVisit *)visit;

@end
