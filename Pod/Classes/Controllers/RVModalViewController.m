//
//  RVModalViewController.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-27.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "Rover.h"
#import "RVModalViewController.h"
#import "RVNetworkingManager.h"
#import "RVVisitProject.h"
#import "RVCardDeckView.h"
#import "RVCardView.h"
#import "RVCardProject.h"
#import "RVCloseButton.h"
#import "RVModalView.h"
#import "RVImageEffects.h"
#import "RVHelper.h"
#import "RVCustomerProject.h"

NSString *const RVModalViewOptionsTag = @"Tags";
NSString *const RVModalViewOptionsPredicate = @"Predicate";

@interface RVModalViewController () <RVModalViewDelegate, RVCardDeckViewDelegate, RVCardDeckViewDataSourceDelegate>

@property (strong, nonatomic) RVModalView *view;
@property (strong, nonatomic) RVVisit *visit;
@property (readonly, nonatomic) NSArray *cards;

@end

@implementation RVModalViewController
{
    NSArray *_cards;
}

@dynamic view;

#pragma mark - Properties

- (void)setVisit:(RVVisit *)visit {
    _visit = visit;
    _cards = nil;
    [self.view.cardDeck reloadData];
}

- (void)setCardSet:(ModalViewCardSet)cardSet {
    _cardSet = cardSet;
    _cards = nil;
}

- (NSArray *)cards {
    if (_cards) {
        return _cards;
    }
    
    NSArray *tags = [self.options objectForKey:RVModalViewOptionsTag];
    NSPredicate *predicate = [self.options objectForKey:RVModalViewOptionsPredicate];
    
    if (self.cardSet == ModalViewCardSetSaved) {
        _cards = self.visit.savedCards;
    } else if (self.cardSet == ModalViewCardSetUnread) {
        _cards = self.visit.unreadCards;
    } else if (self.cardSet == ModalViewCardSetTagsInclude) {
        NSAssert(tags != nil, @"No tag options supplied. You must set the RVModalViewOptionsTag key of the options property.");
        _cards = [self.visit.cards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            RVCard *card = evaluatedObject;
            
            __block BOOL includesTags = NO;
            [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *tag = obj;
                
                if ([card.tags containsObject:tag]) {
                    includesTags = YES;
                    *stop = YES;
                }
                
            }];
            
            return includesTags;
        }]];
    } else if (self.cardSet == ModalViewCardSetTagsExclude) {
        NSAssert(tags != nil, @"No tag options supplied. You must set the RVModalViewOptionsTag key of the options property.");
        _cards = [self.visit.cards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            RVCard *card = evaluatedObject;
            
            __block BOOL excludesTags = YES;
            [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *tag = obj;
                
                if ([card.tags containsObject:tag]) {
                    excludesTags = NO;
                    *stop = YES;
                }
            }];
            
            return excludesTags;
        }]];
    } else if (self.cardSet == ModalViewCardSetCustom) {
        NSAssert(predicate != nil, @"No predicate options supplied. You must set the RVModalViewOptionsPredicate key of the options property.");
        _cards = [self.visit.cards filteredArrayUsingPredicate:predicate];
    } else {
        _cards = self.visit.cards;
    }
    
    return _cards;
}

#pragma mark - Initialization

- (id)init {
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.cardSet = ModalViewCardSetAll;
    }
    return self;
}

- (void)loadView {
    self.view = [[RVModalView alloc] initWithFrame:UIScreen.mainScreen.applicationFrame];
    self.view.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createBlur];
    
    self.view.delegate = self;
    self.view.cardDeck.delegate = self;
    self.view.cardDeck.dataSource = self;
    
    self.visit = [[Rover shared] currentVisit];
    [RVCustomer cachedCustomer];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.view.cardDeck animateIn:^{
        [self.view animateIn];
    }];
}

/* Create a blurred snapshot of current screen
 */
- (void)createBlur {
    UIViewController* rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIView *view = rootViewController.view;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = [RVImageEffects applyBlurWithRadius:self.modalBlurRadius tintColor:self.modalTintColor saturationDeltaFactor:1 maskImage:nil toImage:image];
    
    self.view.background.image = image;
}

- (void)saveCard:(RVCard *)card {
    NSUInteger idx = [self.cards indexOfObject:card];
    card.lastViewedFrom = @"Modal";
    card.lastViewedPosition = [NSNumber numberWithInteger:(idx + 1)];
    [card save:nil failure:nil];
}

#pragma mark - RVModalViewDelegate

- (void)modalViewCloseButtonPressed:(RVModalView *)modalView {
    if (self.view.cardDeck.isFullScreen) {
        [self.view.cardDeck exitFullScreen];
    } else if (self.delegate) {
        [self.delegate modalViewControllerDidFinish:self];
    }
}

- (void)modalViewBackgroundPressed:(RVModalView *)modalView {

}

#pragma mark - RVCardDeckViewDelegate

- (void)cardDeckDidPressBackground:(RVCardDeckView *)cardDeck {

}

- (void)cardDeck:(RVCardDeckView *)cardDeck didSwipeCard:(RVCardView *)cardView {
    NSUInteger idx = [cardDeck indexForCardView:cardView];
    RVCard *card = [self.cards objectAtIndex:idx];
    
    if ([self.delegate respondsToSelector:@selector(modalViewController:didSwipeCard:)]) {
        [self.delegate modalViewController:self didSwipeCard:card];
    }
    
    if (idx == [self.cards count] - 1 && self.delegate) {
        [self.delegate modalViewControllerDidFinish:self];
    }
}

- (void)cardDeck:(RVCardDeckView *)cardDeck didShowCard:(RVCardView *)cardView {
    NSUInteger idx = [self.view.cardDeck indexForCardView:cardView];
    RVCard *card = [self.cards objectAtIndex:idx];
    card.isUnread = NO;
    card.viewedAt = [NSDate date];
    [self saveCard:card];
    
    if ([self.delegate respondsToSelector:@selector(modalViewController:didDisplayCard:)]) {
        [self.delegate modalViewController:self didDisplayCard:card];
    }

    // Onboarding animations
    if (idx == 0 && ![RVCustomer cachedCustomer].hasSeenTutorial) {
        self.view.userInteractionEnabled = NO;
        [self demonstrateCardSwipeWithCardView:cardView completion:^(BOOL finished) {
            [self demonstrateTapToExpandWithCompletion:^(BOOL finished) {
                [RVCustomer cachedCustomer].hasSeenTutorial = YES;
                self.view.userInteractionEnabled = YES;
            }];
        }];
    }

}

- (void)cardDeck:(RVCardDeckView *)cardDeck didLikeCard:(RVCardView *)cardView {
    NSUInteger idx = [self.view.cardDeck indexForCardView:cardView];
    RVCard *card = [self.cards objectAtIndex:idx];
    card.likedAt = [NSDate date];
    card.discardedAt = nil;
    [self saveCard:card];
}

- (void)cardDeck:(RVCardDeckView *)cardDeck didUnlikeCard:(RVCardView *)cardView {
    NSUInteger idx = [self.view.cardDeck indexForCardView:cardView];
    RVCard *card = [self.cards objectAtIndex:idx];
    card.likedAt = nil;
    [self saveCard:card];
}

- (void)cardDeck:(RVCardDeckView *)cardDeck didDiscardCard:(RVCardView *)cardView {
    NSUInteger idx = [self.view.cardDeck indexForCardView:cardView];
    RVCard *card = [self.cards objectAtIndex:idx];
    card.likedAt = nil;
    card.discardedAt = [NSDate date];
    [self saveCard:card];
}

- (void)cardDeckDidEnterFullScreen:(RVCardDeckView *)cardDeck {
    RVCard *card = cardDeck.topCard.card;
    card.lastExpandedAt = [NSDate date];
    [self saveCard:card];
}

- (void)cardDeckDidEnterBarcodeView:(RVCardDeckView *)cardDeck {
    RVCard *card = cardDeck.topCard.card;
    card.lastViewedBarcodeAt = [NSDate date];
    [self saveCard:card];
}

#pragma mark - RVCardDeckViewDataSourceDelegate

- (NSUInteger)numberOfItemsInDeck:(RVCardDeckView *)cardDeck {
    return self.cards.count;
}

- (RVCardView *)cardDeck:(RVCardDeckView *)cardDeck cardViewForItemAtIndex:(NSUInteger)index {
    RVCard *card = [self.cards objectAtIndex:index];
    RVCardView  *cardView = [cardDeck createCard];
    [cardView setCard:card];
    
    return cardView;
}

#pragma mark - Onboarding animations


- (void)demonstrateCardSwipeWithCardView:(RVCardView *)cardView completion:( void (^)(BOOL) )completion
{
    [RVHelper showMessage:@"Swipe for the next card" holdFor:1 delay:.7 duration:.4];
    [RVHelper displaySwipeTutorialWithCardView:cardView completion:completion];

}

- (void)demonstrateTapToExpandWithCompletion:( void (^)(BOOL) )completion
{
    [RVHelper showMessage:@"Tap for more info" holdFor:.73 delay:.1 duration:.4];
    [RVHelper displayTapTutorialAnimationAtPoint:self.view.cardDeck.topCard.center completion:completion];
}

@end
