//
//  RVTouchpoint.m
//  Pods
//
//  Created by Ata Namvari on 2014-12-23.
//
//

#import "RVTouchpoint.h"
#import "RVModelProject.h"
#import "RVLocation.h"
#import "RVCard.h"

@implementation RVTouchpoint

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    
    // minor
    NSNumber *minor = [JSON objectForKey:@"minorNumber"];
    if (minor && minor != (id)[NSNull null]) {
        self.minor = minor;
    }
    
    // title
    NSString *title = [JSON objectForKey:@"title"];
    if (title && title != (id)[NSNull null]) {
        self.title = title;
    }
    
    // notification
    NSString *notification = [JSON objectForKey:@"notification"];
    if (notification && notification != (id)[NSNull null]) {
        self.notification = notification;
    }
    
    // cards
    NSArray *cardsData = [JSON objectForKey:@"cards"];
    if (cardsData && cardsData != (id)[NSNull null]) {
        NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[cardsData count]];
        [cardsData enumerateObjectsUsingBlock:^(NSDictionary *cardData, NSUInteger idx, BOOL *stop) {
            RVCard *card = [[RVCard alloc] initWithJSON:cardData];
            [cards addObject:card];
        }];
        self.cards = [cards copy];
    }
    
}

- (BOOL)isInRegion:(CLBeaconRegion *)beaconRegion
{
    return [self.minor isEqualToNumber:beaconRegion.minor];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.minor forKey:@"minor"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.minor = [decoder decodeObjectForKey:@"minor"];
    }
    return self;
}

@end
