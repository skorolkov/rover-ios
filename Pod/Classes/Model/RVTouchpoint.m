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
#import "RVBeaconRegion.h"

@implementation RVTouchpoint

- (BOOL)respondsToRegion:(CLRegion *)region {
    for (RVBeaconRegion *beaconRegion in self.beaconRegions) {
        if ([beaconRegion isEqualToCLBeaconRegion:(CLBeaconRegion *)region]) {
            return YES;
        }
    }
    return NO;
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
    return [NSString stringWithFormat:@"<RVTouchpoint: id(%@)>", self.ID];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:[NSNumber numberWithBool:self.isVisited] forKey:@"isVisited"];
    [encoder encodeObject:self.gimbalPlaceId forKey:@"gimbalPlaceId"];
    [encoder encodeObject:self.deckId forKey:@"deckId"];
    [encoder encodeObject:self.beaconRegions forKey:@"beaconRegions"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.isVisited = [[decoder decodeObjectForKey:@"isVisited"] boolValue];
        self.gimbalPlaceId = [decoder decodeObjectForKey:@"gimbalPlaceId"];
        self.deckId = [decoder decodeObjectForKey:@"deckId"];
        self.beaconRegions = [decoder decodeObjectForKey:@"beaconRegions"];
    }
    return self;
}

@end
