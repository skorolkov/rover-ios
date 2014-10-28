//
//  RVCardViewButtonBar.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-04.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardViewButtonBar.h"

@interface RVCardViewButtonBar()

@property (strong, nonatomic) UIView *buttonDivider;

@property (strong, nonatomic) NSArray *buttonsConstraints;

@end

@implementation RVCardViewButtonBar

#pragma mark - Properties

- (void)setFontColor:(UIColor *)fontColor {
    self.buttonDivider.backgroundColor = fontColor;
    [self.leftButton setTitleColor:fontColor forState:UIControlStateNormal];
    [self.rightButton setTitleColor:fontColor forState:UIControlStateNormal];
    _fontColor = fontColor;
}

- (void)setLeftButtonTitle:(NSString *)leftButtonTitle andRightButtonTitle:(NSString *)rightButtonTitle
{
    if (leftButtonTitle) {
        self.leftButton = [UIButton new];
        self.leftButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.leftButton setTitle:leftButtonTitle forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(leftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftButton];
    } else {
        self.leftButton = nil;
    }
    
    if (rightButtonTitle) {
        self.rightButton = [UIButton new];
        self.rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightButton setTitle:rightButtonTitle forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(rightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightButton];
        
        self.buttonDivider = [UIView new];
        self.buttonDivider.translatesAutoresizingMaskIntoConstraints = NO;
        self.buttonDivider.backgroundColor = [UIColor whiteColor];
        self.buttonDivider.alpha = 0.2;
        [self addSubview:self.buttonDivider];
    } else {
        self.rightButton = nil;
    }
    
    [self configureLayout];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.fontColor = [UIColor whiteColor];
    }
    return self;
}

- (void)configureLayout
{

    [self removeConstraints:self.constraints];
    
    if (self.leftButton && self.rightButton) {
        NSDictionary *views = @{ @"buttonDivider": self.buttonDivider,
                                 @"leftButton": self.leftButton,
                                 @"rightButton": self.rightButton };
        
        NSDictionary *attributes = @{NSFontAttributeName: self.leftButton.titleLabel.font};
        CGSize size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        
        CGFloat leftButtonMinWidth = [[self leftButtonTitle] boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
        
        CGFloat rightButtonMinWidth = [[self rightButtonTitle] boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
        
        // Layout the buttons and divider horizontally
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|[leftButton(>=%f)][buttonDivider(1)][rightButton(>=%f@750)]|", leftButtonMinWidth + 40.0, rightButtonMinWidth + 40.0] options:0 metrics:nil views:views]];
        
        NSLayoutConstraint *rightButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:self.rightButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.leftButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0];
        rightButtonWidthConstraint.priority = 500;
        
        [self addConstraint:rightButtonWidthConstraint];
        
        // She the buttons and divider to fill the bar vertiacally
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftButton]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[buttonDivider]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightButton]|" options:0 metrics:nil views:views]];
    } else if (self.leftButton) {
        NSDictionary *views = @{@"leftButton": self.leftButton};
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[leftButton]|" options:0 metrics:nil views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftButton]|" options:0 metrics:nil views:views]];
    }

    

}

#pragma mark - Actions

- (void)leftButtonPressed {
    if (self.delegate) {
        [self.delegate buttonBarLeftButtonPressed:self];
    }
}

- (void)rightButtonPressed
{
    if (self.delegate) {
        [self.delegate buttonBarRightButtonPressed:self];
    }
}

#pragma mark - ButtonTitles

- (NSString *)leftButtonTitle
{
    return self.leftButton.titleLabel.text;
}

- (NSString *)rightButtonTitle
{
    return self.rightButton.titleLabel.text;
}

- (void)setLeftButtonTitle:(NSString *)leftButtonTitle
{
    [self.leftButton setTitle:leftButtonTitle forState:UIControlStateNormal];
}

- (void)setRightButtonTitle:(NSString *)rightButtonTitle
{
    [self.rightButton setTitle:rightButtonTitle forState:UIControlStateNormal];
}

@end
