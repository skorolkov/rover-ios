//
//  RVNextButton.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-04.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVNextButton.h"

@interface RVNextButton()

@property (strong, nonatomic) UILabel *label;

@end

@implementation RVNextButton

- (void)setColor:(UIColor *)color
{
    self.label.textColor = color;
    _color = color;
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text
{
    self.label.text = text;
}

- (NSString *)text
{
    return self.label.text;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        [self addSubviews];
        [self configureLayout];
        self.color = [UIColor whiteColor];
        self.text = @"Next";
    }
    return self;
}

- (void)addSubviews
{
    self.label = [UILabel new];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.font = [UIFont boldSystemFontOfSize:14.0];
    [self addSubview:self.label];
}

- (void)configureLayout
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(rect) + 1.0, CGRectGetMinY(rect) + 1.0, CGRectGetWidth(rect) - 2.0, CGRectGetHeight(rect) - 2.0) cornerRadius: (CGRectGetHeight(rect) - 2.0) / 2.0];
    [self.color setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
}

 @end