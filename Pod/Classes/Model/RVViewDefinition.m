//
//  RVView.m
//  Pods
//
//  Created by Ata Namvari on 2015-03-05.
//
//

#import "RVViewDefinition.h"
#import "RVModelProject.h"
#import "RVBlock.h"

@implementation RVViewDefinition

@synthesize backgroundColor, backgroundContentMode, backgroundImageURL;

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    
    // type
    NSString *type = [JSON objectForKey:@"type"];
    if (type && type != (id)[NSNull null]) {
        if ([type isEqualToString:@"detailView"]) {
            self.type = RVViewDefinitionTypeDetailView;
        } else {
            self.type = RVViewDefinitionTypeListView;
        }
    }
    
    // corderRadius
    NSNumber *borderRadius = [JSON objectForKey:@"borderRadius"];
    if (borderRadius && borderRadius != (id)[NSNull null]) {
        self.cornerRadius = [borderRadius floatValue];
    }
    
    
    // margins
    NSArray *margins = [JSON objectForKey:@"margin"];
    if (margins && margins != (id)[NSNull null]) {
        self.margins = UIEdgeInsetsMake([margins[0] floatValue], [margins[3] floatValue], [margins[2] floatValue], [margins[1] floatValue]);
    }
    
    
    // blocks
    NSArray *blocks = [JSON objectForKey:@"blocks"];
    if (blocks && blocks != (id)[NSNull null]) {
        NSMutableArray *blocksArray = [NSMutableArray arrayWithCapacity:blocks.count];
        [blocks enumerateObjectsUsingBlock:^(NSDictionary *blockData, NSUInteger idx, BOOL *stop) {
            RVBlock *block = [RVBlock appropriateBlockWithJSON:blockData];
            [blocksArray insertObject:block atIndex:idx];
        }];
        _blocks = [NSArray arrayWithArray:blocksArray];
    }
    
    // backgroundColor
    NSArray *backgroundColorArray = [JSON objectForKey:@"backgroundColor"];
    if (backgroundColorArray && backgroundColorArray != (id)[NSNull null]) {
        self.backgroundColor = [UIColor colorWithRed:[backgroundColorArray[0] floatValue]/255.f green:[backgroundColorArray[1] floatValue]/255.f blue:[backgroundColorArray[2] floatValue]/255.f alpha:[backgroundColorArray[3] floatValue]];
    }
    
    // backgroundImageURL
    NSString *backgroundImageURLString = [JSON objectForKey:@"backgroundImageUrl"];
    if (backgroundImageURLString && backgroundImageURLString != (id)[NSNull null] && ![backgroundImageURLString isEqualToString:@""]) {
        self.backgroundImageURL = [NSURL URLWithString:backgroundImageURLString];
    }
    
    // backgroundImageContentMode
    NSString *backgroundContentModeString = [JSON objectForKey:@"backgroundContentMode"];
    if (backgroundContentModeString && backgroundContentModeString != (id)[NSNull null]) {
        self.backgroundContentMode = RVBackgroundContentModeFromString(backgroundContentModeString);
    }
}

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
