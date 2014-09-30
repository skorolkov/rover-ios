//
//  RVColorUtilities.h
//  Rover
//
//  Created by Sean Rucker on 2014-08-08.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface RVColorUtilities : NSObject

+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (NSString *)hexStringFromColor:(UIColor *)color;

@end
