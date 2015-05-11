//
//  RXVisitViewController.h
//  Pods
//
//  Created by Ata Namvari on 2015-02-25.
//
//

#import <UIKit/UIKit.h>

@class RVTouchpoint;
@class RXCardViewCell;
@class RVCard;
@protocol RXVisitViewControllerDelegate;

/** This is a base class to be used to display cards. For more control over the UI and presentation of the cards, subclass this class and register it
 as the modal view controller via the registerModalViewControllerClass method on RVConfig. If you would like to display this view controller manually,
 all you need to do is set an array touchpoints. You can also add or remove touchpoints dynamically via the addTouchpoint: and removeTouchpoint: methods.
 */
@interface RXVisitViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

/** Delegate that is notified of card and modal events.
 */
@property (nonatomic, weak) id <RXVisitViewControllerDelegate> delegate;

/** The underlying UITableView that displays the cards.
 */
@property (nonatomic, strong, readonly) UITableView *tableView;

/** The array of RVTouchpoints to display.
 */
@property (nonatomic, strong) NSMutableArray *touchpoints;

/** Returns the RVCard at indexPath. NSIndexPath.section being the touchpoint and NSIndexPath.row being the card index.
 */
- (RVCard *)cardAtIndexPath:(NSIndexPath *)indexPath;

/** Adds a touchpoint to the touchpoints array.
 */
- (void)addTouchpoint:(RVTouchpoint *)touchpoint;

/** Removes a touchpoint from the touchpoints array.
 */
- (void)removeTouchpoint:(RVTouchpoint *)touchpoint;

/** Called before a touchpoint is added.
 */
- (void)willAddTouchpoint:(RVTouchpoint *)touchpoint;

/** Called after the touchpoint is added.
 */
- (void)didAddTouchpoint:(RVTouchpoint *)touchpoint;

/** Called before the touchpoint is removed.
 */
- (void)willRemoveTouchpoint:(RVTouchpoint *)touchpoint;

/** Called after the touchpoint is removed.
 */
- (void)didRemoveTouchpoint:(RVTouchpoint *)touchpoint;

@end


@protocol RXVisitViewControllerDelegate <NSObject>

@optional

/** Called when an RVCard is displayed for the first time.
 */
- (void)visitViewController:(RXVisitViewController *)viewController didDisplayCard:(RVCard *)card;

/** Called when an RVCard is dismissed.
 */
- (void)visitViewController:(RXVisitViewController *)viewController didDiscardCard:(RVCard *)card;

/** Called when an RVCard is clicked.
 */
- (void)visitViewController:(RXVisitViewController *)viewController didClickCard:(RVCard *)card URL:(NSURL *)url;

/** Called before the view controller is dismissed.
 */
- (void)visitViewControllerWillGetDismissed:(RXVisitViewController *)viewController;

/** Called after the view controller has been dismissed.
 */
- (void)visitViewControllerDidGetDismissed:(RXVisitViewController *)viewController;

@end


