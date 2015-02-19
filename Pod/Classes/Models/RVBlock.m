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

NSString *const sRVBlockImageType = @"image";
NSString *const sRVBlockTextType = @"text";
NSString *const sRVBlockBarcodeType = @"barcode";
NSString *const sRVBlockButtonType = @"button";
NSString *const sRVBlockHeaderType = @"header";

@interface RVBlock ()


@end

@implementation RVBlock

+ (RVBlock *)appropriateBlockWithJSON:(NSDictionary *)JSON {
    // type
    RVBlockType blockType;
    
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
    
}

#pragma mark - Overridden Methods

- (NSString *)modelName {
    return @"block";
}

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    
    // backgroundColor
    NSArray *backgroundColor = [JSON objectForKey:@"backgroundColor"];
    if (backgroundColor && backgroundColor != (id)[NSNull null]) {
        self.backgroundColor = [UIColor colorWithRed:[backgroundColor[0] floatValue]/255.f green:[backgroundColor[1] floatValue]/255.f blue:[backgroundColor[2] floatValue]/255.f alpha:[backgroundColor[3] floatValue]];
    }
    
    // borderColor
    NSArray *borderColor = [JSON objectForKey:@"borderColor"];
    if (borderColor && borderColor != (id)[NSNull null]) {
        self.borderColor = [UIColor colorWithRed:[borderColor[0] floatValue]/255.f green:[borderColor[1] floatValue]/255.f blue:[borderColor[2] floatValue]/255.f alpha:[borderColor[3] floatValue]];
    }
    
    // padding
    NSArray *padding = [JSON objectForKey:@"padding"];
    if (padding && borderColor != (id)[NSNull null]) {
        self.padding = UIEdgeInsetsMake([padding[0] floatValue], [padding[2] floatValue], [padding[1] floatValue], [padding[3] floatValue]);
    }
    
    // borderWidth
    NSArray *borderWidth = [JSON objectForKey:@"borderWidth"];
    if (borderWidth && borderWidth != (id)[NSNull null]) {
        self.borderWidth = UIEdgeInsetsMake([borderWidth[0] floatValue], [borderWidth[2] floatValue], [borderWidth[1] floatValue], [borderWidth[3] floatValue]);
    }
    
}

- (CGFloat)heightForWidth:(CGFloat)width {
    return _padding.top  + _padding.bottom;
}

@end
