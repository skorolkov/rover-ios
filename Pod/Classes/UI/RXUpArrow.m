//
//  RXUpArrow.m
//  Pods
//
//  Created by Ata Namvari on 2015-03-17.
//
//

#import "RXUpArrow.h"

@implementation RXUpArrow


- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(40, 40);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Arrow Drawing
    CGContextSaveGState(context);
    CGContextScaleCTM(context, 0.5, 0.5);
    
    UIBezierPath* arrowPath = UIBezierPath.bezierPath;
    [arrowPath moveToPoint: CGPointMake(10, 4)];
    [arrowPath addLineToPoint: CGPointMake(10, 22)];
    [arrowPath addLineToPoint: CGPointMake(11.9, 22)];
    [arrowPath addLineToPoint: CGPointMake(12, 4)];
    [arrowPath addLineToPoint: CGPointMake(20.4, 12.41)];
    [arrowPath addLineToPoint: CGPointMake(21.8, 11)];
    [arrowPath addLineToPoint: CGPointMake(11, 0.1)];
    [arrowPath addLineToPoint: CGPointMake(10.9, 0)];
    [arrowPath addLineToPoint: CGPointMake(10.7, 0.1)];
    [arrowPath addLineToPoint: CGPointMake(0, 11)];
    [arrowPath addLineToPoint: CGPointMake(1.4, 12.41)];
    [arrowPath addLineToPoint: CGPointMake(10, 4)];
    [arrowPath closePath];
    arrowPath.miterLimit = 4;
    
    arrowPath.usesEvenOddFillRule = YES;
    
    [UIColor.whiteColor setFill];
    [arrowPath fill];
    
    CGContextRestoreGState(context);
}

@end
