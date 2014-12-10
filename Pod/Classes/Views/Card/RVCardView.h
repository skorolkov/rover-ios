//
//  RVCardView.h
//  Rover
//
//  Created by Sean Rucker on 2014-06-28.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RVCardBaseView.h"

@class RVMoreButton;
@class RVCardView;
@class RVCard;

@protocol RVCardViewDelegate <RVCardBaseViewDelegate>

@optional

- (void)cardViewCloseButtonPressed:(RVCardView *)cardView;

@end

@protocol RVCardViewActionDelegate <NSObject>

- (void)cardView:(RVCardView *)cardView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end


@interface RVCardView : RVCardBaseView


@property (weak, nonatomic) id <RVCardViewDelegate> delegate;
@property (weak, nonatomic) id <RVCardViewActionDelegate> actionDelegate;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIColor *fontColor;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *shortDescription;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSString *longDescription;
@property (strong, nonatomic) NSString *terms;
@property (strong, nonatomic) UIColor *secondaryBackgroundColor;
@property (strong, nonatomic) UIColor *secondaryFontColor;

@property (nonatomic) BOOL liked;
@property (nonatomic) BOOL discarded;

@property (nonatomic) BOOL useCloseButton;

@property (nonatomic, strong) RVCard *card;

// Subviews
@property (strong, nonatomic) UITextView *longDescriptionTextView;
@property (strong, nonatomic) UIView *termsView;
@property (strong, nonatomic) UILabel *termsLabel;
@property (strong, nonatomic) UILabel *termsTitle;
@property (strong, nonatomic) UIView *termsTitleView;
@property (strong, nonatomic) UIView *descriptionView;
@property (strong, nonatomic) UIView *barcodeView;
@property (strong, nonatomic) UILabel *shortDescriptionTextView;
@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UIFont *shortDescriptionFont;
@property (strong, nonatomic) UIFont *longDescriptionFont;
@property (strong, nonatomic) UIFont *barcodeInstructionFont;
@property (strong, nonatomic) UIFont *buttonTitleFont;

@property (nonatomic, readonly) CGFloat shortDescriptionHeight;

- (void)addButtonsWithTitles:(NSString *)firstButtonTitle, ... NS_REQUIRES_NIL_TERMINATION;
- (NSInteger)addButtonWithTitle:(NSString *)buttonTitle;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

@end

