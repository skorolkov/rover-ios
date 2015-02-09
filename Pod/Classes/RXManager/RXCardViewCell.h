//
//  RXCardViewCell.h
//  Pods
//
//  Created by Ata Namvari on 2015-01-12.
//
//

#import <UIKit/UIKit.h>

@protocol RXCardViewCellDelegate;
@class RVCard;

@interface RXCardViewCell : UITableViewCell

@property (nonatomic, weak) id<RXCardViewCellDelegate> delegate;
@property (nonatomic, readonly) UIView *containerView;
@property (nonatomic, weak) RVCard *card;

@end

@protocol RXCardViewCellDelegate <NSObject>

@optional
- (void)cardViewCellDidSwipe:(RXCardViewCell *)cardViewCell;
- (void)cardViewCellDidCancelSwipe:(RXCardViewCell *)cardViewCell;

@end