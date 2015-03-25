//
//  RVBlock.m
//  Pods
//
//  Created by Ata Namvari on 2015-02-12.
//
//

#import "RVBlock.h"
#import "RVModelProject.h"

#import "RVHeaderBlock.h"
#import "RVTextBlock.h"
#import "RVImageBlock.h"
#import "RVBarcodeBlock.h"
#import "RVButtonBlock.h"

NSString *const sRVBlockImageType = @"imageBlock";
NSString *const sRVBlockTextType = @"textBlock";
NSString *const sRVBlockBarcodeType = @"barcodeBlock";
NSString *const sRVBlockButtonType = @"buttonBlock";
NSString *const sRVBlockHeaderType = @"headerBlock";

@interface RVBlock ()


@end

@implementation RVBlock

@synthesize backgroundColor, backgroundImageURL, backgroundContentMode;

+ (RVBlock *)appropriateBlockWithJSON:(NSDictionary *)JSON {

    NSString *blockTypeString = [JSON objectForKey:@"type"];
    if (blockTypeString && blockTypeString != (id)[NSNull null]) {
        if ([blockTypeString isEqualToString:sRVBlockImageType]) {
            return [[RVImageBlock alloc] initWithJSON:JSON];
            //blockType = RVBlockImageType;
        } else if ([blockTypeString isEqualToString:sRVBlockTextType]) {
            return [[RVTextBlock alloc] initWithJSON:JSON];
            //blockType = RVBlockTextType;
        } else if ([blockTypeString isEqualToString:sRVBlockBarcodeType]) {
            return [[RVBarcodeBlock alloc] initWithJSON:JSON];
            //blockType = RVBlockBarcodeType;
        } else if ([blockTypeString isEqualToString:sRVBlockButtonType]) {
            return [[RVButtonBlock alloc] initWithJSON:JSON];
            //blockType = RVBlockButtonType;
        } else if ([blockTypeString isEqualToString:sRVBlockHeaderType]) {
            return [[RVHeaderBlock alloc] initWithJSON:JSON];
            //blockType = RVBlockHeaderType;
        } else {
            NSLog(@"RVBlock - Invalid block type: '%@'", blockTypeString);
        }
    } else {
        NSLog(@"Warning: RVBlock - no type");
    }
 
    return nil;
}

#pragma mark - Overridden Methods

- (NSString *)modelName {
    return @"block";
}

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    
    // backgroundColor
    NSArray *backgroundColorArray = [JSON objectForKey:@"backgroundColor"];
    if (backgroundColorArray && backgroundColorArray != (id)[NSNull null]) {
        self.backgroundColor = [UIColor colorWithRed:[backgroundColorArray[0] floatValue]/255.f green:[backgroundColorArray[1] floatValue]/255.f blue:[backgroundColorArray[2] floatValue]/255.f alpha:[backgroundColorArray[3] floatValue]];
    }
    
    // borderColor
    NSArray *borderColor = [JSON objectForKey:@"borderColor"];
    if (borderColor && borderColor != (id)[NSNull null]) {
        self.borderColor = [UIColor colorWithRed:[borderColor[0] floatValue]/255.f green:[borderColor[1] floatValue]/255.f blue:[borderColor[2] floatValue]/255.f alpha:[borderColor[3] floatValue]];
    }
    
    // padding
    NSArray *padding = [JSON objectForKey:@"padding"];
    if (padding && borderColor != (id)[NSNull null]) {
        self.padding = UIEdgeInsetsMake([padding[0] floatValue], [padding[3] floatValue], [padding[2] floatValue], [padding[1] floatValue]);
    }
    
    // borderWidth
    NSArray *borderWidth = [JSON objectForKey:@"borderWidth"];
    if (borderWidth && borderWidth != (id)[NSNull null]) {
        self.borderWidth = UIEdgeInsetsMake([borderWidth[0] floatValue], [borderWidth[3] floatValue], [borderWidth[2] floatValue], [borderWidth[1] floatValue]);
    }
    
    // link
    NSString *linkURLString = [JSON objectForKey:@"url"];
    if (linkURLString && linkURLString != (id)[NSNull null]) {
        self.url = [NSURL URLWithString:linkURLString];
    }
    
    // backgroundImageUrl
    NSString *backgroundImageUrl = [JSON objectForKey:@"backgroundImageUrl"];
    if (backgroundImageUrl && backgroundImageUrl != (id)[NSNull null]) {
        self.backgroundImageURL = [NSURL URLWithString:backgroundImageUrl];
    }
    
    // backgroundContentMode
    NSString *backgroundContentModeString = [JSON objectForKey:@"backgroundContentMode"];
    if (backgroundContentModeString && backgroundContentModeString != (id)[NSNull null]) {
        self.backgroundContentMode = RVBackgroundContentModeFromString(backgroundContentModeString);
    }
}

- (CGFloat)heightForWidth:(CGFloat)width {
    return _padding.top + _padding.bottom;
}

- (CGFloat)paddingAdjustedValueForWidth:(CGFloat)width {
    return width - _padding.left - _padding.right;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.borderColor forKey:@"borderColor"];
    [encoder encodeObject:[NSValue valueWithUIEdgeInsets:self.borderWidth] forKey:@"borderWidth"];
    [encoder encodeObject:[NSValue valueWithUIEdgeInsets:self.padding] forKey:@"padding"];
    //[encoder encodeObject:[NSNumber numberWithInt:self.blockType] forKey:@"blockType"];
    [encoder encodeObject:self.url forKey:@"url"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.borderColor = [decoder decodeObjectForKey:@"borderColor"];
        self.borderWidth = [[decoder decodeObjectForKey:@"borderWidth"] UIEdgeInsetsValue];
        self.padding = [[decoder decodeObjectForKey:@"padding"] UIEdgeInsetsValue];
        self.url = [decoder decodeObjectForKey:@"url"];
    }
    return self;
}

@end
