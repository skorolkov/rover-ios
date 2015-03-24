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
        if ([triggerString isEqualToString:@"minorNumber"]) {
            self.trigger = RVTouchpointTriggerMinorNumber;
        } else if ([triggerString isEqualToString:@"beacon"]) {
            self.trigger = RVTouchpointTriggerAnyBeacon;
        } else {
            self.trigger = RVTouchpointTriggerGeofence;
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

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.minorNumber forKey:@"minor"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.minorNumber = [decoder decodeObjectForKey:@"minor"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<RVTouchpoint: id(%@) minorNumber(%@)>", self.ID, self.minorNumber];
}

#pragma mark - RVVisitTouchpointInfo

- (NSString *)name {
    return self.title;
}

// TODO: handle deletion

- (NSUInteger)numberOfCards {
    return self.cards.count;
}

- (NSArray *)cards {
    return _cards;
}

/* Title of the touchpoint (used when displaying the index)
 */
//@property (nonatomic, readonly) NSString *indexTitle;




@end
