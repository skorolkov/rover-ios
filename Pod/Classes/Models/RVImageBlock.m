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
@property (nonatomic, assign) CGFloat originalImageWidth;
@property (nonatomic, assign) CGFloat originalImageHeight;

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
    }
    
    // originalImageWidth
    NSNumber *originalImageWidth = [JSON objectForKey:@"imageWidth"];
    if (originalImageWidth && originalImageWidth != (id)[NSNull null]) {
        self.originalImageWidth = [originalImageWidth floatValue];
    }
    
    // originalImageHeight
    NSNumber *originalImageHeight = [JSON objectForKey:@"imageHeight"];
    if (originalImageHeight && originalImageHeight != (id)[NSNull null]) {
        self.originalImageHeight = [originalImageHeight floatValue];
    }
    
//    self.borderWidth = UIEdgeInsetsMake(1, 1, 1, 1);
//    self.borderColor = [UIColor yellowColor];
}

- (NSURL *)imageURL
{
    if (!self.imagePath) {
        return nil;
    }

    NSInteger imageWidth = [UIScreen mainScreen].bounds.size.width * UIScreen.mainScreen.scale;
    NSInteger imageHeight = self.originalImageWidth / _aspectRatio;
    
    NSURL *url;
    if (self.originalImageWidth && self.originalImageHeight) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?w=%ld&rect=0,%ld,%ld,%ld", self.imagePath, (long)imageWidth, (long)(-self.yOffset * self.originalImageHeight), (long)self.originalImageWidth, (long)imageHeight]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?w=%ld&h=%ld&fit=crop", self.imagePath, (long)imageWidth, (long)(imageWidth / _aspectRatio)]];
    }
    
    return url;
}

- (CGFloat)heightForWidth:(CGFloat)width {
    return [super heightForWidth:width] + round([self paddingAdjustedValueForWidth:width] / _aspectRatio);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.imagePath forKey:@"imagePath"];
    [encoder encodeObject:[NSNumber numberWithFloat:self.aspectRatio] forKey:@"aspectRatio"];
    [encoder encodeObject:[NSNumber numberWithFloat:self.yOffset] forKey:@"yOffset"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.imagePath = [decoder decodeObjectForKey:@"imagePath"];
        self.aspectRatio = [[decoder decodeObjectForKey:@"aspectRatio"] floatValue];
        self.yOffset = [[decoder decodeObjectForKey:@"yOffset"] floatValue];
    }
    return self;
}

@end
