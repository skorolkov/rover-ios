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

#pragma mark - Properties

//- (UIColor *)primaryBackgroundColor {
//    if (!_primaryBackgroundColor) {
//        return [UIColor colorWithRed:37.0/255.0 green:111.0/255.0 blue:203.0/255.0 alpha:1.0];
//    }
//    
//    return _primaryBackgroundColor;
//}
//
//- (UIColor *)primaryFontColor {
//    if (!_primaryFontColor) {
//        return [UIColor whiteColor];
//    }
//    
//    return _primaryFontColor;
//}
//
//- (UIColor *)secondaryBackgroundColor {
//    if (!_secondaryBackgroundColor) {
//        return [UIColor colorWithRed:37.0/255.0 green:111.0/255.0 blue:203.0/255.0 alpha:1.0];
//    }
//    
//    return _secondaryBackgroundColor;
//}
//
//- (UIColor *)secondaryFontColor {
//    if (!_secondaryFontColor) {
//        return [UIColor whiteColor];
//    }
//    
//    return _secondaryFontColor;
//}
//
//- (NSURL *)imageURL
//{
//    if (!_imageURL) {
//        return nil;
//    }
//    
//    NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width * UIScreen.mainScreen.scale;
//    NSInteger screenHeight;
//    
//    switch (screenWidth) {
//        case 750:
//            screenHeight = 469;
//            break;
//        case 1242:
//            screenHeight = 776;
//            break;
//        default: {
//            screenWidth = 640;
//            screenHeight = 400;
//        }
//            break;
//    }
//    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?w=%ld&h=%ld&fit=crop&fm=jpg", _imageURL.absoluteString, (long)screenWidth, (long)screenHeight]];
//    
//    return url;
//}

#pragma mark - Initialization

- (id)initWithJSON:(NSDictionary *)JSON {
    self = [super initWithJSON:JSON];
    if (self) {
        self.isUnread = YES;
    }
    return self;
}

#pragma mark - Overridden Methods

- (NSString *)modelName {
    return @"card";
}

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    

    // metaData
    NSDictionary *metaData = [JSON objectForKey:@"metaData"];
    if (metaData && metaData != (id)[NSNull null]) {
        _metaData = metaData;
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
    
    
// -0-----
    
    
    // cardId
    NSNumber *cardId = [JSON objectForKey:@"card_id"];
    if (cardId != (id)[NSNull null]) {
        self.cardId = cardId;
    }
    

    
    NSDateFormatter *dateFormatter = [self dateFormatter];
    
    // viewedAt
    NSString *viewedAt = [JSON objectForKey:@"viewed_at"];
    if (viewedAt != (id)[NSNull null] && [viewedAt length] > 0) {
        self.viewedAt = [dateFormatter dateFromString:viewedAt];
    }
    
    // likedAt
    NSString *likedAt = [JSON objectForKey:@"liked_at"];
    if (likedAt != (id)[NSNull null] && [likedAt length] > 0) {
        self.likedAt = [dateFormatter dateFromString:likedAt];
    }
    
    // discardedAt
    NSString *discardedAt = [JSON objectForKey:@"discarded_at"];
    if (discardedAt != (id)[NSNull null] && [discardedAt length] > 0) {
        self.discardedAt = [dateFormatter dateFromString:discardedAt];
    }
    
    // expiresAt
    NSString *expiresAt = [JSON objectForKey:@"expires_at"];
    if (expiresAt != (id)[NSNull null] && [expiresAt length] > 0) {
        self.expiresAt = [dateFormatter dateFromString:expiresAt];
    }


    
    // lastExpandedAt
    NSString *lastExpandedAt = [JSON objectForKey:@"last_expanded_at"];
    if (lastExpandedAt != (id)[NSNull null] && [lastExpandedAt length] > 0) {
        self.lastExpandedAt = [dateFormatter dateFromString:lastExpandedAt];
    }
    
    // lastViewedBarcodeAt
    NSString *lastViewedBarcodeAt = [JSON objectForKey:@"last_viewed_barcode_at"];
    if (lastViewedBarcodeAt != (id)[NSNull null] && [lastViewedBarcodeAt length] > 0) {
        self.lastViewedBarcodeAt = [dateFormatter dateFromString:lastViewedBarcodeAt];
    }
    
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *JSON = [[super toJSON] mutableCopy];
    NSDateFormatter *dateFormatter = [self dateFormatter];
    
    // viewedAt
    if (self.viewedAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.viewedAt] forKey:@"viewed_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"viewed_at"];
    }
    
    // likedAt
    if (self.likedAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.likedAt] forKey:@"liked_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"liked_at"];
    }
    
    // discardedAt
    if (self.discardedAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.discardedAt] forKey:@"discarded_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"discarded_at"];
    }
    
    // expiresAt
    if (self.expiresAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.expiresAt] forKey:@"expires_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"expires_at"];
    }
    
    // lastExpandedAt
    if (self.lastExpandedAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.lastExpandedAt] forKey:@"last_expanded_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"last_expanded_at"];
    }
    
    // lastViewedBarcodeAt
    if (self.lastViewedBarcodeAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.lastViewedBarcodeAt] forKey:@"last_viewed_barcode_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"last_viewed_barcode_at"];
    }
    
    // lastViewedFrom
    if (self.lastViewedFrom) {
        [JSON setObject:self.lastViewedFrom forKey:@"last_viewed_from"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"last_viewed_from"];
    }
    
    // lastViewedPosition
    if (self.lastViewedPosition) {
        [JSON setObject:self.lastViewedPosition forKey:@"last_viewed_position"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"last_viewed_position"];
    }
    
    return JSON;
}

- (CGFloat)listViewHeightForWidth:(CGFloat)width {
    return [_listView heightForWidth:width];
}


@end