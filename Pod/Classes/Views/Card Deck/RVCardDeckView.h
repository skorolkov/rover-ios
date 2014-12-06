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

@property (readonly, nonatomic) RVCardView *topCard;
@property (readonly, nonatomic) BOOL isFullScreen;
@property (assign, nonatomic) BOOL cardSwipeEnabled;

- (void)reloadData;
- (void)animateIn:(void (^)())completion;

- (NSUInteger)indexForCardView:(RVCardBaseView *)cardView;

- (void)enterFullScreen;
- (void)exitFullScreen;

- (void)swipeToNextCard;

@end

#pragma mark - CardDeckDataSourceDelegate

@protocol RVCardDeckViewDataSourceDelegate

- (NSUInteger)numberOfItemsInDeck:(RVCardDeckView *)cardDeck;
- (RVCardBaseView *)cardDeck:(RVCardDeckView *)cardDeck cardViewForItemAtIndex:(NSUInteger)index;

@end

#pragma mark - CardDeckDelegate

@protocol RVCardDeckViewDelegate <NSObject>


- (void)cardDeck:(RVCardDeckView *)cardDeck didSwipeCard:(RVCardBaseView *)cardView;
- (void)cardDeck:(RVCardDeckView *)cardDeck didShowCard:(RVCardBaseView *)cardView;

@optional

- (void)cardDeckDidPressBackground:(RVCardDeckView *)cardDeck;
- (void)cardDeckWillEnterFullScreen:(RVCardDeckView *)cardDeck;
- (void)cardDeckDidEnterFullScreen:(RVCardDeckView *)cardDeck;
- (void)cardDeckWillExitFullScreen:(RVCardDeckView *)cardDeck;
- (void)cardDeckDidExitFullScreen:(RVCardDeckView *)cardDeck;
- (void)cardDeckDidEnterBarcodeView:(RVCardDeckView *)cardDeck;

@end
