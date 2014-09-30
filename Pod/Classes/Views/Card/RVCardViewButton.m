//
//  RVCardViewButton.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-04.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardViewButton.h"
#import "RVCardViewButtonIcon.h"

@interface RVCardViewButton ()

@property (strong, nonatomic) UIView *shadow;

@end

@implementation RVCardViewButton
{
    UIColor *_color;
    UIColor *_activeColor;
}

#pragma mark - Properties

- (void)setColor:(UIColor *)color {
    _color = color;
    
    self.label.textColor = color;
    
    if (!self.active) {
        self.icon.color = color;
    }
}

- (UIColor *)color {
    if (!_color) {
        return [UIColor whiteColor];
    }
    return _color;
}

- (void)setActiveColor:(UIColor *)activeColor {
    _activeColor = activeColor;
    
    if (self.active) {
        self.icon.color = activeColor;
    }
}

- (UIColor *)activeColor {
    if (!_activeColor) {
        return [UIColor colorWithRed:239.0/255.0 green:58.0/255.0 blue:22.0/255.0 alpha:1.0];
    }
    return _activeColor;
}

- (void)setActive:(BOOL)active {
    if (active) {
        self.shadow.alpha = 1.0;
        self.icon.color = self.activeColor;
    } else {
        self.shadow.alpha = 0.0;
        self.icon.color = self.color;
    }
    _active = active;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        [self configureLayout];
        self.active = NO;
    }
    return self;
}

- (void)addSubviews {
    self.shadow = [UIView new];
    self.shadow.translatesAutoresizingMaskIntoConstraints = NO;
    self.shadow.userInteractionEnabled = NO;
    self.shadow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [self addSubview:self.shadow];
    
    self.icon = [RVCardViewButtonIcon new];
    self.icon.translatesAutoresizingMaskIntoConstraints = NO;
    self.icon.userInteractionEnabled = NO;
    [self addSubview:self.icon];
    
    self.label = [UILabel new];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.userInteractionEnabled = NO;
    self.label.font = [UIFont boldSystemFontOfSize:14.0];
    [self addSubview:self.label];
}

- (void)configureLayout {
    NSDictionary *views = @{ @"shadow": self.shadow,
                             @"icon": self.icon,
                             @"label": self.label };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[shadow]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[shadow]|" options:0 metrics:nil views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-18-[icon(16)]-10-[label]" options:0 metrics:nil views:views]];
    
    // Center the icon vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.icon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // Center the label vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[icon(16)]" options:0 metrics:nil views:views]];
}

@end
