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

typedef NS_ENUM(NSInteger, RVTouchpointType) {
    RVTouchpointTypeBeacon = 1,
    RVTouchpointTypeLocation = 2,
    RVTouchpointTypeGeofence = 3
};

@interface RVTouchpoint : RVModel

@property (nonatomic, assign) RVTouchpointType type;
@property (nonatomic, strong) NSNumber *minorNumber;
@property (nonatomic, strong) NSString *notification;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *cards;
@property (nonatomic, assign) BOOL isVisited;
@property (nonatomic, assign) BOOL notificationDelivered;
@property (nonatomic, readonly) BOOL isMasterTouchpoint;
@property (nonatomic, strong) NSURL *avatarURL;

- (BOOL)isInRegion:(CLBeaconRegion *)beaconRegion;

@end


