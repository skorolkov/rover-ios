//
//  RVCardViewButtonBar.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-04.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardViewButtonBar.h"
#import "RVCardViewButton.h"
#import "RVCardViewButtonIcon.h"

CGFloat const kRVCardViewButtonBarCondensedWidth = 53.0;

@interface RVCardViewButtonBar()

@property (strong, nonatomic) RVCardViewButton *leftButton;
@property (strong, nonatomic) RVCardViewButton *rightButton;

@property (strong, nonatomic) UIView *buttonDivider;
@property (strong, nonatomic) NSLayoutConstraint *rightButtonWidthConstraint;
@property (nonatomic) BOOL rightButtonCondensed;

@end

@implementation RVCardViewButtonBar

#pragma mark - Properties

- (void)setFontColor:(UIColor *)fontColor {
    self.buttonDivider.backgroundColor = fontColor;
    self.leftButton.color = fontColor;
    self.rightButton.color = fontColor;
    _fontColor = fontColor;
}

- (void)setActiveColor:(UIColor *)activeColor {
    self.leftButton.activeColor = activeColor;
    self.rightButton.activeColor = activeColor;
    _activeColor = activeColor;
}

- (void)setLeftButtonActivated:(BOOL)leftButtonActivated {
    self.leftButton.active = leftButtonActivated;
    
    if (leftButtonActivated) {
        self.rightButton.active = NO;
    }
    
    _leftButtonActivated = leftButtonActivated;
}

- (void)setRightButtonActivated:(BOOL)rightButtonActivated {
    self.rightButton.active = rightButtonActivated;
    
    if (rightButtonActivated) {
        self.leftButton.active = NO;
    }
    
    _rightButtonActivated = rightButtonActivated;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.rightButtonCondensed = YES;
        [self addSubviews];
        [self configureLayout];
        self.fontColor = [UIColor whiteColor];
    }
    return self;
}

- (void)addSubviews
{
    self.leftButton = [RVCardViewButton new];
    self.leftButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.leftButton.icon.iconType = RVCardViewButtonIconTypeHeart;
    self.leftButton.label.text = @"Favourite";
    [self.leftButton addTarget:self action:@selector(leftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftButton];
        
    self.rightButton = [RVCardViewButton new];
    self.rightButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightButton.icon.iconType = RVCardViewButtonIconTypeBang;
    self.rightButton.label.text = @"Not Relevant";
    self.rightButton.label.alpha = 0.0;
    [self.rightButton addTarget:self action:@selector(rightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rightButton];
    
    self.buttonDivider = [UIView new];
    self.buttonDivider.translatesAutoresizingMaskIntoConstraints = NO;
    self.buttonDivider.backgroundColor = [UIColor whiteColor];
    self.buttonDivider.alpha = 0.2;
    [self addSubview:self.buttonDivider];
}

- (void)configureLayout
{
    NSDictionary *views = @{ @"buttonDivider": self.buttonDivider,
                             @"leftButton": self.leftButton,
                             @"rightButton": self.rightButton };
    
    // Layout the buttons and divider horizontally
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[leftButton][buttonDivider(1)][rightButton]|" options:0 metrics:nil views:views]];
    
    // Set the right button width
    self.rightButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:self.rightButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:kRVCardViewButtonBarCondensedWidth];
    [self addConstraint:self.rightButtonWidthConstraint];
    
    // She the buttons and divider to fill the bar vertiacally
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftButton]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[buttonDivider]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightButton]|" options:0 metrics:nil views:views]];
}

#pragma mark - Actions

- (void)leftButtonPressed {
    if (self.rightButtonCondensed) {
        if (self.delegate) {
            [self.delegate buttonBarLeftButtonPressed:self];
        }
    } else {
        self.rightButtonWidthConstraint.constant = kRVCardViewButtonBarCondensedWidth;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self layoutIfNeeded];
            self.leftButton.label.alpha = 1.0;
            self.rightButton.label.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.rightButtonCondensed = YES;
        }];
    }
}

- (void)rightButtonPressed
{
    if (self.rightButtonCondensed) {
        self.rightButtonWidthConstraint.constant = self.leftButton.frame.size.width;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self layoutIfNeeded];
            self.leftButton.label.alpha = 0.0;
            self.rightButton.label.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.rightButtonCondensed = NO;
        }];
    } else {
        if (self.delegate) {
            [self.delegate buttonBarRightButtonPressed:self];
        }
    }
}

@end
