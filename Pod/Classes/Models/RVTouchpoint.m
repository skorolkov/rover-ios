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

@implementation RVTouchpoint

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    
    // minor
    NSNumber *minor = [JSON objectForKey:@"minor"];
    if (minor && minor != (id)[NSNull null]) {
        self.minor = minor;
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
