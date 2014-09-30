//
//  RoverManager.h
//  Rover
//
//  Created by Sean Rucker on 2014-06-23.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RVModalViewController.h"

@class RVCustomer;

@interface RoverManager : NSObject

+ (id)sharedManager;

@property (strong, nonatomic) NSString *applicationID;
@property (strong, nonatomic) NSArray *beaconUUIDs;
@property (strong, nonatomic) NSString *customerID;
@property (strong, nonatomic) RVVisit *currentVisit;

- (void)getCustomer:(void (^)(RVCustomer *customer, NSString *error))block;
- (void)getCards:(void (^)(NSArray *cards, NSString *error))block;

- (void)startMonitoring;
- (void)stopMonitoring;

- (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major;

@end