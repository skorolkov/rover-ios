//
//  RVBeaconRegion.h
//  Pods
//
//  Created by Ata Namvari on 2015-10-01.
//
//

#import "RVModel.h"

@class CLBeaconRegion;

@interface RVBeaconRegion : RVModel

@property (nonatomic, strong) NSUUID *UUID;
@property (nonatomic, strong) NSNumber *majorNumber;
@property (nonatomic, strong) NSNumber *minorNumber;

@property (nonatomic, weak) NSString *UUIDString;

+ (instancetype)beaconRegionWithCLBeaconRegion:(CLBeaconRegion *)region;

- (BOOL)isEqualToCLBeaconRegion:(CLBeaconRegion *)region;

@end
