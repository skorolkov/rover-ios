//
//  Rover.m
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "Rover.h"
#import "RoverManager.h"
#import "RVCustomerProject.h"

NSString *const kRoverDidEnterLocationNotification = @"RoverDidEnterLocationNotification";

@implementation Rover

#pragma mark - Class methods

+ (void)setApplicationID:(NSString *)applicationID beaconUUIDs:(NSArray *)UUIDs {
    RoverManager *rover = [RoverManager sharedManager];
    rover.applicationID = applicationID;
    rover.beaconUUIDs = UUIDs;
}

+ (void)setCustomerID:(NSString *)customerID {
    RoverManager *rover = [RoverManager sharedManager];
    rover.customerID = customerID;
}

+ (RVVisit*)currentVisit {
    RoverManager *rover = [RoverManager sharedManager];
    return rover.currentVisit;
}

+ (void)getCustomer:(void (^)(RVCustomer *, NSString *))block {
    RoverManager *rover = [RoverManager sharedManager];
    [rover getCustomer:^(RVCustomer *customer, NSString *error) {
        if (block) {
            block(customer, error);
        }
    }];
}

+ (void)getCards:(void (^)(NSArray *, NSString *))block {
    RoverManager *rover = [RoverManager sharedManager];
    [rover getCards:^(NSArray *cards, NSString *error) {
        if (block) {
            block(cards, error);
        }
    }];
}

+ (void)startMonitoring {
    RoverManager *rover = [RoverManager sharedManager];
    [rover startMonitoring];
}

+ (void)stopMonitoring {
    RoverManager *rover = [RoverManager sharedManager];
    [rover stopMonitoring];
}

+ (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major {
    RoverManager *rover = [RoverManager sharedManager];
    [rover simulateBeaconWithUUID:UUID major:major];
}

@end
