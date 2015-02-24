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
    NSNumber *imageOffset = [JSON objectForKey:@"imageOffsetRatio"];
    if (imageOffset && imageOffset != (id)[NSNull null]) {
        self.yOffset = [imageOffset floatValue];
        NSLog(@"offset: %f", self.yOffset);
    }
    
    self.borderWidth = UIEdgeInsetsMake(1, 1, 1, 1);
    self.borderColor = [UIColor yellowColor];
}

- (NSURL *)imageURL
{
    if (!self.imagePath) {
        return nil;
    }

    NSInteger imageWidth = [UIScreen mainScreen].bounds.size.width * UIScreen.mainScreen.scale;
    NSInteger imageHeight = imageWidth / _aspectRatio;

    NSLog(@"offset: %f", self.yOffset);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?w=%ld&h=%ld&rect=0,%ld,%ld,%ld", self.imagePath, (long)imageWidth, (long)imageHeight, (long)(-self.yOffset * imageWidth), imageWidth, imageHeight]];

    NSLog(@"url: %@", url);
    return url;
}

- (CGFloat)heightForWidth:(CGFloat)width {
    return [super heightForWidth:width] + floor(width / _aspectRatio);
}

@end
