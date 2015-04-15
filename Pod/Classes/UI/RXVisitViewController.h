//
//  RXVisitViewController.h
//  Pods
//
//  Created by Ata Namvari on 2015-02-25.
//
//

#import <UIKit/UIKit.h>

/** This notification will be posted before the modal view controller is dismissed.
 */
extern NSString *const kRoverWillDismissModalNotification;

/** This notification will be posted after the modal view controller is dismissed.
 */
extern NSString *const kRoverDidDismissModalNotification;

/** This notification will be posted every time a new card is shown to the user. The card is available through the userInfo object.
 */
extern NSString *const kRoverDidDisplayCardNotification;

/** This notification will be posted every time the user swipes a card. The card is available through the userInfo object.
 */
extern NSString *const kRoverDidSwipeCardNotification;

/** This notification will be posted every time the user clicks a link (Button/Image) on a card.
 */
extern NSString *const kRoverDidClickCardNotification;



@class RVTouchpoint;
@class RXCardViewCell;
@class RVCard;

@interface RXVisitViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) NSArray *touchpoints;
//@property (nonatomic, readonly) RVVisitController *visitController;

- (RVCard *)cardAtIndexPath:(NSIndexPath *)indexPath;

- (void)willAddTouchpoint:(RVTouchpoint *)touchpoint;
- (void)didAddTouchpoint:(RVTouchpoint *)touchpoint;

@end



