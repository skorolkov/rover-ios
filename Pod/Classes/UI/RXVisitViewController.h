//
//  RXVisitViewController.h
//  Pods
//
//  Created by Ata Namvari on 2015-02-25.
//
//

#import <UIKit/UIKit.h>

@class RVDeck;
@class RXCardViewCell;
@class RVCard;
@protocol RXVisitViewControllerDelegate;

/** This is a base class to be used to display cards. For more control over the UI and presentation of the cards, subclass this class and register it
 as the modal view controller via the registerModalViewControllerClass method on RVConfig. If you would like to display this view controller manually,
 all you need to do is set an array decks. You can also add or remove decks dynamically via the addDecks: and removeDecks: methods.
 */
@interface RXVisitViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

/** Delegate that is notified of card and modal events.
 */
@property (nonatomic, weak) id <RXVisitViewControllerDelegate> delegate;

/** The underlying UITableView that displays the cards.
 */
@property (nonatomic, strong, readonly) UITableView *tableView;

/** The array of RVDecks to display.
 */
@property (nonatomic, strong) NSMutableArray *decks;

/** Returns the RVCard at indexPath. NSIndexPath.section being the touchpoint and NSIndexPath.row being the card index.
 */
- (RVCard *)cardAtIndexPath:(NSIndexPath *)indexPath;

/** Returns a filtered array of RVCard objects that have isDeleted set to NO.
 
 @param cards An NSArray of RVCard objects to filter.
 */
- (NSArray *)nonDeletedCardsFromCardsArray:(NSArray *)cards;

/** Adds an array of decks to the decks array.
 */
- (void)addDecks:(NSArray *)decks;

/** Removes an array of decks from the decks array.
 */
- (void)removeDecks:(NSArray *)decks;

/** Called before an array of decks is added.
 */
- (void)willAddDecks:(NSArray *)decks;

/** Called after the array of decks is added.
 */
- (void)didAddDecks:(NSArray *)decks;

/** Called before the array of decks is removed.
 */
- (void)willRemoveDecks:(NSArray *)decks;

/** Called after the array of decks is removed.
 */
- (void)didRemoveDecks:(NSArray *)decks;

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


