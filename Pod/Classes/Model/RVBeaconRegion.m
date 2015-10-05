//
//  RVBeaconRegion.m
//  Pods
//
//  Created by Ata Namvari on 2015-10-01.
//
//

#import "RVBeaconRegion.h"

@import CoreLocation;

@implementation RVBeaconRegion

#pragma mark - Properties

- (NSString *)UUIDString {
    return self.UUID.UUIDString;
}

- (void)setUUIDString:(NSString *)UUIDString {
    self.UUID = [[NSUUID alloc] initWithUUIDString:UUIDString];
}

#pragma mark - Instance Methods

- (BOOL)isEqualToCLBeaconRegion:(CLBeaconRegion *)region {
    return [self.UUID.UUIDString isEqualToString:region.proximityUUID.UUIDString] && [self.majorNumber isEqualToNumber:region.major] && [self.minorNumber isEqualToNumber:region.minor];
}

#pragma mark - Class Methods

+ (instancetype)beaconRegionWithCLBeaconRegion:(CLBeaconRegion *)region {
    RVBeaconRegion *beaconRegion = [[self alloc] init];
    beaconRegion.UUID = region.proximityUUID;
    beaconRegion.majorNumber = region.major;
    beaconRegion.minorNumber = region.minor;
    return beaconRegion;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.UUID forKey:@"UUID"];
    [encoder encodeObject:self.majorNumber forKey:@"majorNumber"];
    [encoder encodeObject:self.minorNumber forKey:@"minorNumber"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.UUID = [decoder decodeObjectForKey:@"UUID"];
        self.majorNumber = [decoder decodeObjectForKey:@"majorNumber"];
        self.minorNumber = [decoder decodeObjectForKey:@"minorNumber"];
    }
    return self;
}

@end
