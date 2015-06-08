//
//  RXDraggableView.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-26.
//
//

#import "RXDraggableView.h"

#define VALUE_BETWEEN(V, A, B) MAX(MIN(V, B), A)

@interface RXDraggableView () {
    BOOL _moved;
}

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, assign) CGPoint currentLocation;

@end

@implementation RXDraggableView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _margins = UIEdgeInsetsMake(30, 30, 30, 30);
}

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
     

    if (!_moved) {
        [_animator removeAllBehaviors];
        
        if ([self.delegate respondsToSelector:@selector(draggableViewClicked:)]) {
            [self.delegate draggableViewClicked:self];
        }
    } else {
        [self endUpTouchWithOffset:[self offsetFromAnchorPoint:currentPositionInView]];
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

- (void)endUpTouchWithOffset:(UIOffset)offset {
    [self endUpTouchWithOffset:offset anchor:[_attachmentBehavior anchorPoint]];
}

- (void)endUpTouchWithOffset:(UIOffset)offset anchor:(CGPoint)anchor {
    CGPoint currentLocation = anchor;
    
    [_animator removeAllBehaviors];
    
    RXDraggableEdge anchorToEdge;
    CGFloat horizontalDistance = NSNotFound;
    if (currentLocation.x > (self.superview.frame.size.width / 2)) {
        anchorToEdge = RXDraggableEdgeRight;
        horizontalDistance = self.superview.frame.size.width - currentLocation.x;
    } else {
        anchorToEdge = RXDraggableEdgeLeft;
        horizontalDistance = currentLocation.x;
    }
    
    CGFloat verticalDistance = NSNotFound;
    if (currentLocation.y > (self.superview.frame.size.height / 2)) {
        verticalDistance = self.superview.frame.size.height - currentLocation.y;
        if (verticalDistance < horizontalDistance) {
            anchorToEdge = RXDraggableEdgeBottom;
        }
    } else {
        verticalDistance = currentLocation.y;
        if (verticalDistance < horizontalDistance) {
            anchorToEdge = RXDraggableEdgeTop;
        }
    }
    
    _anchoredEdge = anchorToEdge;
    
    [UIView animateWithDuration:.5
                          delay:0
         usingSpringWithDamping:.7
          initialSpringVelocity:.3
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.center = [self snapPointToClosestEdgeFromPoint:currentLocation offset:offset];
                     }
                     completion:nil];
    
}

- (CGPoint)snapPointToClosestEdgeFromPoint:(CGPoint)point offset:(UIOffset)offset {
    CGFloat leftMinimum = (self.frame.size.width / 2) + _margins.left;
    CGFloat leftMaximum = self.superview.frame.size.width - ((self.frame.size.width / 2) + _margins.right);
    CGFloat topMinimum = (self.frame.size.height / 2) + _margins.top;
    CGFloat topMaximum = self.superview.frame.size.height - ((self.frame.size.height / 2) + _margins.bottom);
    
    switch (_anchoredEdge) {
        case RXDraggableEdgeTop:
            return CGPointMake(VALUE_BETWEEN(point.x + offset.horizontal, leftMinimum, leftMaximum), topMinimum);
        case RXDraggableEdgeBottom:
            return CGPointMake(VALUE_BETWEEN(point.x + offset.horizontal, leftMinimum, leftMaximum), topMaximum);
        case RXDraggableEdgeLeft:
            return CGPointMake(leftMinimum, VALUE_BETWEEN(point.y + offset.vertical, topMinimum, topMaximum));
        case RXDraggableEdgeRight:
            return CGPointMake(leftMaximum, VALUE_BETWEEN(point.y + offset.vertical, topMinimum, topMaximum));
    }
}

@end
