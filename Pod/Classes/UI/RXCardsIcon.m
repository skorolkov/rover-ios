//
//  RXCardsIcon.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-26.
//
//

#import "RXCardsIcon.h"

@implementation RXCardsIcon

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //// Color Declarations
    UIColor* color0 = [UIColor colorWithRed: 0.27 green: 0.472 blue: 0.745 alpha: 1];
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = UIBezierPath.bezierPath;
    [bezier4Path moveToPoint: CGPointMake(36, 11)];
    [bezier4Path addLineToPoint: CGPointMake(34, 11)];
    [bezier4Path addLineToPoint: CGPointMake(34, 8)];
    [bezier4Path addCurveToPoint: CGPointMake(32, 5) controlPoint1: CGPointMake(34, 6.66) controlPoint2: CGPointMake(33.18, 5.21)];
    [bezier4Path addCurveToPoint: CGPointMake(32, 5) controlPoint1: CGPointMake(32, 4.89) controlPoint2: CGPointMake(32, 5.16)];
    [bezier4Path addLineToPoint: CGPointMake(32, 2.5)];
    [bezier4Path addCurveToPoint: CGPointMake(29.31, 0) controlPoint1: CGPointMake(32, 1) controlPoint2: CGPointMake(30.7, 0)];
    [bezier4Path addLineToPoint: CGPointMake(9, 0)];
    [bezier4Path addCurveToPoint: CGPointMake(6, 2.5) controlPoint1: CGPointMake(7.62, 0) controlPoint2: CGPointMake(6, 1)];
    [bezier4Path addLineToPoint: CGPointMake(6, 5)];
    [bezier4Path addCurveToPoint: CGPointMake(6, 5) controlPoint1: CGPointMake(6, 5.11) controlPoint2: CGPointMake(5.95, 4.84)];
    [bezier4Path addCurveToPoint: CGPointMake(4, 8) controlPoint1: CGPointMake(4.82, 5.21) controlPoint2: CGPointMake(4, 6.66)];
    [bezier4Path addLineToPoint: CGPointMake(4, 11)];
    [bezier4Path addLineToPoint: CGPointMake(2, 11)];
    [bezier4Path addCurveToPoint: CGPointMake(0, 13.38) controlPoint1: CGPointMake(0.62, 11) controlPoint2: CGPointMake(0, 11.88)];
    [bezier4Path addLineToPoint: CGPointMake(0, 35.32)];
    [bezier4Path addCurveToPoint: CGPointMake(2.47, 38) controlPoint1: CGPointMake(0, 36.82) controlPoint2: CGPointMake(1.09, 38)];
    [bezier4Path addLineToPoint: CGPointMake(35.53, 38)];
    [bezier4Path addCurveToPoint: CGPointMake(38, 35.32) controlPoint1: CGPointMake(36.91, 38) controlPoint2: CGPointMake(38, 36.82)];
    [bezier4Path addLineToPoint: CGPointMake(38, 13.38)];
    [bezier4Path addCurveToPoint: CGPointMake(36, 11) controlPoint1: CGPointMake(38, 11.88) controlPoint2: CGPointMake(37.38, 11)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(9, 3)];
    [bezier4Path addLineToPoint: CGPointMake(29, 3)];
    [bezier4Path addLineToPoint: CGPointMake(29, 5)];
    [bezier4Path addLineToPoint: CGPointMake(9, 5)];
    [bezier4Path addLineToPoint: CGPointMake(9, 3)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(7, 8)];
    [bezier4Path addLineToPoint: CGPointMake(31, 8)];
    [bezier4Path addLineToPoint: CGPointMake(31, 11)];
    [bezier4Path addLineToPoint: CGPointMake(7, 11)];
    [bezier4Path addLineToPoint: CGPointMake(7, 8)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(35, 35)];
    [bezier4Path addLineToPoint: CGPointMake(3, 35)];
    [bezier4Path addLineToPoint: CGPointMake(3, 14)];
    [bezier4Path addLineToPoint: CGPointMake(7, 14)];
    [bezier4Path addLineToPoint: CGPointMake(31, 14)];
    [bezier4Path addLineToPoint: CGPointMake(35, 14)];
    [bezier4Path addLineToPoint: CGPointMake(35, 35)];
    [bezier4Path closePath];
    bezier4Path.miterLimit = 4;
    
    [color0 setFill];
    [bezier4Path fill];
}

@end
