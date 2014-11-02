//
//  RVCardBaseView.h
//  Rover
//
//  Created by Ata Namvari on 2014-10-13.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RVCardViewButtonBar.h"

@class RVCardViewButtonBar;
@protocol RVCardBaseViewDelegate;

@interface RVCardBaseView : UIView <RVCardViewButtonBarDelegate>

+ (CGFloat)contractedWidth;
+ (CGFloat)contractedHeight;

@property (weak, nonatomic) id <RVCardBaseViewDelegate> delegate;

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIColor *fontColor;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *shortDescription;

// Image view
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) RVCardViewButtonBar *buttonBar;

- (void)expandToFrame:(CGRect)frame animated:(BOOL)animated;
- (void)contractToFrame:(CGRect)frame atCenter:(CGPoint)center animated:(BOOL)animated;
- (void)didShow;

// For subclass user only
- (void)addSubviews;
- (void)configureLayout;
- (void)configureContainerLayout;
- (BOOL)isExpanded;
- (void)expandAnimations;
- (void)contractAnimations;
- (void)expandCompletion;
- (void)contractCompletion;

@end

@protocol RVCardBaseViewDelegate <NSObject>

@optional

- (void)cardViewDidExpand:(RVCardBaseView *)cardBaseView;
- (void)cardViewDidContract:(RVCardBaseView *)cardBaseView;
- (void)cardViewMoreButtonPressed:(RVCardBaseView *)cardView;


@end