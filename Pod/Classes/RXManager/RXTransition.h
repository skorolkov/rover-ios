//
//  RXTransitionAnimator.h
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import <UIKit/UIKit.h>

@interface RXTransition : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, readwrite) id <UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak) UIViewController *parentViewController;

- (instancetype)initWithParentViewController:(UIViewController *)viewController;

- (void)cancelInteractiveTransitionWithDuration:(CGFloat)duration;
- (void)finishInteractiveTransitionWithDuration:(CGFloat)duration;


@end

