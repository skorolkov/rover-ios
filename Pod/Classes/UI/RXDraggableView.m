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
@property (nonatomic, strong) UIDynamicItemBehavior *dynamicItemBehavior;
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
    _anchoredEdge = RXDraggableSnappedEdgeBottom;
}


- (void)didMoveToSuperview {
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
    

}

- (void)setSnapToCorners:(BOOL)snapToCorners {
    _snapToCorners = snapToCorners;
    _anchoredEdge = [self anchoredEdgeFromPoint:self.center];
}

#pragma mark - Override Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _currentLocation = [touch locationInView:self.superview];
    
    [_animator removeAllBehaviors];
    
    _attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self attachedToAnchor:_currentLocation];
    [_animator addBehavior:_attachmentBehavior];
    
    _dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
    _dynamicItemBehavior.allowsRotation = NO;
    [_animator addBehavior:_dynamicItemBehavior];

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
        
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
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
    [_animator removeAllBehaviors];

    _anchoredEdge = [self anchoredEdgeFromPoint:anchor];

    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:self snapToPoint:[self snapPointToClosestEdgeFromPoint:anchor offset:offset]];
    [self.animator addBehavior:snapBehavior];
    
    UIDynamicItemBehavior *dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
    dynamicItemBehavior.allowsRotation = NO;
    [self.animator addBehavior:dynamicItemBehavior];
    
}

- (CGPoint)snapPointToClosestEdgeFromPoint:(CGPoint)point offset:(UIOffset)offset {
    CGFloat leftMinimum = (self.frame.size.width / 2) + _margins.left;
    CGFloat leftMaximum = self.superview.frame.size.width - ((self.frame.size.width / 2) + _margins.right);
    CGFloat topMinimum = (self.frame.size.height / 2) + _margins.top;
    CGFloat topMaximum = self.superview.frame.size.height - ((self.frame.size.height / 2) + _margins.bottom);
    
    switch ((int)_anchoredEdge) {
        case (RXDraggableSnappedEdgeTop | RXDraggableSnappedEdgeLeft):
            return CGPointMake(leftMinimum, topMinimum);
        case RXDraggableSnappedEdgeTop | RXDraggableSnappedEdgeRight:
            return CGPointMake(leftMaximum, topMinimum);
        case RXDraggableSnappedEdgeBottom | RXDraggableSnappedEdgeLeft:
            return CGPointMake(leftMinimum, topMaximum);
        case RXDraggableSnappedEdgeBottom | RXDraggableSnappedEdgeRight:
            return CGPointMake(leftMaximum, topMaximum);
        case RXDraggableSnappedEdgeTop:
            return CGPointMake(VALUE_BETWEEN(point.x + offset.horizontal, leftMinimum, leftMaximum), topMinimum);
        case RXDraggableSnappedEdgeBottom:
            return CGPointMake(VALUE_BETWEEN(point.x + offset.horizontal, leftMinimum, leftMaximum), topMaximum);
        case RXDraggableSnappedEdgeLeft:
            return CGPointMake(leftMinimum, VALUE_BETWEEN(point.y + offset.vertical, topMinimum, topMaximum));
        case RXDraggableSnappedEdgeRight:
            return CGPointMake(leftMaximum, VALUE_BETWEEN(point.y + offset.vertical, topMinimum, topMaximum));
    }
    
    return CGPointMake(leftMaximum, topMaximum);
}

- (RXDraggableSnappedEdge)anchoredEdgeFromPoint:(CGPoint)point {
    RXDraggableSnappedEdge horizontallyAnchoredEdge;
    CGFloat horizontalDistance = NSNotFound;
    if (point.x > (self.superview.frame.size.width / 2)) {
        horizontallyAnchoredEdge = RXDraggableSnappedEdgeRight;
        horizontalDistance = self.superview.frame.size.width - point.x;
    } else {
        horizontallyAnchoredEdge = RXDraggableSnappedEdgeLeft;
        horizontalDistance = point.x;
    }
    
    RXDraggableSnappedEdge verticallyAnchoredEdge;
    CGFloat verticalDistance = NSNotFound;
    if (point.y > (self.superview.frame.size.height / 2)) {
        verticalDistance = self.superview.frame.size.height - point.y;
        verticallyAnchoredEdge = RXDraggableSnappedEdgeBottom;
    } else {
        verticalDistance = point.y;
        verticallyAnchoredEdge = RXDraggableSnappedEdgeTop;
    }
    
    
    if (_snapToCorners) {
        return horizontallyAnchoredEdge | verticallyAnchoredEdge;
    }
    
    if (verticalDistance < horizontalDistance) {
        return verticallyAnchoredEdge;
    }
    
    return horizontallyAnchoredEdge;
}

@end
