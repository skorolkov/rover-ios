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

@interface RXVisitViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <RXVisitViewControllerDelegate> delegate;
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) NSArray *touchpoints;

- (RVCard *)cardAtIndexPath:(NSIndexPath *)indexPath;

- (void)addTouchpoint:(RVTouchpoint *)touchpoint;

- (void)willAddTouchpoint:(RVTouchpoint *)touchpoint;
- (void)didAddTouchpoint:(RVTouchpoint *)touchpoint;

@end


@protocol RXVisitViewControllerDelegate <NSObject>

@optional
- (void)visitViewController:(RXVisitViewController *)viewController didDisplayCard:(RVCard *)card;
- (void)visitViewController:(RXVisitViewController *)viewController didDiscardCard:(RVCard *)card;
- (void)visitViewController:(RXVisitViewController *)viewController didClickCard:(RVCard *)card URL:(NSURL *)url;

- (void)visitViewControllerWillGetDismissed:(RXVisitViewController *)viewController;
- (void)visitViewControllerDidGetDismissed:(RXVisitViewController *)viewController;

@end


