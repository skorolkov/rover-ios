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
    return [_listView heightForWidth:width];
}


@end