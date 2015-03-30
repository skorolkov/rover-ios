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
    
    // trigger
    NSString *triggerString = [JSON objectForKey:@"trigger"];
    if (triggerString && triggerString != (id)[NSNull null]) {
        if ([triggerString isEqualToString:@"beacon"]) {
            self.trigger = RVTouchpointTriggerMinorNumber;
        } else {
            self.trigger = RVTouchpointTriggerVisit;
        }
    }
    
    // minorNumber
    NSNumber *minorNumber = [JSON objectForKey:@"minorNumber"];
    if (minorNumber && minorNumber != (id)[NSNull null]) {
        self.minorNumber = minorNumber;
    }
    
    // title
    NSString *title = [JSON objectForKey:@"title"];
    if (title && title != (id)[NSNull null]) {
        self.title = title;
    }
    
    // notification
    NSString *notification = [JSON objectForKey:@"notification"];
    if (notification && notification != (id)[NSNull null] && ![notification isEqualToString:@""]) {
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
        self.cards = [NSArray arrayWithArray:cards];
    }
    
}

- (BOOL)isInRegion:(CLBeaconRegion *)beaconRegion
{
    return [self.minorNumber isEqualToNumber:beaconRegion.minor];
}

- (BOOL)isEqual:(id)object {
    // TODO: better implementation from NSHipster
    RVTouchpoint *otherTouchpoint = object;
    
    return [self.ID isEqualToString:otherTouchpoint.ID];
}

- (NSUInteger)hash {
    return [self.ID hash];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<RVTouchpoint: id(%@) minorNumber(%@)>", self.ID, self.minorNumber];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:[NSNumber numberWithInt:self.trigger] forKey:@"trigger"];
    [encoder encodeObject:self.minorNumber forKey:@"minorNumber"];
    [encoder encodeObject:self.notification forKey:@"notification"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.cards forKey:@"cards"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isVisited] forKey:@"isVisited"];
    [encoder encodeObject:[NSNumber numberWithBool:self.notificationDelivered] forKey:@"notificationDelivered"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.trigger = [[decoder decodeObjectForKey:@"trigger"] integerValue];
        self.minorNumber = [decoder decodeObjectForKey:@"minorNumber"];
        self.notification = [decoder decodeObjectForKey:@"notification"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.cards = [decoder decodeObjectForKey:@"cards"];
        self.isVisited = [[decoder decodeObjectForKey:@"isVisited"] boolValue];
        self.notificationDelivered = [[decoder decodeObjectForKey:@"notificationDelivered"] boolValue];
    }
    return self;
}

@end
