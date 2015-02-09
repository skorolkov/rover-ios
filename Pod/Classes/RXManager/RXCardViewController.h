//
//  RXCardViewController.h
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import <UIKit/UIKit.h>

@class RVCard;

@interface RXCardViewController : UIViewController

@property (nonatomic, weak) RVCard *card;
@property (readonly) UIScrollView *scrollView;
@property (readonly) UIView *containerView;
@property (readonly) UIView *titleBar;

- (instancetype)initWithCard:(RVCard *)card;

- (void)prepareLayoutForTransition;
- (void)prepareLayoutForInteractiveTransition:(CGFloat)percentageComplete;
- (void)resetLayout ;

@end
