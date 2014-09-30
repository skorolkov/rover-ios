//
//  RoverManager.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-23.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "Rover.h"
#import "RoverManager.h"
#import "RVNetworkingManager.h"
#import "RVRegionManager.h"
#import "RVVisitManager.h"
#import "RVCustomerProject.h"
#import "RVVisitProject.h"
#import "RVLog.h"
#import "RVNotificationCenter.h"
#import "RVModel.h"

static NSString *const kRVCustomerIDKey = @"kRVCustomerIDKey";

@interface RoverManager()

@property (readonly, nonatomic) NSDictionary *configuration;
@property (readonly, nonatomic) NSString *endpoint;

@end

@implementation RoverManager
{
    NSDictionary *_configuration;
    NSString *_endpoint;
    NSString *_customerID;
}

#pragma mark - Class methods

+ (id)sharedManager {
    static RoverManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Properties

- (NSDictionary *)configuration {
    if (!_configuration) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Rover" ofType:@"plist"];
        _configuration = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return _configuration;
}

- (NSString *)endpoint {
    if (!_endpoint) {
        NSString *value = [self.configuration objectForKey:@"API Endpoint"];
        _endpoint = [value length] > 0 ? value : @"http://rover-app.herokuapp.com/mobileapi/v1/";
    }
    return _endpoint;
}

- (void)setApplicationID:(NSString *)applicationID {
    _applicationID = applicationID;
    
    NSString *authToken = [NSString stringWithFormat:@"Bearer %@", applicationID];
    [[RVNetworkingManager sharedManager] setAuthToken:authToken];
}

- (void)setBeaconUUIDs:(NSArray *)beaconUUIDs {
    _beaconUUIDs = beaconUUIDs;
    
    NSMutableArray *UUIDs = [NSMutableArray arrayWithCapacity:[beaconUUIDs count]];
    [beaconUUIDs enumerateObjectsUsingBlock:^(NSString *UUIDString, NSUInteger idx, BOOL *stop) {
        NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:UUIDString];
        [UUIDs addObject:UUID];
    }];
    [[RVRegionManager sharedManager] setBeaconUUIDs:UUIDs];
}

- (NSString *)customerID {
    if ([_customerID length] > 0) return _customerID;
    
    NSString *customerID = [[NSUserDefaults new] objectForKey:kRVCustomerIDKey];
    
    if (!customerID) {
        CFUUIDRef identifier = CFUUIDCreate(NULL);
        customerID = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, identifier));
    }
    
    self.customerID = customerID;
    return _customerID;
}

- (void)setCustomerID:(NSString *)customerID {
    _customerID = customerID;
    [[NSUserDefaults new] setObject:_customerID forKey:kRVCustomerIDKey];
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        // TODO: Fix this
        [RVVisitManager sharedManager];
        
        RVNetworkingManager *networkingManager = [RVNetworkingManager sharedManager];
        networkingManager.baseURL = [NSURL URLWithString:self.endpoint];
        networkingManager.loggingEnabled = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(visitManagerDidEnterLocation:) name:kRVVisitManagerDidEnterLocationNotification object:nil];
        [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(visitManagerDidExitLocation:) name:kRVVisitManagerDidExitLocationNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[RVNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public methods

- (void)getCustomer:(void (^)(RVCustomer *, NSString *))block {
    NSString *method = @"GET";
    NSString *path = [NSString stringWithFormat:@"customers/%@", self.customerID];
    
    [[RVNetworkingManager sharedManager] sendRequestWithMethod:method path:path parameters:nil success:^(NSDictionary *data) {
        RVCustomer *customer = [RVCustomer new];
        NSDictionary *JSON = [data objectForKey:customer.modelName];
        
        if (JSON) {
            [customer updateWithJSON:JSON];
        }
        
        if (block) {
            block(customer, nil);
        }
    } failure:^(NSError *error) {
        NSString *reason = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        if (block) {
            block(nil, reason);
        }
    }];
}

- (void)getCards:(void (^)(NSArray *, NSString *))block {
    [[RVNetworkingManager sharedManager] sendRequestWithMethod:@"GET" path:@"cards" parameters:@{ @"customer_id": self.customerID } success:^(NSDictionary *data) {
        
        NSArray *JSON = [data objectForKey:@"cards"];
        NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[JSON count]];
        
        [JSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            RVCard *card = [[RVCard alloc] initWithJSON:obj];
            [cards addObject:card];
        }];
        
        if (block) {
            block(cards, nil);
        }
    } failure:^(NSError *error) {
        NSString *reason = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        if (block) {
            block(nil, reason);
        }
    }];
}

- (void)startMonitoring {
    [[RVRegionManager sharedManager] startMonitoring];
}

- (void)stopMonitoring {
    [[RVRegionManager sharedManager] stopMonitoring];
}

- (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:UUID major:major identifier:UUID.UUIDString];
    [[RVNotificationCenter defaultCenter] postNotificationName:kRVRegionManagerDidEnterRegionNotification object:[RVRegionManager sharedManager] userInfo:@{ @"beaconRegion": beaconRegion }];
}

#pragma mark - Utility 

- (void)updateVisitOpenTime {
    self.currentVisit.openedAt = [NSDate date];
    [self.currentVisit save:nil failure:nil];
}

#pragma mark - Visit Manager Notifications

- (void)visitManagerDidEnterLocation:(NSNotification *)note {
    self.currentVisit = [note.userInfo objectForKey:@"visit"];
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [self updateVisitOpenTime];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidEnterLocationNotification object:self];
}

- (void)visitManagerDidExitLocation:(NSNotification *)note {    
    
}

#pragma mark - Application Notifications

- (void)applicationDidBecomeActive:(NSNotification *)note {
    if (self.currentVisit && !self.currentVisit.openedAt) {
        [self updateVisitOpenTime];
    }
}

@end
