//
//  RXDraggableView.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-26.
//
//

#import "RXDraggableView.h"

@interface RXDraggableView () {
    BOOL _moved;
}

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, assign) CGPoint currentLocation;

@end

@implementation RXDraggableView

- (void)didMoveToSuperview {
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
}


#pragma mark - Override Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _currentLocation = [touch locationInView:self.superview];
    
    [_animator removeAllBehaviors];
    
    _attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self attachedToAnchor:_currentLocation];
    [_animator addBehavior:_attachmentBehavior];
    
    UIDynamicItemBehavior *dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
    dynamicItemBehavior.allowsRotation = NO;
    [_animator addBehavior:dynamicItemBehavior];
    
    _moved = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _currentLocation = [touch locationInView:self.superview];
    
    _attachmentBehavior.anchorPoint = _currentLocation;
    
    _moved = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPositionInView = [touch locationInView:self];
    
    [self endUpTouchWithOffset:[self offsetFromAnchorPoint:currentPositionInView]];

    if (!_moved) {
        if ([self.delegate respondsToSelector:@selector(draggableViewClicked:)]) {
            [self.delegate draggableViewClicked:self];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // When user for example accidentally drag notifications bar
    // with ChatHead we need to cancel touch
    [self touchesEnded:touches withEvent:event];
}

- (UIOffset)offsetFromAnchorPoint:(CGPoint)anchorPoint {
    return UIOffsetMake((self.frame.size.width / 2) - anchorPoint.x, (self.frame.size.height / 2) - anchorPoint.y);
}

- (void)endUpTouchWithOffset:(UIOffset)offset
{
    CGPoint currentLocation = _attachmentBehavior.anchorPoint;
    
    [_animator removeAllBehaviors];
    
    RXDraggableEdge anchorToEdge;
    if (currentLocation.x > (self.superview.frame.size.width / 2)) {
        anchorToEdge = RXDraggableEdgeRight;
    } else {
        anchorToEdge = RXDraggableEdgeLeft;
    }
    
    [UIView animateWithDuration:.5
                          delay:0
         usingSpringWithDamping:.7
          initialSpringVelocity:.3
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.center = CGPointMake(anchorToEdge == RXDraggableEdgeRight ? (self.superview.frame.size.width - 60 ) : 60, currentLocation.y + offset.vertical);
                     }
                     completion:^(BOOL finished) {
                         _anchoredEdge = anchorToEdge;
                     }];
    
}


@end
