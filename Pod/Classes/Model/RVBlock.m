//
//  RVBlock.m
//  Pods
//
//  Created by Ata Namvari on 2015-02-12.
//
//

#import "RVBlock.h"

@interface RVBlock ()

@end

@implementation RVBlock

@synthesize backgroundColor, backgroundImageURL, backgroundContentMode;

#pragma mark - Overridden Methods

- (NSString *)modelName {
    return @"block";
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
    
    // Background
    [encoder encodeObject:self.backgroundColor forKey:@"backgroundColor"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.backgroundContentMode] forKey:@"backgroundContentMode"];
    [encoder encodeObject:self.backgroundImageURL forKey:@"backgroundImageURL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.borderColor = [decoder decodeObjectForKey:@"borderColor"];
        self.borderWidth = [[decoder decodeObjectForKey:@"borderWidth"] UIEdgeInsetsValue];
        self.padding = [[decoder decodeObjectForKey:@"padding"] UIEdgeInsetsValue];
        self.url = [decoder decodeObjectForKey:@"url"];
        
        // Background
        self.backgroundColor = [decoder decodeObjectForKey:@"backgroundColor"];
        self.backgroundContentMode = [[decoder decodeObjectForKey:@"backgroundContentMode"] integerValue];
        self.backgroundImageURL = [decoder decodeObjectForKey:@"backgroundImageURL"];
    }
    return self;
}

@end
