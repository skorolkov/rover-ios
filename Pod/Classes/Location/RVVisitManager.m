//
//  RVVisitManager.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-29.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "Rover.h"
#import "RVVisitManager.h"

#import "RVCardProject.h"
#import "RVCustomerProject.h"
#import "RVLog.h"
#import "RVNetworkingManager.h"
#import "RVNotificationCenter.h"
#import "RVRegionManager.h"
#import "RVVisitProject.h"
#import "RVTouchpoint.h"
#import "RVCustomer.h"

NSString *const kRVVisitManagerDidEnterTouchpointNotification = @"RVVisitManagerDidEnterTouchpointNotification";
NSString *const kRVVisitManagerDidEnterLocationNotification = @"RVVisitManagerDidEnterLocationNotification";
NSString *const kRVVisitManagerDidExitLocationNotification = @"RVVisitManagerDidExitLocationNotification";

@interface RVVisitManager ()

@property (strong, nonatomic) RVVisit *latestVisit;
@property (strong, nonatomic) NSTimer *expirationTimer;

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

#pragma mark - Instance methods

- (RVVisit *)latestVisit
{
    if (_latestVisit) {
        return _latestVisit;
    }
    
    NSUserDefaults *standardDefault = [NSUserDefaults standardUserDefaults];
    _latestVisit = [NSKeyedUnarchiver unarchiveObjectWithData:[standardDefault objectForKey:@"_roverLatestVisit"]];
    return _latestVisit;
}


#pragma mark - Region Manager Notifications

- (void)regionManagerDidEnterRegion:(NSNotification *)note {
    CLBeaconRegion *beaconRegion = [note.userInfo objectForKey:@"beaconRegion"];

    if (self.latestVisit && [self.latestVisit isInRegion:beaconRegion] && self.latestVisit.isAlive) {

        // Touchpoint check
        if (!self.latestVisit.currentTouchpoint || ![self.latestVisit.currentTouchpoint isInRegion:beaconRegion]) {
            [self movedToSubRegion:beaconRegion];
        }
        
        NSDate *now = [NSDate date];
        NSTimeInterval elapsed = [now timeIntervalSinceDate:self.latestVisit.enteredAt];

        [_expirationTimer invalidate];

        
        RVLog(kRoverAlreadyVisitingNotification, @{ @"elapsed": [NSNumber numberWithDouble:elapsed],
                                                    @"keepAlive": [NSNumber numberWithDouble:self.latestVisit.keepAlive] });
        return;
    }
    
    _expirationTimer = nil;


    RVCustomer *customer = [Rover shared].customer;
    [customer set:@"annual_salary" to:@400];
    if (customer.dirty) {
        [customer save:^{
            [self createVisitWithBeaconRegion:beaconRegion];
        } failure:nil];
    } else {
        [self createVisitWithBeaconRegion:beaconRegion];
    }
}

- (void)regionManagerDidExitRegion:(NSNotification *)note {
    CLBeaconRegion *beaconRegion = [note.userInfo objectForKey:@"beaconRegion"];
    
    if (self.latestVisit && [self.latestVisit isInRegion:beaconRegion]) {
        // Reset the keep-alive timer
        self.latestVisit.beaconLastDetectedAt = [NSDate date];
        [self.latestVisit persistToDefaults];
        
        // Reset region monitoring
        RVRegionManager *regionManager = [RVRegionManager sharedManager];
        [regionManager setBeaconUUIDs:[Rover shared].config.beaconUUIDs];
        [regionManager startMonitoring];
        
        [self updateVisitExitTime];
        [self startExpirationTimer];
    }
}

#pragma mark - Networking

- (void)createVisitWithBeaconRegion:(CLBeaconRegion *)beaconRegion {
    RVLog(kRoverWillPostVisitNotification, nil);
    
    self.latestVisit = [RVVisit new];
    self.latestVisit.UUID = beaconRegion.proximityUUID;
    self.latestVisit.major = beaconRegion.major;
    self.latestVisit.customerID = [Rover shared].customer.customerID;
    self.latestVisit.enteredAt = [NSDate date];
    
    [self.latestVisit save:^{
        [[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidEnterLocationNotification object:self userInfo:@{ @"visit": self.latestVisit }];
        RVLog(kRoverDidPostVisitNotification, nil);
        
        NSLog(@"touchpoints: %@", self.latestVisit.touchpoints); //DELETE
        
        RVRegionManager *regionManager = [RVRegionManager sharedManager];
        [regionManager setBeaconRegions:self.latestVisit.observableRegions];
        [regionManager startMonitoring];
        
        [self movedToSubRegion:beaconRegion];
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

// TODO: consider if this should happen in the succes block ^

#pragma mark - Helper Methods

- (void)movedToSubRegion:(CLBeaconRegion *)beaconRegion {
    RVTouchpoint *touchpoint = [self.latestVisit touchpointForRegion:beaconRegion];
    if (touchpoint) {
        
        
        if (![self.latestVisit.visitedTouchpoints containsObject:touchpoint]) {
            self.latestVisit.currentTouchpoint = touchpoint;
            [[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidEnterTouchpointNotification object:self
                                                              userInfo:@{ @"touchpoint": touchpoint,
                                                                          @"visit": self.latestVisit}];
            return;
        }
        
        self.latestVisit.currentTouchpoint = touchpoint;
        // TODO: fix this, this posts a noti,..why?!
        //RVLog(kRoverDidEnterTouchpointNotification, nil);
    } else {
        NSLog(@"Invalid touchpoint: %@", beaconRegion.minor);
    }
}

- (void)startExpirationTimer {
    _expirationTimer = [NSTimer scheduledTimerWithTimeInterval:self.latestVisit.keepAlive target:self selector:@selector(expireVisit) userInfo:nil repeats:NO];
}

- (void)expireVisit {
    [[RVNotificationCenter defaultCenter] postNotificationName:kRVVisitManagerDidExitLocationNotification object:self userInfo:@{@"visit": self.latestVisit}];
}

@end