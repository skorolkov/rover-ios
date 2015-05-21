//
//  RVBackgroundImage.m
//  Pods
//
//  Created by Ata Namvari on 2015-03-05.
//
//

#import "RVBackgroundImage.h"

extern inline RVBackgroundContentMode RVBackgroundContentModeFromString(NSString *string) {
    if ([string isEqualToString:@"stretch"]) {
        return RVBackgroundContentModeScaleFill;
    } else if ([string isEqualToString:@"tile"]) {
        return RVBackgroundContentModeTile;
    } else if ([string isEqualToString:@"fill"]) {
        return RVBackgroundContentModeScaleAspectFill;
    } else if ([string isEqualToString:@"fit"]) {
        return RVBackgroundContentModeScaleAspectFit;
    }
    return RVBackgroundContentModeOriginalSize;
}

extern inline UIViewContentMode UIViewContentModeFromRVBackgroundContentMode(RVBackgroundContentMode backgroundContentMode) {
    switch (backgroundContentMode) {
        case RVBackgroundContentModeScaleAspectFill:
            return UIViewContentModeScaleAspectFill;
            break;
        case RVBackgroundContentModeScaleAspectFit:
            return UIViewContentModeScaleAspectFit;
            break;
        case RVBackgroundContentModeScaleFill:
            return UIViewContentModeScaleToFill;
            break;
        default:
            return UIViewContentModeCenter;
            break;
    }
}