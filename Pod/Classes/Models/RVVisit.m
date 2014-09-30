//
//  RVVisit.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-26.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModelProject.h"
#import "RVVisitProject.h"
#import "RVCardProject.h"
#import "RVColorUtilities.h"

@implementation RVVisit

#pragma mark - Overridden Properties

- (NSString *)modelName {
    return @"visit";
}

#pragma mark - Properties

- (BOOL)isAlive {
    NSDate *now = [NSDate date];
    NSTimeInterval elapsed = [now timeIntervalSinceDate:self.enteredAt];
    return elapsed < self.keepAlive;
}

- (NSString *)welcomeMessage {
    if ([_welcomeMessage length] < 1) {
        return @"Welcome!";
    }
    
    return _welcomeMessage;
}

- (NSArray *)unreadCards {
    NSIndexSet *indexes = [self.cards indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        RVCard *card = (RVCard *)obj;
        return card.isUnread;
    }];
    return [self.cards objectsAtIndexes:indexes];
}

- (NSArray *)savedCards {
    NSIndexSet *indexes = [self.cards indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        RVCard *card = (RVCard *)obj;
        return card.likedAt ? YES : NO;
    }];
    return [self.cards objectsAtIndexes:indexes];
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.cards = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    
    // UUID
    NSString *UUID = [JSON objectForKey:@"uuid"];
    if (UUID && UUID != (id)[NSNull null]  && [UUID length] > 0) {
        self.UUID = [[NSUUID alloc] initWithUUIDString:UUID];
    }
    
    // major
    NSNumber *major = [JSON objectForKey:@"major"];
    if (major && major != (id)[NSNull null]) {
        self.major = major;
    }
    
    // customerID
    NSString *customerID = [JSON objectForKey:@"customer_id"];
    if (customerID && customerID != (id)[NSNull null] && [customerID length] > 0) {
        self.customerID = customerID;
    }
    
    // welcomeMessage
    NSString *welcomeMessage = [JSON objectForKey:@"welcome_message"];
    if (welcomeMessage && welcomeMessage != (id)[NSNull null] && [welcomeMessage length] > 0) {
        self.welcomeMessage = welcomeMessage;
    }
    
    // recallMessage
    NSString *recallMessage = [JSON objectForKey:@"recall_message"];
    if (recallMessage && recallMessage != (id)[NSNull null] && [recallMessage length] > 0) {
        self.recallMessage = recallMessage;
    }
    
    // keepAlive
    NSNumber *keepAlive = [JSON objectForKey:@"keep_alive"];
    if (keepAlive && keepAlive != (id)[NSNull null]) {
        self.keepAlive = [keepAlive doubleValue];
    }
    
    // primaryBackgroundColor
    NSString *primaryBackgroundColor = [JSON objectForKey:@"primary_background_color"];
    if (primaryBackgroundColor && primaryBackgroundColor != (id)[NSNull null] && [primaryBackgroundColor length] > 0) {
        self.primaryBackgroundColor = [RVColorUtilities colorFromHexString:primaryBackgroundColor];
    }
    
    // primaryFontColor
    NSString *primaryFontColor = [JSON objectForKey:@"primary_font_color"];
    if (primaryFontColor && primaryFontColor != (id)[NSNull null] && [primaryFontColor length] > 0) {
        self.primaryFontColor = [RVColorUtilities colorFromHexString:primaryFontColor];
    }
    
    // secondaryBackgroundColor
    NSString *secondaryBackgroundColor = [JSON objectForKey:@"secondary_background_color"];
    if (secondaryBackgroundColor && secondaryBackgroundColor != (id)[NSNull null] && [secondaryBackgroundColor length] > 0) {
        self.secondaryBackgroundColor = [RVColorUtilities colorFromHexString:secondaryBackgroundColor];
    }
    
    // secondaryFontColor
    NSString *secondaryFontColor = [JSON objectForKey:@"secondary_font_color"];
    if (secondaryFontColor && secondaryFontColor != (id)[NSNull null] && [secondaryFontColor length] > 0) {
        self.secondaryFontColor = [RVColorUtilities colorFromHexString:secondaryFontColor];
    }
    
    NSDateFormatter *dateFormatter = [self dateFormatter];
    
    // enteredAt
    NSString *enteredAt = [JSON objectForKey:@"entered_at"];
    if (enteredAt && enteredAt != (id)[NSNull null] && [enteredAt length] > 0) {
        self.enteredAt = [dateFormatter dateFromString:enteredAt];
    }
    
    // exitedAt
    NSString *exitedAt = [JSON objectForKey:@"exited_at"];
    if (exitedAt && exitedAt != (id)[NSNull null] && [exitedAt length] > 0) {
        self.exitedAt = [dateFormatter dateFromString:exitedAt];
    }
    
    // openedAt
    NSString *openedAt = [JSON objectForKey:@"opened_at"];
    if (openedAt && openedAt != (id)[NSNull null] && [openedAt length] > 0) {
        self.openedAt = [dateFormatter dateFromString:openedAt];
    }
    
    // cards
    NSArray *cardsData = [JSON objectForKey:@"cards"];
    if (cardsData && cardsData != (id)[NSNull null]) {
        NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[cardsData count]];
        [cardsData enumerateObjectsUsingBlock:^(NSDictionary *cardData, NSUInteger idx, BOOL *stop) {
            RVCard *card = [[RVCard alloc] initWithJSON:cardData];
            [cards addObject:card];
        }];
        self.cards = cards;
    }
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *JSON = [[super toJSON] mutableCopy];
    
    // UUID
    if (self.UUID) {
        [JSON setObject:self.UUID.UUIDString forKey:@"uuid"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"uuid"];
    }
    
    // major
    if (self.major) {
        [JSON setObject:self.major forKey:@"major"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"major"];
    }
    
    // customerID
    if (self.customerID) {
        [JSON setObject:self.customerID forKey:@"customer_id"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"customer_id"];
    }
    
    // welcomeMessage
    if (self.welcomeMessage) {
        [JSON setObject:self.welcomeMessage forKey:@"welcome_message"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"welcome_message"];
    }
    
    // recallMessage
    if (self.recallMessage) {
        [JSON setObject:self.recallMessage forKey:@"recall_message"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"recall_message"];
    }
    
    // keepAlive
    if (self.keepAlive) {
        [JSON setObject:[NSNumber numberWithDouble:self.keepAlive] forKey:@"keep_alive"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"keep_alive"];
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
    
    // enteredAt
    if (self.enteredAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.enteredAt] forKey:@"entered_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"entered_at"];
    }
    
    // exitedAt
    if (self.exitedAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.exitedAt] forKey:@"exited_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"exited_at"];
    }
    
    // openedAt
    if (self.openedAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.openedAt] forKey:@"opened_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"opened_at"];
    }
    
    return JSON;
}

@end