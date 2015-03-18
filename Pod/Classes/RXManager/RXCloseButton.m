//
//  RXCloseButton.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-28.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RXCloseButton.h"

CGFloat const kWidth = 22.0;
CGFloat const kHeight = 22.0;

@implementation RXCloseButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.color = [UIColor whiteColor];
        [self sizeToFit];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(kWidth, kHeight);
}

- (void)drawRect:(CGRect)rect
{
    CGPoint offset = CGPointMake((rect.size.width - kWidth) / 2, (rect.size.height - kHeight) / 2);
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(offset.x + 0.5, offset.y + 0.5, kWidth - 1.0, kWidth - 1.0)];
    [self.color setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(offset.x + 7.5, offset.y + 7.5)];
    [bezierPath addLineToPoint:CGPointMake(offset.x + kWidth - 7.5, offset.y + kHeight - 7.5)];
    [self.color setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(offset.x + kWidth - 7.5, offset.y + 7.5)];
    [bezier2Path addLineToPoint:CGPointMake(offset.x + 7.5, offset.y + kHeight - 7.5)];
    [self.color setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
}

@end
