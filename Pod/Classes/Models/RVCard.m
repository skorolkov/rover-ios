//
//  RVCard.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-27.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModelProject.h"
#import "RVCardProject.h"
#import "RVColorUtilities.h"

@implementation RVCard

#pragma mark - Properties

- (UIColor *)primaryBackgroundColor {
    if (!_primaryBackgroundColor) {
        return [UIColor colorWithRed:37.0/255.0 green:111.0/255.0 blue:203.0/255.0 alpha:1.0];
    }
    
    return _primaryBackgroundColor;
}

- (UIColor *)primaryFontColor {
    if (!_primaryFontColor) {
        return [UIColor whiteColor];
    }
    
    return _primaryFontColor;
}

- (UIColor *)secondaryBackgroundColor {
    if (!_secondaryBackgroundColor) {
        return [UIColor colorWithRed:37.0/255.0 green:111.0/255.0 blue:203.0/255.0 alpha:1.0];
    }
    
    return _secondaryBackgroundColor;
}

- (UIColor *)secondaryFontColor {
    if (!_secondaryFontColor) {
        return [UIColor whiteColor];
    }
    
    return _secondaryFontColor;
}

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
    
    // organizationTitle
    NSString *organizationTitle = [JSON objectForKey:@"organization_title"];
    if (organizationTitle != (id)[NSNull null] && [organizationTitle length] > 0) {
        self.organizationTitle = organizationTitle;
    }
    
    // title
    NSString *title = [JSON objectForKey:@"title"];
    if (title != (id)[NSNull null] && [title length] > 0) {
        self.title = title;
    }
    
    // shortDescription
    NSString *shortDescription = [JSON objectForKey:@"short_description"];
    if (shortDescription != (id)[NSNull null] && [shortDescription length] > 0) {
        self.shortDescription = shortDescription;
    }
    
    // longDescription
    NSString *longDescription = [JSON objectForKey:@"long_description"];
    if (longDescription != (id)[NSNull null] && [longDescription length] > 0) {
        self.longDescription = longDescription;
    }
    
    // imageURL
    NSString *imageURL = [JSON objectForKey:@"image_url"];
    if (imageURL != (id)[NSNull null] && [imageURL length] > 0) {
        self.imageURL = [NSURL URLWithString:imageURL];
    }
    
    // primaryBackgroundColor
    NSString *primaryBackgroundColor = [JSON objectForKey:@"primary_background_color"];
    if (primaryBackgroundColor != (id)[NSNull null] && [primaryBackgroundColor length] > 0) {
        self.primaryBackgroundColor = [RVColorUtilities colorFromHexString:primaryBackgroundColor];
    }
    
    // primaryFontColor
    NSString *primaryFontColor = [JSON objectForKey:@"primary_font_color"];
    if (primaryFontColor != (id)[NSNull null] && [primaryFontColor length] > 0) {
        self.primaryFontColor = [RVColorUtilities colorFromHexString:primaryFontColor];
    }
    
    // secondaryBackgroundColor
    NSString *secondaryBackgroundColor = [JSON objectForKey:@"secondary_background_color"];
    if (secondaryBackgroundColor != (id)[NSNull null] && [secondaryBackgroundColor length] > 0) {
        self.secondaryBackgroundColor = [RVColorUtilities colorFromHexString:secondaryBackgroundColor];
    }
    
    // secondaryFontColor
    NSString *secondaryFontColor = [JSON objectForKey:@"secondary_font_color"];
    if (secondaryFontColor != (id)[NSNull null] && [secondaryFontColor length] > 0) {
        self.secondaryFontColor = [RVColorUtilities colorFromHexString:secondaryFontColor];
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
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *JSON = [[super toJSON] mutableCopy];
    
    // organizationTitle
    if (self.organizationTitle) {
        [JSON setObject:self.organizationTitle forKey:@"organization_title"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"organization_title"];
    }
    
    // title
    if (self.title) {
        [JSON setObject:self.title forKey:@"title"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"title"];
    }
    
    // shortDescription
    if (self.shortDescription) {
        [JSON setObject:self.shortDescription forKey:@"short_description"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"short_description"];
    }
    
    // longDescription
    if (self.longDescription) {
        [JSON setObject:self.longDescription forKey:@"long_description"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"long_description"];
    }
    
    // imageURL
    if (self.imageURL) {
        [JSON setObject:self.imageURL.description forKey:@"image_url"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"image_url"];
    }
    
    // primaryBackgroundColor
    if (self.primaryBackgroundColor) {
        [JSON setObject:[RVColorUtilities hexStringFromColor:self.primaryBackgroundColor] forKey:@"primary_background_color"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"primary_background_color"];
    }
    
    // primaryFontColor
    if (self.primaryFontColor) {
        [JSON setObject:[RVColorUtilities hexStringFromColor:self.primaryFontColor] forKey:@"primary_font_color"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"primary_font_color"];
    }
    
    // secondaryBackgroundColor
    if (self.secondaryBackgroundColor) {
        [JSON setObject:[RVColorUtilities hexStringFromColor:self.secondaryBackgroundColor] forKey:@"secondary_background_color"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"secondary_background_color"];
    }
    
    // secondaryFontColor
    if (self.secondaryFontColor) {
        [JSON setObject:[RVColorUtilities hexStringFromColor:self.secondaryFontColor] forKey:@"secondary_font_color"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"secondary_font_color"];
    }
    
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

    return JSON;
}

@end