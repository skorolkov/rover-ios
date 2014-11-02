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
@property (strong, nonatomic) UILabel *secondLabel;

@property (strong, nonatomic) NSLayoutConstraint *labelCenterXConstraint;
@property (strong, nonatomic) NSLayoutConstraint *labelTrailConstraint;
@property (strong, nonatomic) NSLayoutConstraint *secondLabelCenterXConstraint;
@property (strong, nonatomic) NSLayoutConstraint *secondLabelLeftConstraint;

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
    
}

- (UIColor *)color {
    if (!_color) {
        return [UIColor whiteColor];
    }
    return _color;
}

- (void)setActiveColor:(UIColor *)activeColor {
    _activeColor = activeColor;
    
}

- (UIColor *)activeColor {
    if (!_activeColor) {
        return [UIColor colorWithRed:239.0/255.0 green:58.0/255.0 blue:22.0/255.0 alpha:1.0];
    }
    return _activeColor;
}

- (void)setActive:(BOOL)active {
    if (active) {
        [self removeConstraints:@[self.labelCenterXConstraint, self.secondLabelLeftConstraint]];
        [self addConstraints:@[self.labelTrailConstraint, self.secondLabelCenterXConstraint]];
        
        [UIView animateWithDuration:0.1 animations:^{
            [self layoutIfNeeded];
            self.shadow.alpha = 1.0;
        }];
    } else {
        [self removeConstraints:@[self.labelTrailConstraint, self.secondLabelCenterXConstraint]];
        [self addConstraints:@[self.labelCenterXConstraint, self.secondLabelLeftConstraint]];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
            self.shadow.alpha = 0.0;
        }];
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
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)addSubviews {
    self.shadow = [UIView new];
    self.shadow.translatesAutoresizingMaskIntoConstraints = NO;
    self.shadow.userInteractionEnabled = NO;
    self.shadow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [self addSubview:self.shadow];
    
    self.label = [UILabel new];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.userInteractionEnabled = NO;
    self.label.font = [UIFont systemFontOfSize:14.0];
    self.label.textColor = self.color;
    [self addSubview:self.label];
    
    self.secondLabel = [UILabel new];
    self.secondLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.secondLabel.userInteractionEnabled = NO;
    self.secondLabel.font = [UIFont systemFontOfSize:14];
    self.secondLabel.textColor = self.color;
    [self addSubview:self.secondLabel];
}

- (void)configureLayout {
    NSDictionary *views = @{ @"shadow": self.shadow,
                             @"label": self.label };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[shadow]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[shadow]|" options:0 metrics:nil views:views]];
    
    self.labelCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    self.labelTrailConstraint = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    
    [self addConstraint:self.labelCenterXConstraint];
    
    self.secondLabelCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.secondLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    self.secondLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.secondLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    
    [self addConstraint:self.secondLabelLeftConstraint];
    
    
    // Center the label vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.secondLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    if (state == UIControlStateSelected) {
        [self.secondLabel setText:title];
    } else {
        [self.label setText:title];
    }
}

- (void)setSelected:(BOOL)selected
{
    self.active = selected;
}

@end
