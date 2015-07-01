//
//  RXRecallButton.m
//  Pods
//
//  Created by Ata Namvari on 2015-06-02.
//
//

#import "RXRecallButton.h"
#import "RXCardsIcon.h"

@interface RXRecallButton ()

@property (nonatomic, assign) RXRecallButtonPosition initialPosition;

@end

@implementation RXRecallButton

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithInitialPosition:RXRecallButtonPositionBottomRight];
}

- (instancetype)initWithInitialPosition:(RXRecallButtonPosition)position {
    UIView *view = [[RXCardsIcon alloc] initWithFrame:CGRectMake(12, 12, 38, 38)];
    return [self initWithCustomView:view initialPosition:position];
}

- (instancetype)initWithCustomView:(UIView *)view initialPosition:(RXRecallButtonPosition)position {
    return [self initWithFrame:CGRectMake(0, 0, 64, 64) customView:view initialPosition:position];
}

- (instancetype)initWithFrame:(CGRect)frame customView:(UIView *)view initialPosition:(RXRecallButtonPosition)position {
    self = [self initWithFrame:frame];
    if (self) {
        self.snapToCorners = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = .5;
        self.layer.shadowRadius = 4;
        
        UIView *viewContainer = [[UIView alloc] initWithFrame:self.bounds];
        viewContainer.backgroundColor = [UIColor clearColor];
        viewContainer.layer.cornerRadius = self.layer.cornerRadius;
        viewContainer.clipsToBounds = YES;
        [viewContainer addSubview:view];
        
        [self addSubview:viewContainer];
        _view = view;
        _initialPosition = position;
        _isVisible = NO;
    }
    return self;
}

#pragma mark - Helpers

- (CGPoint)tuckedPositionForCorner:(RXRecallButtonPosition)corner {
    UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
    
    switch (corner) {
        case RXRecallButtonPositionBottomRight:
            return CGPointMake(currentWindow.frame.size.width - self.frame.size.width, currentWindow.frame.size.height + (self.frame.size.height / 2) + 5);
        case RXRecallButtonPositionBottomLeft:
            return CGPointMake(self.frame.size.width, currentWindow.frame.size.height + (self.frame.size.height / 2) + 5);
        case RXRecallButtonPositionTopLeft:
            return CGPointMake(self.frame.size.width, - (self.frame.size.height / 2) - 5);
        case RXRecallButtonPositionTopRight:
            return CGPointMake(currentWindow.frame.size.width - self.frame.size.width, - (self.frame.size.height / 2) - 5);
    }
}

- (CGPoint)offscreenPosition {
    CGPoint center;
    
    switch ((int)self.anchoredEdge) {
        case RXDraggableSnappedEdgeTop | RXDraggableSnappedEdgeLeft:
        case RXDraggableSnappedEdgeTop | RXDraggableSnappedEdgeRight:
        case RXDraggableSnappedEdgeTop:
            center = CGPointMake(self.center.x, - (self.frame.size.height / 2) - self.layer.shadowRadius - 1);
            break;
        case RXDraggableSnappedEdgeBottom | RXDraggableSnappedEdgeLeft:
        case RXDraggableSnappedEdgeBottom | RXDraggableSnappedEdgeRight:
        case RXDraggableSnappedEdgeBottom:
            center = CGPointMake(self.center.x, self.superview.frame.size.height + (self.frame.size.height / 2) +  self.layer.shadowRadius + 1);
            break;
        case RXDraggableSnappedEdgeRight:
            center = CGPointMake(self.superview.frame.size.width + self.frame.size.width + self.layer.shadowRadius + 1, self.center.y);
            break;
        case RXDraggableSnappedEdgeLeft:
            center = CGPointMake(- (self.frame.size.width / 2) - self.layer.shadowRadius - 1, self.center.y);
            break;
    }
    
    return center;
}

#pragma mark - Instance Methods

- (void)hide:(BOOL)animated completion:(void (^)())completion {
    CGPoint center = [self offscreenPosition];
    
    NSTimeInterval duration = animated ? .3 : 0;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.center = center;
                     }
                     completion:^(BOOL finished) {
                         _isVisible = NO;
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)show:(BOOL)animated completion:(void (^)())completion {
    UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (!self.superview) {
        self.center = [self tuckedPositionForCorner:_initialPosition];
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
            _isVisible = YES;
            if (completion) {
                completion();
            }
        }];
        [self.layer addAnimation:animation forKey:@"up"];
        self.layer.position = point;
    } [CATransaction commit];
}

@end
