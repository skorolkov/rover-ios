//
//  RVCardViewCorner.m
//  Rover
//
//  Created by Sean Rucker on 2014-08-06.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardViewCorner.h"
#import "RVCardViewButtonIcon.h"

@implementation RVCardViewCorner
{
    UIColor *_backgroundColor;
    UIColor *_iconColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self setNeedsDisplay];
}

- (UIColor *)backgroundColor {
    if (!_backgroundColor) {
        return [UIColor colorWithRed:239.0/255.0 green:58.0/255.0 blue:22.0/255.0 alpha:1.0];
    }
    
    return _backgroundColor;
}

- (void)setIconColor:(UIColor *)iconColor {
    self.icon.color = iconColor;
    _iconColor = iconColor;
}

- (UIColor *)iconColor {
    if (!_iconColor) {
        return [UIColor whiteColor];
    }
    
    return _iconColor;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubviews];
        [self configureLayout];
        self.opaque = NO;
    }
    return self;
}

- (void)createSubviews {
    self.icon = [RVCardViewButtonIcon new];
    self.icon.translatesAutoresizingMaskIntoConstraints = NO;
    self.icon.userInteractionEnabled = NO;
    [self addSubview:self.icon];
}

- (void)configureLayout {
    NSDictionary *views = @{ @"icon": self.icon };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[icon(16)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[icon(16)]" options:0 metrics:nil views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.icon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.5 constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.icon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.75 constant:0.0]];
}

- (void)drawRect:(CGRect)rect {
    [self drawBezier:rect];
}

- (void)drawBezier:(CGRect)frame {
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))];
    [bezierPath closePath];
    [self.backgroundColor setFill];
    [bezierPath fill];
}

@end
