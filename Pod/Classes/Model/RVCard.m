//
//  RVCard.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-27.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCard.h"
#import "RVBlock.h"
#import "RVViewDefinition.h"

@interface RVCard ()

@property (nonatomic, strong) RVViewDefinition *listView;

@end

@implementation RVCard

#pragma mark - Overridden Methods

- (NSString *)modelName {
    return @"card";
}

- (CGFloat)listViewHeightForWidth:(CGFloat)width {
    return [self.listView heightForWidth:width];
}

- (RVViewDefinition *)listView {
    if (_listView) {
        return _listView;
    }
    
    [self.viewDefinitions enumerateObjectsUsingBlock:^(RVViewDefinition *viewDefinition, NSUInteger idx, BOOL *stop) {
        if (viewDefinition.type == RVViewDefinitionTypeListView) {
            _listView = viewDefinition;
            *stop = YES;
        }
    }];
    
    return _listView;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.viewDefinitions forKey:@"viewDefinitions"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isDeleted] forKey:@"isDeleted"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isViewed] forKey:@"isViewed"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.title = [decoder decodeObjectForKey:@"title"];
        self.viewDefinitions = [decoder decodeObjectForKey:@"viewDefinitions"];
        self.isDeleted = [[decoder decodeObjectForKey:@"isDeleted"] boolValue];
        self.isViewed = [[decoder decodeObjectForKey:@"isViewed"] boolValue];
    }
    return self;
}

@end