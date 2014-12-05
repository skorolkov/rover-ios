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
//const CGFloat kCardMarginTop = 67.0;

// Focal length used in 3D projection
const CGFloat kFocalLength = 280.0;

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

@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) UIDynamicAnimator *animator;
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
    self.panGesture.enabled = self.cardSwipeEnabled && !fullScreen;
    
    _fullScreen = fullScreen;
}

- (void)setCardSwipeEnabled:(BOOL)cardSwipeEnabled
{
    self.panGesture.enabled = cardSwipeEnabled && !self.fullScreen;
    _cardSwipeEnabled = cardSwipeEnabled;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScreen:)];
        [self addGestureRecognizer:tapGesture];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        self.panGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
        self.panGesture.cancelsTouchesInView = YES;
        
        self.fullScreen = NO;
        self.animating = NO;
        self.cardSwipeEnabled = YES;
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
    CGPoint origin = CGPointMake(self.frame.size.width / 2, (self.frame.size.height  / 2) - (kCardSpacing * (self.frame.size.height > 560 ? 2 : 1)) );
    CGFloat spacing = kCardSpacing * idx;
    CGFloat y = 25 + spacing * -1.0;
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
        [cardView removeGestureRecognizer:self.panGesture];
        [cardView removeFromSuperview];
    }];
    
    [self.cards removeAllObjects];
    
    if (!self.dataSource) return;
    
    NSUInteger numCards = [self.dataSource numberOfItemsInDeck:self];
    self.cards = [NSMutableArray arrayWithCapacity:numCards];
    self.cardIndexMap = [NSMapTable weakToStrongObjectsMapTable];
    
    // Create the cards in order so the first image loads first
    for (int i = 0, l = (int)numCards; i < l; i++) {
        RVCardBaseView *cardView = [_dataSource cardDeck:self cardViewForItemAtIndex:i];
        cardView.delegate = self;
        //cardView.useCloseButton = NO;
        cardView.frame = CGRectMake(0, 0, cardView.contractedWidth, cardView.contractedHeight);
        
        cardView.alpha = 0.0;
        [self.cards insertObject:cardView atIndex:i];
        [self.cardIndexMap setObject:@(i) forKey:cardView];
        [self addSubview:cardView];
        [self sendSubviewToBack:cardView];
    }
    
    if (self.topCard) {
        [self.topCard addGestureRecognizer:self.panGesture];
    }
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
        [self.topCard expandToFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height) animated:YES];
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
        [self.topCard contractToFrame:CGRectMake(0, 0, self.topCard.contractedWidth, self.topCard.contractedHeight) atCenter:layout.center animated:YES];
    }
}

- (NSUInteger)indexForCardView:(RVCardBaseView *)cardView
{
    NSNumber *idx = [self.cardIndexMap objectForKey:cardView];
    return [idx unsignedIntegerValue];
}

- (void)nextCard
{
    self.animating = YES;
    RVCardView *card = self.topCard;
    [self removeCard:card];
    
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
}

#pragma mark - Utility methods

- (CGFloat)angleOfView:(UIView *)view
{
    // http://stackoverflow.com/a/2051861/1271826
    
    return atan2(view.transform.b, view.transform.a);
}

#pragma mark - Card Management Methods

- (void)removeCard:(RVCardView *)cardView
{
    [cardView removeGestureRecognizer:self.panGesture];
    [cardView removeFromSuperview];
    [self.cards removeObject:cardView];
    if (self.topCard) {
        [self.topCard addGestureRecognizer:self.panGesture];
    }
}

#pragma mark - Actions

- (void)didTapScreen:(UITapGestureRecognizer *)tapGesture {
    if ([self.delegate respondsToSelector:@selector(cardDeckDidPressBackground:)]) {
        [self.delegate cardDeckDidPressBackground:self];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (void)didPan:(UIPanGestureRecognizer *)panGesture
{
    static UIAttachmentBehavior *attachment;
    static CGPoint               startCenter;
    
    // variables for calculating angular velocity
    
    static CFAbsoluteTime        lastTime;
    static CGFloat               lastAngle;
    static CGFloat               angularVelocity;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.animating = YES;
        startCenter = panGesture.view.center;
        
        // calculate the center offset and anchor point
        CGPoint pointWithinAnimatedView = [panGesture locationInView:panGesture.view];
        
        UIOffset offset = UIOffsetMake(pointWithinAnimatedView.x - panGesture.view.bounds.size.width / 2.0,
                                       pointWithinAnimatedView.y - panGesture.view.bounds.size.height / 2.0);
        
        CGPoint anchor = [panGesture locationInView:panGesture.view.superview];
        
        // create attachment behavior
        attachment = [[UIAttachmentBehavior alloc] initWithItem:panGesture.view
                                               offsetFromCenter:offset
                                               attachedToAnchor:anchor];
        lastTime = CFAbsoluteTimeGetCurrent();
        lastAngle = [self angleOfView:panGesture.view];
        attachment.length = 0.0;
        
        attachment.action = ^{
            CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
            CGFloat angle = [self angleOfView:panGesture.view];
            if (time > lastTime) {
                angularVelocity = (angle - lastAngle) / (time - lastTime);
                lastTime = time;
                lastAngle = angle;
            }
        };
        
        [self.animator addBehavior:attachment];
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged)
    {
        // as user makes gesture, update attachment behavior's anchor point, achieving drag 'n' rotate
        CGPoint anchor = [panGesture locationInView:panGesture.view.superview];
        attachment.anchorPoint = anchor;
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded)
    {
        [self.animator removeAllBehaviors];
        
        CGPoint velocity = [panGesture velocityInView:panGesture.view.superview];
        CGPoint translation = [panGesture translationInView:panGesture.view.superview];
        
        // if we aren't dragging it far enough, just snap it back and quit
        
        if (MAX(fabs(translation.x), fabs(translation.y)) < 20) { //fabs(atan2(velocity.y, velocity.x) - M_PI_2) > M_PI_4) {
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:panGesture.view snapToPoint:startCenter];
            [self.animator addBehavior:snap];
            
            return;
        }
        
        // otherwise, create UIDynamicItemBehavior that carries on animation from where the gesture left off (notably linear and angular velocity)
        
        UIDynamicItemBehavior *dynamic = [[UIDynamicItemBehavior alloc] initWithItems:@[panGesture.view]];
        [dynamic addLinearVelocity:CGPointMake(MIN(velocity.x, 10)/4,velocity.y/4) forItem:panGesture.view];
        //dynamic.resistance = 10.f;
        //dynamic.friction =10;
        [dynamic addAngularVelocity:angularVelocity forItem:panGesture.view];
        [dynamic setAngularResistance:10];
        
        // when the view no longer intersects with its superview, go ahead and remove it
        
        dynamic.action = ^{
            if (!CGRectIntersectsRect(panGesture.view.superview.bounds, panGesture.view.frame)) {
                [self.animator removeAllBehaviors];
                [self nextCard];
            }
        };
        [self.animator addBehavior:dynamic];
        
        // add a little gravity so it accelerates off the screen (in case user gesture was slow)
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[panGesture.view]];
        gravity.magnitude = 2.7;
        [self.animator addBehavior:gravity];
    }
}

#pragma mark - RVCardViewDelegate

- (void)cardViewMoreButtonPressed:(RVCardBaseView *)cardView {
    if (cardView == self.topCard) {
        cardView.isExpanded ? [self exitFullScreen] : [self enterFullScreen];
    }
}


- (void)cardViewDidExpand:(RVCardBaseView *)cardView {
    self.animating = NO;
    self.fullScreen = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardDeckDidEnterFullScreen:)]) {
        [self.delegate cardDeckDidEnterFullScreen:self];
    }
}

- (void)cardViewDidContract:(RVCardBaseView *)cardView {
    self.animating = NO;
    self.fullScreen = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardDeckDidExitFullScreen:)]) {
        [self.delegate cardDeckDidExitFullScreen:self];
    }
}

@end
