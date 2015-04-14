//
//  RVNotificationCenter.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-29.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVNotificationCenter.h"

@implementation RVNotificationCenter

+ (NSNotificationCenter *)defaultCenter {
    static RVNotificationCenter *defaultCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCenter = [[self alloc] init];
    });
    
    return defaultCenter;
}

@end
