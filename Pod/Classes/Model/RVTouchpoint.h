//
//  RVTouchpoint.h
//  Pods
//
//  Created by Ata Namvari on 2014-12-23.
//
//

#import <Foundation/Foundation.h>
#import "RVModel.h"

@class CLRegion;

//typedef NS_ENUM(NSInteger, RVTouchpointType) {
//    RVTouchpointTypeBeacon = 1,
//    RVTouchpointTypeLocation = 2,
//    RVTouchpointTypeGeofence = 3
//};

@interface RVTouchpoint : RVModel

//@property (nonatomic, assign) RVTouchpointType type;
@property (nonatomic, assign) BOOL isVisited;
@property (nonatomic, strong) NSString *gimbalPlaceId;
@property (nonatomic, strong) NSString *deckId;
@property (nonatomic, strong) NSArray *beaconRegions;

- (BOOL)respondsToRegion:(CLRegion *)region;

@end


