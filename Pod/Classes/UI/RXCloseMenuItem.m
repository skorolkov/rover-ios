//
//  RXCloseMenuItem.m
//  Pods
//
//  Created by Ata Namvari on 2015-06-24.
//
//

#import "RXCloseMenuItem.h"

@implementation RXCloseMenuItem

- (instancetype)init {
    self = [self initWithFrame:CGRectMake(0, 0, 45, 45)];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = frame.size.height / 2;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self drawCanvas1WithFrame:CGRectMake(14.5, 14.5, 16, 16)];
}

- (void)drawCanvas1WithFrame: (CGRect)frame
{
    //// Color Declarations
    UIColor* color0 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    
    //// Subframes
    CGRect cards = CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 15.97) * 0.00000 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 15.97) * 0.00000 + 0.47) + 0.03, 15.97, 15.97);
    
    
    //// Cards
    {
        //// Minimized-Default
        {
            //// close
            {
                //// Add Drawing
                UIBezierPath* addPath = UIBezierPath.bezierPath;
                [addPath moveToPoint: CGPointMake(CGRectGetMinX(cards) + 7.96, CGRectGetMinY(cards) + 9.23)];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards) + 1.22, CGRectGetMinY(cards) + 15.97)];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards), CGRectGetMinY(cards) + 14.75)];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards) + 6.74, CGRectGetMinY(cards) + 8.01)];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards) + 0.22, CGRectGetMinY(cards) + 1.49)];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards) + 1.49, CGRectGetMinY(cards) + 0.22)];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards) + 8.01, CGRectGetMinY(cards) + 6.74)];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards) + 14.75, CGRectGetMinY(cards))];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards) + 15.97, CGRectGetMinY(cards) + 1.22)];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards) + 9.23, CGRectGetMinY(cards) + 7.96)];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards) + 15.75, CGRectGetMinY(cards) + 14.48)];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards) + 14.48, CGRectGetMinY(cards) + 15.75)];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards) + 7.96, CGRectGetMinY(cards) + 9.23)];
                [addPath addLineToPoint: CGPointMake(CGRectGetMinX(cards) + 7.96, CGRectGetMinY(cards) + 9.23)];
                [addPath closePath];
                addPath.miterLimit = 4;
                
                addPath.usesEvenOddFillRule = YES;
                
                [color0 setFill];
                [addPath fill];
            }
        }
    }
}

@end
