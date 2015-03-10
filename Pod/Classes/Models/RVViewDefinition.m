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
    NSArray *backgroundColor = [JSON objectForKey:@"backgroundColor"];
    if (backgroundColor && backgroundColor != (id)[NSNull null]) {
        self.backgroundColor = [UIColor colorWithRed:[backgroundColor[0] floatValue]/255.f green:[backgroundColor[1] floatValue]/255.f blue:[backgroundColor[2] floatValue]/255.f alpha:[backgroundColor[3] floatValue]];
    }
    
    // backgroundImageURL
    NSString *backgroundImageURL = [JSON objectForKey:@"backgroundImageUrl"];
    if (backgroundImageURL && backgroundImageURL != (id)[NSNull null]) {
        self.backgroundImageURL = [NSURL URLWithString:backgroundImageURL];
    }
    
    // backgroundImageContentMode
    NSString *backgroundContentMode = [JSON objectForKey:@"backgroundContentMode"];
    if (backgroundContentMode && backgroundContentMode != (id)[NSNull null]) {
        self.backgroundContentMode = RVBackgroundContentModeFromString(backgroundContentMode);
    }
}

- (CGFloat)heightForWidth:(CGFloat)width {
    __block CGFloat blocksHeight = 0;
    [_blocks enumerateObjectsUsingBlock:^(RVBlock *block, NSUInteger idx, BOOL *stop) {
        blocksHeight += [block heightForWidth:width - _margins.left - _margins.right];
    }];
    
    return _margins.top + blocksHeight + _margins.bottom;
}

@end
