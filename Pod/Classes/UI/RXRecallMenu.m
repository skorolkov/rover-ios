//
//  RXRecallMenu.m
//  Pods
//
//  Created by Ata Namvari on 2015-06-16.
//
//

#import "RXRecallMenu.h"
#import "RXMenuItem.h"

@interface RXDraggableView ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
- (void)endUpTouchWithOffset:(UIOffset)offset;

@end

@interface RXRecallMenu () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat offsetFactor;
@property (nonatomic, strong) RXMenuItem *closeMenuItem;
@property (nonatomic, strong) UIDynamicAnimator *snakeAnimator;

@end

#define kCollapsedOffsetFactor 10

@implementation RXRecallMenu

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, 64, 64)];
    if (self) {
        self.clipsToBounds = NO;
        
        self.offsetFactor = 10;
        
        _closeMenuItem = [[RXMenuItem alloc] init];
        [_closeMenuItem setTitle:@"X" forState:UIControlStateNormal];
        [_closeMenuItem addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_closeMenuItem setCenter:[self convertPoint:self.center fromView:self.superview]];
        [_closeMenuItem setEnabled:NO];
        [self addSubview:_closeMenuItem];
        
        [self addTarget:self action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    _snakeAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
}

- (void)addItem:(RXMenuItem *)item animated:(BOOL)animated {
    item.enabled = NO;
    
    CGPoint center = [self convertPoint:self.center fromView:self.superview];
    item.center = CGPointMake(center.x, center.y + 170); // start somewhere off screen

    [self addSubview:item];
    [self layoutItems:animated enable:_isExpanded];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    for (NSInteger i = 1, count = self.subviews.count ; i < count; ++i) {
        RXMenuItem *menuItem = self.subviews[i];
        RXMenuItem *previousMenuItem;
        if (i < count - 1) {
            previousMenuItem = self.subviews[i+1];
        }
        
        UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:menuItem attachedToItem:(i == count - 1 ? self : previousMenuItem)];
        [self.animator addBehavior:attachmentBehavior];
    }
}

- (void)endUpTouchWithOffset:(UIOffset)offset {
    [super endUpTouchWithOffset:offset];
    [self layoutItems:YES enable:_isExpanded];
}

- (void)removeItem:(RXMenuItem *)item animated:(BOOL)animated {
    //NSAssert(item.superview == self, @"This RXMenuItem was never added");
    
    if (item.superview != self) {
        return;
    }
    
    CGFloat oldAlphaValue = item.alpha;
    CGPoint center = CGPointMake(item.center.x - 150, item.center.y);
    [UIView animateWithDuration:animated ? .3 : 0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         item.center = center;
                         item.alpha = 0;
                     } completion:^(BOOL finished) {
                         [item removeFromSuperview];
                         item.alpha = oldAlphaValue;
                         [self layoutItems:animated enable:_isExpanded];
                     }];
}

- (void)collapse:(BOOL)animated {
    if (!_isExpanded) {
        return;
    }
    
    _offsetFactor = 10;
    _closeMenuItem.enabled = NO;
    _isExpanded = NO;
    [self layoutItems:animated enable:NO];
}

- (void)expand:(BOOL)animated {
    if (_isExpanded) {
        return;
    }
    
    _offsetFactor = 70;
    _closeMenuItem.enabled = YES;
    _isExpanded = YES;
    [self layoutItems:animated enable:YES];
}

- (void)layoutItems:(BOOL)animated enable:(BOOL)enable {
    CGPoint center = [self convertPoint:self.center fromView:self.superview];
    NSInteger count = self.subviews.count;
    [UIView animateWithDuration:animated ? .3 : 0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         for (int i = 1; i < count; ++i) {
                             RXMenuItem *menuItem = self.subviews[i];
                             [menuItem setCenter:CGPointMake(center.x, center.y - (((count - i) - (_isExpanded ? 0 : 1)) * _offsetFactor))];
                             [menuItem setEnabled:enable];
                         }
                     } completion:nil];
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

#pragma mark - Tap Gesture Action

- (void)toggleExpandedView {
    if (_isExpanded) {
        [self collapse:YES];
    } else {
        [self expand:YES];
    }
}

#pragma mark - Actions

- (void)closeButtonClicked {
    [self collapse:YES];
}

- (void)menuClicked {
    [self expand:YES];
}

@end
