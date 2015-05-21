//
//  RVTouchpoint.m
//  Pods
//
//  Created by Ata Namvari on 2014-12-23.
//
//

#import "RVTouchpoint.h"
#import "RVLocation.h"
#import "RVCard.h"

@implementation RVTouchpoint

- (BOOL)isInRegion:(CLBeaconRegion *)beaconRegion
{
    return [self.minorNumber isEqualToNumber:beaconRegion.minor];
}

- (BOOL)isEqual:(id)object {
    // TODO: better implementation from NSHipster
    RVTouchpoint *otherTouchpoint = object;
    
    return [self.ID isEqualToString:otherTouchpoint.ID];
}

- (BOOL)isMasterTouchpoint {
    return self.trigger == RVTouchpointTriggerVisit;
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
