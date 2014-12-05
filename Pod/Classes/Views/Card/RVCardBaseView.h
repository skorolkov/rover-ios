//
//  RVCardBaseView.h
//  Rover
//
//  Created by Ata Namvari on 2014-10-13.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RVCardBaseViewDelegate;

@interface RVCardBaseView : UIView


@property (weak, nonatomic) id <RVCardBaseViewDelegate> delegate;

// Constraints
@property (strong, nonatomic) NSLayoutConstraint *containerViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *containerViewHeightConstraint;

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *containerView;
@property (nonatomic) CGFloat shadow;

- (CGFloat)contractedWidth;
- (CGFloat)contractedHeight;

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

+ (UIImage *)barcodeImageForCode:(NSString *)code type:(NSString *)type;

@end

@protocol RVCardBaseViewDelegate <NSObject>

@optional

- (void)cardViewDidExpand:(RVCardBaseView *)cardBaseView;
- (void)cardViewDidContract:(RVCardBaseView *)cardBaseView;
- (void)cardViewMoreButtonPressed:(RVCardBaseView *)cardView;


@end