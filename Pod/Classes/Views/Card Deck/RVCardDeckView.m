//
//  RVCardDeckView.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-28.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardDeckView.h"
#import "RVCardView.h"
#import "RVCardViewButton.h"

// Space between the top of the card and the top of the screen
const CGFloat kCardMarginTop = 67.0;

// Focal length used in 3D projection
const CGFloat kFocalLength = 300.0;

// Amount we need to move the card before letting go triggers action callback
const CGFloat kCardActionTolerance = 80.0;

// Spacing on the Y and Z axis between each card
const CGFloat kCardSpacing = 20.0;

typedef struct {
    CGPoint center;
    CGFloat scale;
    CGFloat shadow;
} RVCardViewLayout;

@interface RVCardDeckView()

@property (strong, nonatomic) NSMapTable *cardIndexMap;
@property (strong, nonatomic) NSMutableArray *cards;
@property (readonly, nonatomic) NSArray *otherCards;
@property (readonly, nonatomic) RVCardView *topCard;
@property (strong, nonatomic) UIButton *invisibleButton;

@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) BOOL fullScreen;
@property (nonatomic) BOOL animating;

@end

@implementation RVCardDeckView

#pragma mark - Public Properties

- (BOOL)isFullScreen
{
    return self.fullScreen;
}

#pragma mark - Private Properties

- (RVCardView *)topCard
{
    return [self.cards firstObject];
}

- (NSArray *)otherCards
{
    NSRange r = NSMakeRange(1, [self.cards count] - 1);
    return [self.cards subarrayWithRange:r];
}

- (void)setFullScreen:(BOOL)fullScreen
{
    self.panGesture.enabled = !fullScreen;
    
    _fullScreen = fullScreen;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.invisibleButton = [[UIButton alloc] initWithFrame:frame];
        [self.invisibleButton addTarget:self action:@selector(invisibleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.invisibleButton];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        self.panGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
        self.panGesture.cancelsTouchesInView = YES;
        [self addGestureRecognizer:self.panGesture];
        
        self.fullScreen = NO;
        self.animating = NO;
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.animating) {
        [self layoutCards];
    }
}

- (void)layoutCards
{
    for (NSUInteger i=0, l=self.cards.count; i<l; i++) {
        RVCardView *cardView = self.cards[i];
        RVCardViewLayout layout = [self layoutForCardAtIndex:i];
        cardView.layer.position = layout.center;
        cardView.layer.transform = CATransform3DMakeScale(layout.scale, layout.scale, 1);
        cardView.shadow = layout.shadow;
    }
}

- (RVCardViewLayout)layoutForCardAtIndex:(NSUInteger)idx
{
    CGPoint origin = CGPointMake(self.frame.size.width / 2, ([RVCardView contractedHeight] / 2) + kCardMarginTop);
    CGFloat spacing = kCardSpacing * idx;
    CGFloat y = spacing * -1.0;
    CGFloat z = spacing;
    
    RVCardViewLayout layout;
    layout.scale = kFocalLength / (kFocalLength + z);
    layout.center = CGPointMake(origin.x, origin.y + y * layout.scale);
    layout.shadow = (1.0 - layout.scale) * 1.5;
    return layout;
}

#pragma mark - Public Methods

- (void)reloadData
{
    [self.cards enumerateObjectsUsingBlock:^(UIView *cardView, NSUInteger idx, BOOL *stop) {
        [cardView removeFromSuperview];
    }];
    
    [self.cards removeAllObjects];
    
    if (!self.dataSource) return;
    
    NSUInteger numCards = [self.dataSource numberOfItemsInDeck:self];
    self.cards = [NSMutableArray arrayWithCapacity:numCards];
    self.cardIndexMap = [NSMapTable weakToStrongObjectsMapTable];
    
    // Create the cards and add them as subviews in reverse order so the first card is on top
    for (int i = ((int)numCards - 1); i >= 0; i--) {
        RVCardView *cardView = [_dataSource cardDeck:self cardViewForItemAtIndex:i];
        cardView.delegate = self;
        cardView.frame = CGRectMake(0, 0, [RVCardView contractedWidth], [RVCardView contractedHeight]);
        cardView.alpha = 0.0;
        [self.cards insertObject:cardView atIndex:0];
        [self.cardIndexMap setObject:@(i) forKey:cardView];
        [self addSubview:cardView];
    }
}

- (RVCardView *)createCard
{
    return [[RVCardView alloc] initWithFrame:CGRectMake(0.0, 0.0, [RVCardView contractedWidth], [RVCardView contractedHeight])];
}

- (void)animateIn:(void (^)())completion
{
    
    if ([self.cards count] < 1) {
        if (completion) {
            completion();
        }
        return;
    }
    
    // Fade in and scale the top card
    self.topCard.alpha = 0.9;
    self.topCard.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [UIView animateWithDuration:0.5 animations:^{
        self.topCard.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.topCard didShow];
        
        if (completion) {
            completion();
        }
        
        if (self.delegate) {
            [self.delegate cardDeck:self didShowCard:self.topCard];
        }
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.topCard.transform = CGAffineTransformIdentity;
    }];
    
    // Fade in the rest of the cards
    [self.otherCards enumerateObjectsUsingBlock:^(UIView *cardView, NSUInteger idx, BOOL *stop) {
        [UIView animateWithDuration:0.3 delay:0.3 + (0.1 * idx) options:UIViewAnimationOptionCurveEaseOut animations:^{
            cardView.alpha = 1.0;
        } completion:nil];
    }];
}

- (void)enterFullScreen
{
    if (!self.fullScreen && !self.topCard.isExpanded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cardDeckWillEnterFullScreen:)]) {
            [self.delegate cardDeckWillEnterFullScreen:self];
        }
        self.animating = YES;
        [self.topCard expandToFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    }
}

- (void)exitFullScreen
{
    if (self.fullScreen && self.topCard.isExpanded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cardDeckWillExitFullScreen:)]) {
            [self.delegate cardDeckWillExitFullScreen:self];
        }
        self.animating = YES;
        RVCardViewLayout layout = [self layoutForCardAtIndex:0];
        [self.topCard contractToFrame:CGRectMake(0, 0, [RVCardView contractedWidth], [RVCardView contractedHeight]) atCenter:layout.center];
    }
}

- (NSUInteger)indexForCardView:(RVCardView *)cardView
{
    NSNumber *idx = [self.cardIndexMap objectForKey:cardView];
    return [idx unsignedIntegerValue];
}

- (void)nextCardWithDirection:(CardDeckSwipeDirection)direction completion:(void (^)(RVCardView *card))completion
{
    self.animating = YES;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGFloat x = direction == CardDeckSwipeDirectionRight ? 500.0 : -500.0;
        CGAffineTransform t1 = CGAffineTransformMakeTranslation(x, 100.0);
        CGAffineTransform t2 = [self rotationForOffset:x];
        self.topCard.transform = CGAffineTransformConcat(t1, t2);
        self.topCard.alpha = 0.0;
    } completion:^(BOOL finished) {
        RVCardView *card = self.topCard;
        [self removeCard:card];
        
        if (completion) {
            completion(card);
        }
        
        if (self.delegate) {
            [self.delegate cardDeck:self didSwipeCard:card];
        }
        
        if (!self.topCard) return;
        
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutCards];
        } completion:^(BOOL finished) {
            [self.topCard didShow];
            self.animating = NO;
            
            if (self.delegate) {
                [self.delegate cardDeck:self didShowCard:self.topCard];
            }
        }];
    }];
}

#pragma mark - Utility methods

- (CGAffineTransform)rotationForOffset:(CGFloat)offset
{
    if (offset < 0) {
        offset = MAX(offset, 0 - kCardActionTolerance);
    } else {
        offset = MIN(offset, kCardActionTolerance);
    }
    
    CGFloat degrees = (offset / 100 * 10.0) * -1.0;
    CGFloat radians = degrees * (M_PI/180.0);
    return CGAffineTransformMakeRotation(radians);
}

#pragma mark - Card Management Methods

- (void)removeCard:(RVCardView *)cardView
{
    [cardView removeFromSuperview];
    [self.cards removeObject:cardView];
}

#pragma mark - Actions

- (void)invisibleButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(cardDeckDidPressBackground:)]) {
        [self.delegate cardDeckDidPressBackground:self];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (void)didPan:(UIPanGestureRecognizer *)panGesture
{
    CGPoint translation = [panGesture translationInView:[self superview]];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.animating = YES;
    }
    
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGAffineTransform t1 = CGAffineTransformMakeTranslation(translation.x, translation.y);
        CGAffineTransform t2 = [self rotationForOffset:translation.x];
        self.topCard.transform = CGAffineTransformConcat(t1, t2);
    }
    
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        if (abs(translation.x) > kCardActionTolerance) {
            CardDeckSwipeDirection direction = translation.x > 0 ? CardDeckSwipeDirectionRight : CardDeckSwipeDirectionLeft;
            [self nextCardWithDirection:direction completion:nil];
        } else {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.topCard.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.animating = NO;
            }];
        }
    }
}

#pragma mark - RVCardViewDelegate

- (void)cardViewMoreButtonPressed:(RVCardView *)cardView {
    if (cardView == self.topCard) {
        cardView.isExpanded ? [self exitFullScreen] : [self enterFullScreen];
    }
}

- (void)cardViewLikeButtonPressed:(RVCardView *)cardView {
    if (cardView.liked) {
        cardView.liked = NO;
        
        if (self.delegate) {
            [self.delegate cardDeck:self didUnlikeCard:cardView];
        }
    } else {
        cardView.liked = YES;
        
        if (self.delegate) {
            [self.delegate cardDeck:self didLikeCard:cardView];
        }
    }
}

- (void)cardViewDiscardButtonPressed:(RVCardView *)cardView {
    if (!cardView.discarded) {
        cardView.discarded = YES;
        
//    [self nextCardWithDirection:CardDeckSwipeDirectionLeft completion:^(RVCardView *card) {
        if (self.delegate) {
            [self.delegate cardDeck:self didDiscardCard:cardView];
        }
    }
}

- (void)cardViewDidExpand:(RVCardView *)cardView {
    self.animating = NO;
    self.fullScreen = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardDeckDidEnterFullScreen:)]) {
        [self.delegate cardDeckDidEnterFullScreen:self];
    }
}

- (void)cardViewDidContract:(RVCardView *)cardView {
    self.animating = NO;
    self.fullScreen = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardDeckDidExitFullScreen:)]) {
        [self.delegate cardDeckDidExitFullScreen:self];
    }
}

@end
