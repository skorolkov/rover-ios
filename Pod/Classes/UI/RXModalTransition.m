//
//  RXModalTransition.m
//  Pods
//
//  Created by Ata Namvari on 2015-06-04.
//
//

#import "RXModalTransition.h"
#import "RXModalViewController.h"

@implementation RXModalTransition

#pragma mark - UIViewControllerTransioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    RXModalViewController *modalViewController = (RXModalViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    return modalViewController.tableView.visibleCells.count * 1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    RXModalViewController *modalViewController = (RXModalViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    NSInteger count = modalViewController.tableView.visibleCells.count;
    
    [modalViewController.tableView.visibleCells enumerateObjectsUsingBlock:^(UITableViewCell *cell, NSUInteger idx, BOOL *stop) {
        [UIView animateWithDuration:.5
                              delay:((count - 1 - idx) * .1)
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             cell.transform = CGAffineTransformMakeTranslation(0, modalViewController.view.frame.size.height + 50);
                         }
                         completion:nil];
    }];
    
    [UIView animateWithDuration:((count - 1) * .1) + .5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         modalViewController.backgroundImageView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
    
    [UIView animateWithDuration:.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         modalViewController.tableView.tableFooterView.alpha = 0;
                     } completion:nil];
}

@end
