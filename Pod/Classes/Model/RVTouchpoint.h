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

typedef NS_ENUM(NSInteger, RVTouchpointTrigger) {
    RVTouchpointTriggerMinorNumber = 1,
    RVTouchpointTriggerVisit = 2
};

@interface RVTouchpoint : RVModel

@property (nonatomic, assign) RVTouchpointTrigger trigger;
@property (nonatomic, strong) NSNumber *minorNumber;
@property (nonatomic, strong) NSString *notification;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *cards;
@property (nonatomic, assign) BOOL isVisited;
@property (nonatomic, assign) BOOL notificationDelivered;
@property (nonatomic, readonly) BOOL isMasterTouchpoint;

- (BOOL)isInRegion:(CLBeaconRegion *)beaconRegion;

@end


