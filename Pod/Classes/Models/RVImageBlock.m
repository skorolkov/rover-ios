//
//  RVImageBlock.m
//  Pods
//
//  Created by Ata Namvari on 2015-02-18.
//
//

#import "RVImageBlock.h"
#import "RVModelProject.h"


@interface RVImageBlock ()

@property (nonatomic, strong) NSString *imagePath;

@end

@implementation RVImageBlock

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    
    // imagePath
    NSString *imagePath = [JSON objectForKey:@"imageUrl"];
    if (imagePath && imagePath != (id)[NSNull null]) {
        self.imagePath = imagePath;
    }
    
    // imageAspectRatio
    NSNumber *aspectRatio = [JSON objectForKey:@"imageAspectRatio"];
    if (aspectRatio && aspectRatio != (id)[NSNull null]) {
        self.aspectRatio = [aspectRatio floatValue];
    }
    
    // imageOffset
    NSNumber *imageOffset = [JSON objectForKey:@"imageOffset"];
    if (imageOffset && imageOffset != (id)[NSNull null]) {
        self.yOffset = [imageOffset floatValue];
    }
    
}

- (NSURL *)imageURL
{
    if (!self.imagePath) {
        return nil;
    }

    NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width * UIScreen.mainScreen.scale;
    NSInteger screenHeight;

    switch (screenWidth) {
        case 750:
            screenHeight = 469;
            break;
        case 1242:
            screenHeight = 776;
            break;
        default: {
            screenWidth = 640;
            screenHeight = 400;
        }
            break;
    }

    // TODO: make an exception for gifs
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?w=%ld&h=%ld&fit=crop&fm=jpg", self.imagePath, (long)screenWidth, (long)screenHeight]];

    return url;
}

- (CGFloat)heightForWidth:(CGFloat)width {
    return [super heightForWidth:width] + (width / _aspectRatio);
}

@end
