//
//  RVCard.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-27.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModelProject.h"
#import "RVCardProject.h"
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

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    
    // title
    NSString *title = [JSON objectForKey:@"title"];
    if (title && title != (id)[NSNull null]) {
        self.title = title;
    }
    
    // views
    NSArray *views = [JSON objectForKey:@"views"];
    if (views && views != (id)[NSNull null]) {
        NSMutableArray *viewsArray = [NSMutableArray arrayWithCapacity:views.count];
        [views enumerateObjectsUsingBlock:^(NSDictionary *viewData, NSUInteger idx, BOOL *stop) {
            RVViewDefinition *view = [[RVViewDefinition alloc] initWithJSON:viewData];
            [viewsArray insertObject:view atIndex:idx];
            
            if (view.type == RVViewDefinitionTypeListView) {
                self.listView = view;
            }
        }];
        _viewDefinitions = [NSArray arrayWithArray:viewsArray];
    }
    
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
    [encoder encodeObject:[NSNumber numberWithBool:self.isDeleted] forKey:@"viewDefinitions"];
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