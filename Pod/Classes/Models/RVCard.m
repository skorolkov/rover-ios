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

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.organizationTitle forKey:@"organizationTitle"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.cardId forKey:@"cardId"];
    [encoder encodeObject:self.shortDescription forKey:@"shortDescription"];
    [encoder encodeObject:self.longDescription forKey:@"longDescription"];
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
    [encoder encodeObject:self.primaryBackgroundColor forKey:@"primaryBackgroundColor"];
    [encoder encodeObject:self.primaryFontColor forKey:@"primaryFontColor"];
    [encoder encodeObject:self.secondaryBackgroundColor forKey:@"secondaryBackgroundColor"];
    [encoder encodeObject:self.secondaryFontColor forKey:@"secondaryFontColor"];
    [encoder encodeObject:self.viewedAt forKey:@"viewedAt"];
    [encoder encodeObject:self.likedAt forKey:@"likedAt"];
    [encoder encodeObject:self.barcode forKey:@"barcode"];
    [encoder encodeObject:self.barcodeType forKey:@"barcodeType"];
    [encoder encodeObject:self.barcodeInstructions forKey:@"barcodeInstructions"];
    [encoder encodeObject:self.tags forKey:@"tags"];
    [encoder encodeObject:self.terms forKey:@"terms"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isUnread] forKey:@"isUnread"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.organizationTitle = [decoder decodeObjectForKey:@"organizationTitle"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.cardId = [decoder decodeObjectForKey:@"cardId"];
        self.shortDescription = [decoder decodeObjectForKey:@"shortDescription"];
        self.longDescription = [decoder decodeObjectForKey:@"longDescription"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.primaryBackgroundColor = [decoder decodeObjectForKey:@"primaryBackgroundColor"];
        self.primaryFontColor = [decoder decodeObjectForKey:@"primaryFontColor"];
        self.secondaryBackgroundColor = [decoder decodeObjectForKey:@"secondaryBackgroundColor"];
        self.secondaryFontColor = [decoder decodeObjectForKey:@"secondaryFontColor"];
        self.viewedAt = [decoder decodeObjectForKey:@"viewedAt"];
        self.likedAt = [decoder decodeObjectForKey:@"likedAt"];
        self.barcode = [decoder decodeObjectForKey:@"barcode"];
        self.barcodeType = [decoder decodeObjectForKey:@"barcodeType"];
        self.barcodeInstructions = [decoder decodeObjectForKey:@"barcodeInstructions"];
        self.tags = [decoder decodeObjectForKey:@"tags"];
        self.terms = [decoder decodeObjectForKey:@"terms"];
        self.isUnread = [[decoder decodeObjectForKey:@"isUnread"] boolValue];
    }
    return self;
}
@end