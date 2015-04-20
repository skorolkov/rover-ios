//
//  RVView.m
//  Pods
//
//  Created by Ata Namvari on 2015-03-05.
//
//

#import "RVViewDefinition.h"
#import "RVBlock.h"

@implementation RVViewDefinition

@synthesize backgroundColor, backgroundContentMode, backgroundImageURL;

- (CGFloat)heightForWidth:(CGFloat)width {
    __block CGFloat blocksHeight = 0;
    [_blocks enumerateObjectsUsingBlock:^(RVBlock *block, NSUInteger idx, BOOL *stop) {
        blocksHeight += [block heightForWidth:width - _margins.left - _margins.right];
    }];
    
    return _margins.top + blocksHeight + _margins.bottom;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:[NSNumber numberWithInt:self.type] forKey:@"type"];
    [encoder encodeObject:self.blocks forKey:@"blocks"];
    [encoder encodeObject:[NSValue valueWithUIEdgeInsets:self.margins] forKey:@"margins"];
    [encoder encodeObject:[NSNumber numberWithFloat:self.cornerRadius] forKey:@"cornerRadius"];
    
    // Background
    [encoder encodeObject:self.backgroundColor forKey:@"backgroundColor"];
    [encoder encodeObject:[NSNumber  numberWithInteger:self.backgroundContentMode] forKey:@"backgroundContentMode"];
    [encoder encodeObject:self.backgroundImageURL forKey:@"backgroundImageURL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.type = [[decoder decodeObjectForKey:@"type"] integerValue];
        self.blocks = [decoder decodeObjectForKey:@"blocks"];
        self.margins = [[decoder decodeObjectForKey:@"margins"] UIEdgeInsetsValue];
        self.cornerRadius = [[decoder decodeObjectForKey:@"cornerRadius"] floatValue];
        
        // Background
        self.backgroundColor = [decoder decodeObjectForKey:@"backgroundColor"];
        self.backgroundContentMode = [[decoder decodeObjectForKey:@"backgroundContentMode"] integerValue];
        self.backgroundImageURL = [decoder decodeObjectForKey:@"backgroundImageURL"];
    }
    return self;
}

@end
