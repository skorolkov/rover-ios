//
//  RXConfig.m
//  Pods
//
//  Created by Ata Namvari on 2015-04-09.
//
//

#import "RXConfig.h"

@implementation RXConfig

+ (instancetype)defaultConfig {
    RXConfig *config = [[RXConfig alloc] init];
    config.modalBackdropBlurRadius = 3;
    config.modalBackdropTintColor = [UIColor colorWithWhite:0.0 alpha:0.5];

    return config;
}

@end
