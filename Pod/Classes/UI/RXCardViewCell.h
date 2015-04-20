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

@interface RXCardViewCell : UITableViewCell

@property (nonatomic, weak) id<RXCardViewCellDelegate> delegate;
@property (nonatomic, readonly) UIView *containerView;
@property (nonatomic, weak) RVViewDefinition *viewDefinition;

@property (nonatomic, assign) UIEdgeInsets margins;

@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

- (void)addBlockView:(UIView *)blockView;

@end

@protocol RXCardViewCellDelegate <NSObject>

@optional
- (void)cardViewCellDidSwipe:(RXCardViewCell *)cardViewCell;
- (void)cardViewCellDidCancelSwipe:(RXCardViewCell *)cardViewCell;
- (BOOL)cardViewCell:(RXCardViewCell *)cell shouldOpenURL:(NSURL *)url;

@end