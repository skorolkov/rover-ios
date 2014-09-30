//
//  RVMoreButton.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-01.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVMoreButton.h"

@implementation RVMoreButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddArc(context, center.x, center.y, 25.0, 0.0, 180.0 * (M_PI / 180.0), 1);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.2);
    CGContextDrawPath(context, kCGPathFill);
    
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(center.x - 7.0, center.y - 13.0)];
    [bezierPath addLineToPoint:CGPointMake(center.x, center.y - 5.0)];
    [bezierPath addLineToPoint:CGPointMake(center.x + 7.0, center.y - 13.0)];
    [UIColor.whiteColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
}

@end
