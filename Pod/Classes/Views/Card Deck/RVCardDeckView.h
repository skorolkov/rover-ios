//
//  RVCardDeckView.h
//  Rover
//
//  Created by Sean Rucker on 2014-06-28.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RVCardView.h"

@protocol RVCardDeckViewDelegate, RVCardDeckViewDataSourceDelegate;

typedef enum {
    CardDeckSwipeDirectionNone = 0,
    CardDeckSwipeDirectionLeft,
    CardDeckSwipeDirectionRight
} CardDeckSwipeDirection;

@interface RVCardDeckView : UIView <RVCardViewDelegate>

@property (weak, nonatomic) id <RVCardDeckViewDelegate> delegate;
@property (weak, nonatomic) id <RVCardDeckViewDataSourceDelegate> dataSource;

@property (readonly, nonatomic) BOOL isFullScreen;

- (void)reloadData;
- (void)animateIn:(void (^)())completion;

- (NSUInteger)indexForCardView:(RVCardView *)cardView;
- (RVCardView *)createCard;

- (void)enterFullScreen;
- (void)exitFullScreen;

@end

#pragma mark - CardDeckDataSourceDelegate

@protocol RVCardDeckViewDataSourceDelegate

- (NSUInteger)numberOfItemsInDeck:(RVCardDeckView *)cardDeck;
- (RVCardView *)cardDeck:(RVCardDeckView *)cardDeck cardViewForItemAtIndex:(NSUInteger)index;

@end

#pragma mark - CardDeckDelegate

@protocol RVCardDeckViewDelegate <NSObject>

- (void)cardDeckDidPressBackground:(RVCardDeckView *)cardDeck;

- (void)cardDeck:(RVCardDeckView *)cardDeck didSwipeCard:(RVCardView *)cardView;
- (void)cardDeck:(RVCardDeckView *)cardDeck didShowCard:(RVCardView *)cardView;
- (void)cardDeck:(RVCardDeckView *)cardDeck didLikeCard:(RVCardView *)cardView;
- (void)cardDeck:(RVCardDeckView *)cardDeck didUnlikeCard:(RVCardView *)cardView;
- (void)cardDeck:(RVCardDeckView *)cardDeck didDiscardCard:(RVCardView *)cardView;

@optional

- (void)cardDeckWillEnterFullScreen:(RVCardDeckView *)cardDeck;
- (void)cardDeckDidEnterFullScreen:(RVCardDeckView *)cardDeck;
- (void)cardDeckWillExitFullScreen:(RVCardDeckView *)cardDeck;
- (void)cardDeckDidExitFullScreen:(RVCardDeckView *)cardDeck;

@end
