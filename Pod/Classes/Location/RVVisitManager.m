//
//  RVVisitManager.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-29.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVVisitManager.h"

#import "RVCardProject.h"
#import "RVCustomerProject.h"
#import "RVLog.h"
#import "RVNetworkingManager.h"
#import "RVNotificationCenter.h"
#import "RVRegionManager.h"
#import "RoverManager.h"
#import "RVVisitProject.h"

NSString *const kRVVisitManagerDidEnterLocationNotification = @"RVVisitManagerDidEnterLocationNotification";
NSString *const kRVVisitManagerDidExitLocationNotification = @"RVVisitManagerDidExitLocationNotification";

@interface RVVisitManager ()

@property (strong, nonatomic) RVVisit *latestVisit;

@end

@implementation RVVisitManager

#pragma mark - Class Methods

+ (id)sharedManager {
    static RVVisitManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(regionManagerDidEnterRegion:) name:kRVRegionManagerDidEnterRegionNotification object:nil];
        
        [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(regionManagerDidExitRegion:) name:kRVRegionManagerDidExitRegionNotification object:nil];
    }
    return  self;
}

- (void)dealloc {
    [[RVNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Utility methods

- (BOOL)isCurrentRegion:(CLBeaconRegion *)beaconRegion {
    return [self.latestVisit.UUID.UUIDString isEqualToString:beaconRegion.proximityUUID.UUIDString];
}

#pragma mark - Region Manager Notifications

- (void)regionManagerDidEnterRegion:(NSNotification *)note {
    CLBeaconRegion *beaconRegion = [note.userInfo objectForKey:@"beaconRegion"];
    
    if (self.latestVisit && [self isCurrentRegion:beaconRegion] && self.latestVisit.isAlive) {
        NSDate *now = [NSDate date];
        NSTimeInterval elapsed = [now timeIntervalSinceDate:self.latestVisit.enteredAt];
        
        RVLog(kRoverAlreadyVisitingNotification, @{ @"elapsed": [NSNumber numberWithDouble:elapsed],
                                                    @"keepAlive": [NSNumber numberWithDouble:self.latestVisit.keepAlive] });
        return;
    }

    [self createVisitWithUUID:beaconRegion.proximityUUID major:beaconRegion.major];
}

- (void)regionManagerDidExitRegion:(NSNotification *)note {
    CLBeaconRegion *beaconRegion = [note.userInfo objectForKey:@"beaconRegion"];
    
    if (self.latestVisit && [self isCurrentRegion:beaconRegion]) {
        [self updateVisitExitTime];
    }
}

#pragma mark - Networking

- (void)createVisitWithUUID:(NSUUID *)UUID major:(NSNumber *)major {
    RVLog(kRoverWillPostVisitNotification, nil);
    
    self.latestVisit = [RVVisit new];
    self.latestVisit.UUID = UUID;
    self.latestVisit.major = major;
    self.latestVisit.customerID = [[RoverManager sharedManager] customerID];
    self.latestVisit.enteredAt = [NSDate date];
    
    [self.latestVisit save:^{
        [[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidEnterLocationNotification object:self userInfo:@{ @"visit": self.latestVisit }];
        RVLog(kRoverDidPostVisitNotification, nil);
    } failure:^(NSString *reason) {
        RVLog(kRoverPostVisitFailedNotification, nil);
    }];
}

- (void)updateVisitExitTime {
    if (!self.latestVisit) return;
    
    RVLog(kRoverWillUpdateExitTimeNotification, nil);
    
    self.latestVisit.exitedAt = [NSDate date];
    [self.latestVisit save:^{
        RVLog(kRoverDidUpdateExitTimeNotification, nil);
    } failure:^(NSString *reason) {
        RVLog(kRoverUpdateExitTimeFailedNotification, nil);
    }];
}

@end