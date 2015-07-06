//
//  RXRecallMenu.m
//  Pods
//
//  Created by Ata Namvari on 2015-06-16.
//
//

#import "RXRecallMenu.h"
#import "RXCloseMenuItem.h"

@interface RXDraggableView ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
- (void)endUpTouchWithOffset:(UIOffset)offset;

@end

@interface RXRecallMenu () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat offsetFactor;
@property (nonatomic, assign) CGFloat offsetConstant;
@property (nonatomic, strong) RXCloseMenuItem *closeMenuItem;

@end

#define kExpandedOffsetFactor 80
#define kCollapsedOffsetFactor 10
#define kTitleLabelMargin 10

@implementation RXRecallMenu

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, 64, 64) ];
    if (self) {
        self.snapToCorners = YES;
        self.clipsToBounds = NO;
        
        self.offsetFactor = 10;
        
        _closeMenuItem = [[RXCloseMenuItem alloc] init];
        [_closeMenuItem setHidden:YES];
        [_closeMenuItem setBackgroundColor:[UIColor darkGrayColor]];
        [_closeMenuItem addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_closeMenuItem setCenter:self.center];
        [_closeMenuItem setEnabled:NO];
        [self addSubview:_closeMenuItem];
        
        [self addTarget:self action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
        
        self.backdropView = [UIView new];
        self.backdropView.backgroundColor = [UIColor blackColor];
        self.backdropView.alpha = .3;
    }
    return self;
}

- (void)setBackdropView:(UIView *)backdropView {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonClicked)];
    [backdropView addGestureRecognizer:gestureRecognizer];
    _backdropView = backdropView;
}

#pragma mark - Item Management

- (NSUInteger)itemCount {
    return self.subviews.count - 1;
}

- (NSArray *)items {
    return [self.subviews subarrayWithRange:NSMakeRange(1, self.itemCount)];
}

- (void)addItem:(UIButton *)item animated:(BOOL)animated {
    item.userInteractionEnabled = NO;
    item.titleLabel.alpha = 0;
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat offsetDirection = (self.anchoredEdge & RXDraggableSnappedEdgeBottom ? 1 : -1);
    item.center = CGPointMake(center.x, center.y + (offsetDirection * (item.bounds.size.height + item.layer.shadowRadius + (offsetDirection < 1 ? self.margins.bottom : self.margins.top) + 2)));

    [self addSubview:item];
    [self layoutItems:animated completion:nil];
}

- (void)removeItem:(UIButton *)item animated:(BOOL)animated {
    //NSAssert(item.superview == self, @"This RXMenuItem was never added");
    
    if (item.superview != self) {
        return;
    }
    
    CGFloat oldAlphaValue = item.alpha;
    CGFloat direction = self.anchoredEdge & RXDraggableSnappedEdgeRight ? -1 : 1;
    CGPoint center = CGPointMake(item.center.x + (direction * 150), item.center.y);
    [UIView animateWithDuration:animated ? .3 : 0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         item.center = center;
                         item.alpha = 0;
                     } completion:^(BOOL finished) {
                         [item removeFromSuperview];
                         item.alpha = oldAlphaValue;
                         
                         [self layoutItems:animated completion:nil];
                     }];
}

#pragma mark - Overridden Methods

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        if ([subview pointInside:[subview convertPoint:point fromView:self] withEvent:event]) {
            return YES;
        }
    }
    return [super pointInside:point withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isExpanded) {
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
    
    [self.items enumerateObjectsUsingBlock:^(UIView *item, NSUInteger idx, BOOL *stop) {
        UIView *previousItem;
        if (idx == self.itemCount - 1) {
            previousItem = self;
        } else {
            previousItem = self.items[idx + 1];
        }
        
        UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToItem:previousItem];
        [self.animator addBehavior:attachmentBehavior];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isExpanded) {
        return;
    }
    
    [super touchesEnded:touches withEvent:event];
}


- (void)endUpTouchWithOffset:(UIOffset)offset {
    [super endUpTouchWithOffset:offset];
    
    [self.items enumerateObjectsUsingBlock:^(UIView *item, NSUInteger idx, BOOL *stop) {
        CGPoint position = [self anchorPointForItemAtIndex:idx];
        
        UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:item snapToPoint:position];
        [self.animator addBehavior:snapBehavior];
        
        UIDynamicItemBehavior *dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
        dynamicItemBehavior.allowsRotation = NO;
        [self.animator addBehavior:dynamicItemBehavior];
    }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (_isExpanded) {
        for (UIView *subview in self.subviews) {
            UIView *hitTestView = [subview hitTest:[subview convertPoint:point fromView:self] withEvent:event];
            if (hitTestView) {
                return hitTestView;
            }
        }
    }
    return [super hitTest:point withEvent:event];
}

- (CGPoint)offscreenPosition {
    CGPoint position = [super offscreenPosition];
    CGFloat offset = self.itemCount * kCollapsedOffsetFactor;
    
    switch ((int)self.anchoredEdge) {
        case RXDraggableSnappedEdgeTop | RXDraggableSnappedEdgeLeft:
        case RXDraggableSnappedEdgeTop | RXDraggableSnappedEdgeRight:
        case RXDraggableSnappedEdgeTop:
            position = CGPointMake(position.x, position.y - offset);
            break;
        case RXDraggableSnappedEdgeBottom | RXDraggableSnappedEdgeLeft:
        case RXDraggableSnappedEdgeBottom | RXDraggableSnappedEdgeRight:
        case RXDraggableSnappedEdgeBottom:
            position = CGPointMake(position.x, position.y + offset);
            break;
    }
    
    return position;
}

#pragma mark - Layout

- (void)layoutItems:(BOOL)animated completion:(void (^)())completion {
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    center.y += _isExpanded ?  : 0;
    
    BOOL rightAligned = self.anchoredEdge & RXDraggableSnappedEdgeRight;
    
    [self.items enumerateObjectsUsingBlock:^(UIButton *item, NSUInteger idx, BOOL *stop) {
        item.userInteractionEnabled = _isExpanded;
        item.contentHorizontalAlignment = rightAligned ? UIControlContentHorizontalAlignmentRight : UIControlContentHorizontalAlignmentLeft;
        // TODO: change this 300 to screen width minus a 30 pixel margin from the side
        [item setContentEdgeInsets:UIEdgeInsetsMake(0, rightAligned ? -300 : item.bounds.size.width + kTitleLabelMargin, 0, rightAligned ? item.bounds.size.width + kTitleLabelMargin : -300)];
        
        [UIView animateWithDuration:animated ? .3 : 0
                              delay:animated ? (_isExpanded ? idx * .1 : (self.itemCount - idx - 1) * .1) : 0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             item.center = CGPointMake(center.x, center.y + [self verticallOffsetForItemAtIndex:idx]);
                             item.titleLabel.alpha = _isExpanded ? 1 : 0;
                         }
                         completion:^(BOOL finished) {
                             if (idx == self.itemCount - 1) {
                                 _closeMenuItem.hidden = !_isExpanded;
                                 
                                 if (completion) {
                                     completion();
                                 }
                             }
                         }];
    }];
}

- (void)collapse:(BOOL)animated completion:(void (^)())completion {
//    if (!_isExpanded) {
//        return;
//    }
    
    self.userInteractionEnabled = NO;
    
    [self hideBackdrop];
    
    _offsetFactor = kCollapsedOffsetFactor;
    _offsetConstant = 0;
    _closeMenuItem.enabled = NO;
    _isExpanded = NO;
    [self layoutItems:animated completion:^{
        self.userInteractionEnabled = YES;
        
        if (completion) {
            completion();
        }
    }];
}

- (void)expand:(BOOL)animated completion:(void (^)())completion {
//    if (_isExpanded) {
//        return;
//    }
    
    [self showBackdrop];
    
    _offsetFactor = kExpandedOffsetFactor;
    _offsetConstant = self.bounds.size.height + 10;
    _closeMenuItem.enabled = YES;
    _closeMenuItem.hidden = NO;
    _isExpanded = YES;
    [self layoutItems:animated completion:completion];
}

#pragma mark - Helpers

- (CGPoint)anchorPointForItemAtIndex:(NSUInteger)index {
    CGPoint center = [self snapPointToClosestEdgeFromPoint:self.center offset:UIOffsetZero];
    return CGPointMake(center.x, center.y + [self verticallOffsetForItemAtIndex:index]);
}

- (CGFloat)verticallOffsetForItemAtIndex:(NSUInteger)index {
    CGFloat offsetDirection = (self.anchoredEdge & RXDraggableSnappedEdgeBottom ? -1 : 1);
    return (offsetDirection * (MAX(self.itemCount - index - 1, 0) * _offsetFactor + _offsetConstant));
}

- (void)showBackdrop {
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    self.backdropView.frame = currentWindow.bounds;
    CGFloat originalAlpha = self.backdropView.alpha;
    self.backdropView.alpha = 0;
    [currentWindow insertSubview:self.backdropView belowSubview:self];
    [UIView animateWithDuration:.2 animations:^{
        self.backdropView.alpha = originalAlpha;
    }];
}

- (void)hideBackdrop {
    CGFloat originalAlpha = self.backdropView.alpha;
    [UIView animateWithDuration:.2 animations:^{
        self.backdropView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backdropView removeFromSuperview];
        self.backdropView.alpha = originalAlpha;
    }];
}

#pragma mark - Tap Gesture Action

- (void)toggleExpandedView {
    if (_isExpanded) {
        [self collapse:YES completion:nil];
    } else {
        [self expand:YES completion:nil];
    }
}

#pragma mark - Actions

- (void)closeButtonClicked {
    [self collapse:YES completion:nil];
}

- (void)menuClicked {
    if (self.itemCount == 1) {
        UIButton *item = self.items[0];
        [item sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        [self expand:YES completion:nil];
    }
}


@end
