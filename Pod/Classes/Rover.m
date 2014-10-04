//
//  Rover.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-23.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "Rover.h"
#import "RVNetworkingManager.h"
#import "RVRegionManager.h"
#import "RVVisitManager.h"
#import "RVCustomerProject.h"
#import "RVVisitProject.h"
#import "RVLog.h"
#import "RVNotificationCenter.h"
#import "RVModel.h"

NSString *const kRoverDidEnterLocationNotification = @"RoverDidEnterLocationNotification";

@interface Rover()

@property (strong, nonatomic) RVConfig *config;

@end

@implementation Rover {
    RVCustomer *_customer;
}

#pragma mark - Class methods

static Rover *sharedInstance = nil;

+ (Rover *)setup:(RVConfig *)config {
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:config.allowedUserNotificationTypes categories:nil]];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithConfig:config];
    });
    
    return sharedInstance;
}

+ (Rover *)shared {
    if (sharedInstance == nil) {
        NSLog(@"%@ warning shared called before setup:", self);
    }
    return sharedInstance;
}

#pragma mark - Properties

- (RVCustomer *)customer {
    if (_customer) {
        return _customer;
    }
    
    _customer = [RVCustomer cachedCustomer];
    return _customer;
}

#pragma mark - Initialization

- (instancetype)initWithConfig:(RVConfig *)config {
    self = [super init];
    if (self) {
        self.config = config;
        
        if (config.serverURL) {
            RVNetworkingManager *networkingManager = [RVNetworkingManager sharedManager];
            networkingManager.baseURL = [NSURL URLWithString:config.serverURL];
            networkingManager.loggingEnabled = YES;
        } else {
            NSLog(@"%@ warning empty server URL", self);
        }
        
        if ([config.applicationID length]) {
            NSString *authToken = [NSString stringWithFormat:@"Bearer %@", config.applicationID];
            [[RVNetworkingManager sharedManager] setAuthToken:authToken];
        } else {
            NSLog(@"%@ warning empty application id", self);
        }
        
        if ([config.beaconUUIDs count]) {
            [[RVRegionManager sharedManager] setBeaconUUIDs:config.beaconUUIDs];
        } else {
            NSLog(@"%@ warning empty beacon uuids", self);
        }
        
        // TODO: Fix this
        [RVVisitManager sharedManager];
        
        [self setupListeners];
    }
    return self;
}

- (void)setupListeners {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(visitManagerDidEnterLocation:) name:kRVVisitManagerDidEnterLocationNotification object:nil];
    [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(visitManagerDidExitLocation:) name:kRVVisitManagerDidExitLocationNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[RVNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public methods

- (void)getCards:(void (^)(NSArray *, NSString *))block {
    [[RVNetworkingManager sharedManager] sendRequestWithMethod:@"GET" path:@"cards" parameters:@{ @"customer_id": self.customer.customerID } success:^(NSDictionary *data) {
        
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
    _currentVisit = [note.userInfo objectForKey:@"visit"];
    
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



@implementation RVConfig

+ (RVConfig *)defaultConfig {
    RVConfig *config = [[RVConfig alloc] init];
    config.allowedUserNotificationTypes = (UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound);
    config.notificationSoundName = UILocalNotificationDefaultSoundName;
    config.serverURL = @"http://api.roverlabs.co/mobileapi/v1/";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Rover" ofType:@"plist"];
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    id serverURL = [plist objectForKey:@"serverURL"];
    if (serverURL) {
        if (![serverURL isKindOfClass:[NSString class]]) {
            NSLog(@"%@ warning serverURL property in Rover.plist is expected to be a string", self);
        } else if ([serverURL length]) {
            config.serverURL = serverURL;
        }
    }
    
    id applicationID = [plist objectForKey:@"applicationID"];
    if (applicationID) {
        if (![applicationID isKindOfClass:[NSString class]]) {
            NSLog(@"%@ warning applicationID property in Rover.plist is expected to be a string", self);
        } else if ([applicationID length]) {
            config.applicationID = applicationID;
        }
    }
    
    id beaconUUIDs = [plist objectForKey:@"beaconUUIDs"];
    if (beaconUUIDs) {
        if (![beaconUUIDs isKindOfClass:[NSArray class]]) {
            NSLog(@"%@ warning beaconUUIDs property in Rover.plist is expected to be an array", self);
        } else if ([beaconUUIDs count]) {
            [beaconUUIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (obj) {
                    if (![obj isKindOfClass:[NSString class]]) {
                        NSLog(@"%@ warning each item in beaconUUIDs is expected to be a string", self);
                    } else if ([obj length]) {
                        [config addBeaconUUID:obj];
                    }
                }
            }];
        }
    }
    
    return config;
}

- (void)addBeaconUUID:(NSString *)UUIDString {
    NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:UUIDString];
    if (self.beaconUUIDs) {
        _beaconUUIDs = [self.beaconUUIDs arrayByAddingObject:UUID];
    } else {
        _beaconUUIDs = [NSArray arrayWithObject:UUID];
    }
}

@end