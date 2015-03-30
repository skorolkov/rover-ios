//
//  RXVisitViewController.h
//  Pods
//
//  Created by Ata Namvari on 2015-02-25.
//
//

#import <UIKit/UIKit.h>

@class RVVisitController;
@class RVTouchpoint;
@class RXCardViewCell;

@interface RXVisitViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, readonly) RVVisitController *visitController;

- (void)willAddTouchpoint:(RVTouchpoint *)touchpoint;
- (void)didAddTouchpoint:(RVTouchpoint *)touchpoint;

@end



