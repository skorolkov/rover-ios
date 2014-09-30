//
//  RVColorUtilities.m
//  Rover
//
//  Created by Sean Rucker on 2014-08-08.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVColorUtilities.h"

@implementation RVColorUtilities

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString *)hexStringFromColor:(UIColor *)color {
    CGFloat fRed, fGreen, fBlue;
    [color getRed:&fRed green:&fGreen blue:&fBlue alpha:NULL];
    
    int iRed = (int)(255.0 * fRed);
    int iGreen = (int)(255.0 * fGreen);
    int iBlue = (int)(255.0 * fBlue);
    
    return [NSString stringWithFormat:@"%02X%02X%02X", iRed, iGreen, iBlue];
}

@end
