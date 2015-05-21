//
//  RoverDelegate.h
//  Pods
//
//  Created by Ata Namvari on 2015-05-21.
//
//

#import <Foundation/Foundation.h>

@class RVVisit;
@class RVLocation;
@class RVCard;

@protocol RoverDelegate <NSObject>

@optional
/** Called when the user enters a location.
 */
- (void)roverVisit:(RVVisit *)visit didEnterLocation:(RVLocation *)location;

/** Called when the user enters a touchpoint.
 */
- (void)roverVisit:(RVVisit *)visit didEnterTouchpoints:(NSArray *)touchpoints;

/** Called when the user exits a touchpoint.
 */
- (void)roverVisit:(RVVisit *)visit didExitTouchpoints:(NSArray *)touchpoints;

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

/** Called when the application becomes active during a visit.
 */
- (void)applicationDidBecomeActiveDuringVisit:(RVVisit *)visit;

/** Called before the modal view controller is presented.
 */
- (void)roverWillDisplayModalViewController:(UIViewController *)modalViewController;

/** Called after the modal view controller is presented.
 */
- (void)roverDidDisplayModalViewController:(UIViewController *)modalViewController;

@end