//
//  RVCardView.h
//  Rover
//
//  Created by Sean Rucker on 2014-06-28.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RVCardViewButtonBar.h"

@class RVMoreButton;
@protocol RVCardViewDelegate;

@interface RVCardView : UIView <RVCardViewButtonBarDelegate>

+ (CGFloat)contractedWidth;
+ (CGFloat)contractedHeight;

@property (weak, nonatomic) id <RVCardViewDelegate> delegate;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *shortDescription;
@property (strong, nonatomic) NSString *longDescription;
@property (strong, nonatomic) NSURL *imageURL;

@property (nonatomic) CGFloat shadow;
@property (strong, nonatomic) UIColor *fontColor;
@property (strong, nonatomic) UIColor *secondaryBackgroundColor;
@property (strong, nonatomic) UIColor *secondaryFontColor;
@property (readonly, nonatomic) BOOL isExpanded;

@property (nonatomic) BOOL liked;
@property (nonatomic) BOOL discarded;

@property (nonatomic) BOOL useCloseButton;

- (void)expandToFrame:(CGRect)frame;
- (void)contractToFrame:(CGRect)frame atCenter:(CGPoint)center;
- (void)didShow;

@end

@protocol RVCardViewDelegate <NSObject>

@optional

- (void)cardViewMoreButtonPressed:(RVCardView *)cardView;
- (void)cardViewLikeButtonPressed:(RVCardView *)cardView;
- (void)cardViewDiscardButtonPressed:(RVCardView *)cardView;
- (void)cardViewCloseButtonPressed:(RVCardView *)cardView;

- (void)cardViewDidExpand:(RVCardView *)cardView;
- (void)cardViewDidContract:(RVCardView *)cardView;

@end