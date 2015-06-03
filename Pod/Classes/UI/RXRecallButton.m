//
//  RXRecallButton.m
//  Pods
//
//  Created by Ata Namvari on 2015-06-02.
//
//

#import "RXRecallButton.h"
#import "RXCardsIcon.h"

@implementation RXRecallButton

- (instancetype)init {
    return [self initWithInitialPosition:RXRecallButtonPositionBottomRight];
}

- (instancetype)initWithInitialPosition:(RXRecallButtonPosition)position {
    RXCardsIcon *view = [[RXCardsIcon alloc] initWithFrame:CGRectMake(12, 12, 38, 38)];
    return [self initWithCustomView:view initialPosition:position];
}

- (instancetype)initWithCustomView:(UIView *)view initialPosition:(RXRecallButtonPosition)position {
    self = [self initWithFrame:CGRectMake(0, 0, 64, 64)];
    if (self) {
        self.center = [self tuckedPositionForCorner:position];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = .5;
        self.layer.shadowRadius = 4;
        
        [self addSubview:view];
    }
    return self;
}

#pragma mark - Helpers

- (CGPoint)tuckedPositionForCorner:(RXRecallButtonPosition)corner {
    UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
    
    switch (corner) {
        case RXRecallButtonPositionBottomRight:
            return CGPointMake(currentWindow.frame.size.width - 64, currentWindow.frame.size.height + 32 + 5);
        case RXRecallButtonPositionBottomLeft:
            return CGPointMake(64, currentWindow.frame.size.height + 32 + 5);
        case RXRecallButtonPositionTopLeft:
            return CGPointMake(64, - 32 - 5);
        case RXRecallButtonPositionTopRight:
            return CGPointMake(currentWindow.frame.size.width - 64, - 32 - 5);
    }
}

#pragma mark - Instance Methods

- (void)hide:(BOOL)animated completion:(void (^)())completion {
    CGPoint center;
    
    switch (self.anchoredEdge) {
        case RXDraggableEdgeTop:
            center = CGPointMake(self.center.x, - (self.frame.size.height / 2) - self.layer.shadowRadius - 1);
            break;
        case RXDraggableEdgeBottom:
            center = CGPointMake(self.center.x, self.superview.frame.size.height + (self.frame.size.height / 2) +  self.layer.shadowRadius + 1);
            break;
        case RXDraggableEdgeRight:
            center = CGPointMake(self.superview.frame.size.width + self.frame.size.width + self.layer.shadowRadius + 1, self.center.y);
            break;
        case RXDraggableEdgeLeft:
            center = CGPointMake(- (self.frame.size.width / 2) - self.layer.shadowRadius - 1, self.center.y);
            break;
    }
    
    NSTimeInterval duration = animated ? .3 : 0;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.center = center;
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)show:(BOOL)animated completion:(void (^)())completion {
    UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (!self.superview) {
        [currentWindow addSubview:self];
    }
    
    CGPoint point = [self snapPointToClosestEdgeFromPoint:self.center offset:UIOffsetZero];

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = animated ? .5 : 0;
    animation.fromValue = [NSValue valueWithCGPoint:self.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:point];
    animation.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:.7 :4/22.f :7/22.f :1];
    
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            if (completion) {
                completion();
            }
        }];
        [self.layer addAnimation:animation forKey:@"up"];
        self.layer.position = point;
    } [CATransaction commit];
}

@end
