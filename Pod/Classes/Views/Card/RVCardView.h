//
//  RVCardView.h
//  Rover
//
//  Created by Sean Rucker on 2014-06-28.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RVCardViewButtonBar.h"
#import "RVCardBaseView.h"

@class RVMoreButton;
@class RVCardView;
@class RVCard;

@protocol RVCardViewDelegate <RVCardBaseViewDelegate>

@optional

- (void)cardViewLikeButtonPressed:(RVCardView *)cardView;
- (void)cardViewDiscardButtonPressed:(RVCardView *)cardView;
- (void)cardViewCloseButtonPressed:(RVCardView *)cardView;
- (void)cardViewBarcodeButtonPressed:(RVCardView *)cardView;

@end

@interface RVCardView : RVCardBaseView


@property (weak, nonatomic) id <RVCardViewDelegate> delegate;

@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSString *longDescription;
@property (nonatomic) CGFloat shadow;
@property (strong, nonatomic) UIColor *secondaryBackgroundColor;
@property (strong, nonatomic) UIColor *secondaryFontColor;

@property (nonatomic) BOOL liked;
@property (nonatomic) BOOL discarded;

@property (nonatomic) BOOL useCloseButton;

@property (nonatomic, strong) RVCard *card;

@end

