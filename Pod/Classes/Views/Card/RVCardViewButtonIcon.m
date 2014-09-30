//
//  RVHeartIcon.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-04.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardViewButtonIcon.h"

@implementation RVCardViewButtonIcon
{
    UIColor *_color;
}

- (void)setIconType:(RVCardViewButtonIconType)iconType
{
    _iconType = iconType;
    [self setNeedsDisplay];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

- (UIColor *)color
{
    if (!_color) {
        return [UIColor whiteColor];
    }
    
    return _color;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    switch (self.iconType) {
        case RVCardViewButtonIconTypeBang:
            [self drawBang:rect];
            break;
            
        default:
            [self drawHeart:rect];
            break;
    }
}

- (void)drawHeart:(CGRect)frame
{
    //// Subframes
    CGRect group = CGRectMake(CGRectGetMinX(frame) + 0.16, CGRectGetMinY(frame) + 0.82, CGRectGetWidth(frame) - 0.16, CGRectGetHeight(frame) - 0.82);
    
    
    //// Group
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.92639 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.50157 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.92639 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.08611 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 1.02454 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.38679 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 1.02454 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.20089 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.74451 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00004 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.87623 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.02749 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.81013 * CGRectGetWidth(group), CGRectGetMinY(group) + -0.00121 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.50095 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.14413 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.65256 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00186 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.50095 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.14413 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.25086 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00004 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.50095 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.14413 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.34508 * CGRectGetWidth(group), CGRectGetMinY(group) + -0.00014 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.07360 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.08611 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.18667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00018 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.12253 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.02881 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.07360 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.50157 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + -0.02451 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.20089 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + -0.02456 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.38679 * CGRectGetHeight(group))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.49999 * CGRectGetWidth(group), CGRectGetMinY(group) + 1.00000 * CGRectGetHeight(group))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.92639 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.50157 * CGRectGetHeight(group))];
        [bezierPath closePath];
        bezierPath.miterLimit = 4;
        
        [self.color setFill];
        [bezierPath fill];
    }
}

- (void)drawBang:(CGRect)frame;
{
    //// Subframes
    CGRect group = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame) - 0.5, CGRectGetHeight(frame) - 0.5);
    
    
    //// Group
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.50000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00000 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.50000 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.22385 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00000 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.22384 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.50000 * CGRectGetWidth(group), CGRectGetMinY(group) + 1.00000 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.77613 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.22385 * CGRectGetWidth(group), CGRectGetMinY(group) + 1.00000 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 1.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.50000 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.77616 * CGRectGetWidth(group), CGRectGetMinY(group) + 1.00000 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 1.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.77613 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.50000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00000 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 1.00000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.22384 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.77616 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.00000 * CGRectGetHeight(group))];
        [bezierPath closePath];
        [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.58073 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.75003 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.50000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.82889 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.58073 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.79457 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.54640 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.82889 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.41927 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.75003 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.45361 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.82889 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.41927 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.79457 * CGRectGetHeight(group))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.41927 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.74819 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.50000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.66933 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.41927 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.70366 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.45361 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.66933 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.58073 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.74819 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.54640 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.66933 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.58073 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.70366 * CGRectGetHeight(group))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.58073 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.75003 * CGRectGetHeight(group))];
        [bezierPath closePath];
        [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.58256 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.21840 * CGRectGetHeight(group))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.54267 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.56726 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.49999 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.60807 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.53989 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.59233 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.52319 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.60807 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.45730 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.56726 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.47679 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.60807 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.46010 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.59233 * CGRectGetHeight(group))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.41741 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.21840 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.45452 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.17108 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.41463 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.19150 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.42947 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.17108 * CGRectGetHeight(group))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.54544 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.17108 * CGRectGetHeight(group))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 0.58256 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.21840 * CGRectGetHeight(group)) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.57053 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.17108 * CGRectGetHeight(group)) controlPoint2: CGPointMake(CGRectGetMinX(group) + 0.58535 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.19150 * CGRectGetHeight(group))];
        [bezierPath closePath];
        bezierPath.miterLimit = 4;
        
        [self.color setFill];
        [bezierPath fill];
    }
}

@end
