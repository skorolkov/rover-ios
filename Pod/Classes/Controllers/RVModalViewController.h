//
//  RVModalViewController.h
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Defines the options for the view controller's card set property.
 */
typedef enum {
    /** Used to indicate the view controller should display all cards for the current visit.
     */
    ModalViewCardSetAll = 0,
    
    /** Used to indicate the view controller should display only cards the customer has saved to their list.
     */
    ModalViewCardSetSaved,
    
    /** Used to indicate the view controller should display only cards that the customer has not yet viewed.
     */
    ModalViewCardSetUnread
} ModalViewCardSet;

@protocol RVModalViewControllerDelegate;

/** The RVModalViewController is used to display the cards for the current visit. It displays the cards in a pseudo 3D stack. Each card can be swiped away to reveal the card below it. 
 
 Your app should instantiate and present this view controller when the customer enters a location. Your app will be notified when this occurs by subscribing to the kRoverDidEnterLocationNotification notification.
 
 This view controller contains a lot of useful functionality out of the box. By using the RVModalViewController you can get your app up and running with the Rover Platform quickly.
 */
@interface RVModalViewController : UIViewController

/** The view controller's delegate. You should assign your view controller that instantiated the RVModalViewController to this property in order to be notified of certain events in the controller's lifecycle.
 */
@property (weak, nonatomic) id <RVModalViewControllerDelegate> delegate;

/** The cardSet property determines which cards the RVModalViewController will display. The options are all cards, saved cards or unread cards. 
 @see ModalViewCardSet
 */
@property (nonatomic) ModalViewCardSet cardSet;

@end

/** Defines the delegate methods your app can implement in order to be notified of certain events during the view controller's lifecyle.
 */
@protocol RVModalViewControllerDelegate <NSObject>

/** This method will be called when the view controller has finished displaying all cards *or* was dismissed by the customer (by tapping the background). Your app should implement this method and remove the view controller from the display when it is called.
 */
- (void)modalViewControllerDidFinish:(RVModalViewController *)modalViewController;

@optional

/** This method will be called each time the customer swipes a card from the stack.
 */
- (void)modalViewController:(RVModalViewController *)modalViewController didSwipeCard:(RVCard *)card;

/** This method will be called each time the customer views a new card in the stack.
 */
- (void)modalViewController:(RVModalViewController *)modalViewController didDisplayCard:(RVCard *)card;

@end