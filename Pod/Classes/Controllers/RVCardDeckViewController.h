//
//  RVCardDeckViewController.h
//  Pods
//
//  Created by Ata Namvari on 2014-12-04.
//
//

#import <UIKit/UIKit.h>

@class RVCardDeckView;
@class RVModalView;
@class RVCardBaseView;

@interface RVCardDeckViewController : UIViewController

@property (strong, nonatomic) RVModalView *modalView;
@property (strong, nonatomic) RVCardDeckView *cardDeckView;
@property (nonatomic, strong) UIColor *backdropTintColor;
@property (nonatomic, assign) NSUInteger backdropBlurRadius;


#pragma mark - RVModalViewDelegate
- (void)modalViewBackgroundPressed:(RVModalView *)modalView;
- (void)modalViewCloseButtonPressed:(RVModalView *)modalView;
#pragma mark - RVCardDeckViewDelegate
- (void)cardDeck:(RVCardDeckView *)cardDeck didSwipeCard:(RVCardBaseView *)cardView;
- (void)cardDeck:(RVCardDeckView *)cardDeck didShowCard:(RVCardBaseView *)cardView;
- (void)cardDeckDidPressBackground:(RVCardDeckView *)cardDeck;
- (void)cardDeckWillEnterFullScreen:(RVCardDeckView *)cardDeck;
- (void)cardDeckDidEnterFullScreen:(RVCardDeckView *)cardDeck;
- (void)cardDeckWillExitFullScreen:(RVCardDeckView *)cardDeck;
- (void)cardDeckDidExitFullScreen:(RVCardDeckView *)cardDeck;
- (void)cardDeckDidEnterBarcodeView:(RVCardDeckView *)cardDeck;
#pragma mark - RVCardDeckViewDataSource
- (NSUInteger)numberOfItemsInDeck:(RVCardDeckView *)cardDeck;
- (RVCardBaseView *)cardDeck:(RVCardDeckView *)cardDeck cardViewForItemAtIndex:(NSUInteger)index;

@end
