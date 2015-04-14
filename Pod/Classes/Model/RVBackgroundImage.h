//
//  RVBackgroundImage.h
//  Pods
//
//  Created by Ata Namvari on 2015-03-05.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RVBackgroundContentMode) {
    RVBackgroundContentModeOriginalSize = 0,
    RVBackgroundContentModeScaleFill = 1,
    RVBackgroundContentModeTile = 2,
    RVBackgroundContentModeScaleAspectFill = 3,
    RVBackgroundContentModeScaleAspectFit = 4
};

extern RVBackgroundContentMode RVBackgroundContentModeFromString(NSString *string);
extern UIViewContentMode UIViewContentModeFromRVBackgroundContentMode(RVBackgroundContentMode backgroundContentMode);

@protocol RVBackgroundImage <NSObject>

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) NSURL *backgroundImageURL;
@property (nonatomic, assign) RVBackgroundContentMode backgroundContentMode;

@end