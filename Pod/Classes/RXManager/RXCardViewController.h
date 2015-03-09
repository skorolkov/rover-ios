//
//  RXCardViewController.h
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import <UIKit/UIKit.h>

@class RVViewDefinition;

@interface RXCardViewController : UIViewController

@property (nonatomic, weak) RVViewDefinition *viewDefinition;
@property (readonly) UIScrollView *scrollView;
@property (readonly) UIView *containerView;
@property (readonly) UIView *titleBar;

- (instancetype)initWithViewDefinition:(RVViewDefinition *)viewDefinition;

- (void)prepareLayoutForTransition;
- (void)prepareLayoutForInteractiveTransition:(CGFloat)percentageComplete;
- (void)resetLayout ;

@end
