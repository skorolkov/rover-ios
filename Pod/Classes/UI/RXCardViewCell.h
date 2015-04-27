//
//  RXCardViewCell.h
//  Pods
//
//  Created by Ata Namvari on 2015-01-12.
//
//

#import <UIKit/UIKit.h>

@class RVViewDefinition;

@protocol RXCardViewCellDelegate;

/** A UITableViewCell subclass responsible for displaying the content of cards.
 */
@interface RXCardViewCell : UITableViewCell

/** Delegate that gets notified of card events.
 */
@property (nonatomic, weak) id<RXCardViewCellDelegate> delegate;

/** The UIView containing all the RXBlockViews.
 */
@property (nonatomic, readonly) UIView *containerView;

/** The RVViewDefinition used to build the view.
 */
@property (nonatomic, weak) RVViewDefinition *viewDefinition;

/** Margins around the `contianerView`.
 */
@property (nonatomic, assign) UIEdgeInsets margins;

/** The UIPanGestureRecognizer used to swipe cards. This UIGestureRecognizer is attached to the `containerView`.
 */
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

/** Method to add UIViews to the card.
 */
- (void)addBlockView:(UIView *)blockView;

@end

@protocol RXCardViewCellDelegate <NSObject>

@optional

/** Called when user swipes the card.
 */
- (void)cardViewCellDidSwipe:(RXCardViewCell *)cardViewCell;

/** Called when the user cancels the swipe.
 */
- (void)cardViewCellDidCancelSwipe:(RXCardViewCell *)cardViewCell;

/** Called when the user clicks on the card.
 If NO is returned, nothing happens. If YES is returned [[UIApplication sharedApplication] openURL:url] is performed.
 
 @param url The NSURL to follow.
 */
- (BOOL)cardViewCell:(RXCardViewCell *)cell shouldOpenURL:(NSURL *)url;

@end