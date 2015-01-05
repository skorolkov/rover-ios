//
//  RVTouchpoint.h
//  Pods
//
//  Created by Ata Namvari on 2014-12-23.
//
//

#import <Foundation/Foundation.h>
#import "RVModel.h"

@class CLBeaconRegion;

@interface RVTouchpoint : RVModel

@property (nonatomic, strong) NSNumber *minor;

- (BOOL)isInRegion:(CLBeaconRegion *)beaconRegion;

@end
