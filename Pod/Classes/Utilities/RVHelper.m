//
//  RVHelper.m
//  Pods
//
//  Created by Ata Namvari on 2014-11-13.
//
//

#import "RVHelper.h"
#import "RVCardView.h"

@implementation RVHelper

+ (void)showMessage:(NSString *)message holdFor:(NSTimeInterval)seconds delay:(NSTimeInterval)delay duration:(NSTimeInterval)duration
{
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    
    UIView *messageContainer = [[UIView alloc] initWithFrame:CGRectMake(0, mainWindow.frame.size.height - 40, mainWindow.frame.size.width, 50)];
    messageContainer.alpha = 0;
    
    UIView *messageBackgroundView = [[UIView alloc] initWithFrame:messageContainer.bounds];
    messageBackgroundView.backgroundColor = [UIColor blackColor];
    messageBackgroundView.alpha = 0.5;
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, messageContainer.bounds.size.width, 40)];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = [UIFont systemFontOfSize:18];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = message;
    
    [messageContainer addSubview:messageBackgroundView];
    [messageContainer addSubview:messageLabel];
    [mainWindow addSubview:messageContainer];
    
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         messageContainer.alpha = 1;
                         messageContainer.layer.transform = CATransform3DMakeTranslation(0, -10, 0);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.5 delay:seconds options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              messageContainer.alpha = 0;
                                          } completion:^(BOOL finished) {
                                              [messageContainer removeFromSuperview];
                                          }];
                     }];
    
}

+ (void)displaySwipeTutorialWithCardView:(RVCardView *)cardView completion:( void (^)(BOOL finished) )completion
{
    [UIView animateWithDuration:.4 delay:0.7 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cardView.layer.transform = CATransform3DConcat(CATransform3DMakeTranslation(30, 5, 0), CATransform3DMakeRotation(-0.05, 0, 0, 1));
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.5 delay:.77 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              cardView.layer.transform = CATransform3DIdentity;
                                          } completion:^(BOOL finished) {
                                              if (completion) {
                                                  completion(finished);
                                              }
                                          }];
                     }];
}

+ (void)displayTapTutorialAnimationAtPoint:(CGPoint)point completion:( void (^)(BOOL finished))completion
{
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(-34, point.y - 50, 34, 34)];
    circleView.backgroundColor = [UIColor blackColor];
    circleView.alpha = .5;
    circleView.layer.cornerRadius = 17;
    circleView.layer.borderWidth = 2;
    circleView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    [mainWindow addSubview:circleView];
    
    [UIView animateWithDuration:.3 delay:.1 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         circleView.frame = CGRectMake(point.x - 17, point.y - 17, 34, 34);
                     } completion:^(BOOL finished) {
                         
                         CABasicAnimation *shrinkRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
                         shrinkRadiusAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                         shrinkRadiusAnimation.fromValue = [NSNumber numberWithInt:17];
                         shrinkRadiusAnimation.toValue = [NSNumber numberWithInt:12];
                         shrinkRadiusAnimation.duration = .17;
                         shrinkRadiusAnimation.beginTime = CACurrentMediaTime() - .2;
                         
                         CABasicAnimation *shrinkFrameAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
                         shrinkFrameAnimation.fromValue = [NSValue valueWithCGRect:circleView.frame];
                         shrinkFrameAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 24, 24)];
                         shrinkFrameAnimation.timingFunction = shrinkRadiusAnimation.timingFunction;
                         shrinkFrameAnimation.duration = shrinkRadiusAnimation.duration;
                         shrinkFrameAnimation.beginTime = shrinkRadiusAnimation.beginTime;
                         
                         CABasicAnimation *expandRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
                         expandRadiusAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                         expandRadiusAnimation.fromValue = shrinkRadiusAnimation.toValue;
                         expandRadiusAnimation.toValue = [NSNumber numberWithInt:40];
                         expandRadiusAnimation.duration = .24;
                         
                         CABasicAnimation *expandFrameAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
                         expandFrameAnimation.fromValue = shrinkFrameAnimation.toValue;
                         expandFrameAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 80, 80)];
                         expandFrameAnimation.duration = expandRadiusAnimation.duration;
                         expandFrameAnimation.timingFunction = expandRadiusAnimation.timingFunction;
                         
                         CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                         fadeAnimation.duration = expandRadiusAnimation.duration;
                         fadeAnimation.timingFunction = expandRadiusAnimation.timingFunction;
                         fadeAnimation.fromValue = [NSNumber numberWithFloat:circleView.alpha];
                         fadeAnimation.toValue = [NSNumber numberWithFloat:0];
                         
                         [CATransaction begin]; {
                             
                             [CATransaction setCompletionBlock:^{
                                 circleView.bounds = [shrinkFrameAnimation.toValue CGRectValue];
                                 circleView.layer.cornerRadius = [shrinkRadiusAnimation.toValue floatValue];
                                 
                                 [CATransaction begin]; {
                                     [CATransaction setCompletionBlock:^{
                                         [circleView removeFromSuperview];
                                         
                                         if (completion) {
                                             completion(YES);
                                         }
                                     }];
                                     
                                     [circleView.layer addAnimation:expandRadiusAnimation forKey:@"expandRadius"];
                                     [circleView.layer addAnimation:expandFrameAnimation forKey:@"expandBounds"];
                                     [circleView.layer addAnimation:fadeAnimation forKey:@"fade"];
                                     circleView.bounds = [expandFrameAnimation.toValue CGRectValue];
                                     circleView.layer.cornerRadius = [expandRadiusAnimation.toValue floatValue];
                                     circleView.layer.opacity = [fadeAnimation.toValue floatValue];
                                 } [CATransaction commit];
                             }];
                             
                             [circleView.layer addAnimation:shrinkRadiusAnimation forKey:@"cornerRadius"];
                             [circleView.layer addAnimation:shrinkFrameAnimation forKey:@"frameAnimation"];
                         } [CATransaction commit];
                         
                     }];
}

@end
