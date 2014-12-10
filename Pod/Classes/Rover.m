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
NSString *const kRoverWillPresentModalNotification = @"RoverWillPresentModalNotification";
NSString *const kRoverDidPresentModalNotification = @"RoverDidPresentModalNotification";
NSString *const kRoverWillDismissModalNotification = @"RoverWillDismissModalNotification";
NSString *const kRoverDidDismissModalNotification = @"RoverDidDismissModalNotification";
NSString *const kRoverDidDisplayCardNotification = @"RoverDidDisplayCardNotification";
NSString *const kRoverDidSwipeCardNotification = @"RoverDidSwipeCardNotification";


@implementation Rover {
    RVCustomer *_customer;
}

#pragma mark - Class methods

static Rover *sharedInstance = nil;

+ (Rover *)setup:(RVConfig *)config {
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        Class userSettingClass = NSClassFromString(@"UIUserNotificationSettings");
        if (userSettingClass) {
            [application registerUserNotificationSettings:[userSettingClass settingsForTypes:config.allowedUserNotificationTypes categories:nil]];
        }
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

+ (UIViewController *)findCurrentViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        return [Rover findCurrentViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *svc = (UISplitViewController *)vc;
        if (svc.viewControllers.count > 0) {
            return [Rover findCurrentViewController:svc.viewControllers.lastObject];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nvc = (UINavigationController *)vc;
        if (nvc.viewControllers.count > 0) {
            return [Rover findCurrentViewController:nvc.topViewController];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tbc = (UITabBarController *)vc;
        if (tbc.viewControllers.count > 0) {
            return [Rover findCurrentViewController:tbc.selectedViewController];
        } else {
            return vc;
        }
    } else {
        return vc;
    }
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
        _config = config;
        
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

- (void)savedCards:(void (^)(NSArray *, NSString *))block {
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

- (void)presentModal {
    [self presentModalForCardSet:ModalViewCardSetAll withOptions:nil];
}

- (void)presentModalForCardSet:(ModalViewCardSet)cardSet withOptions:(NSDictionary *)options {
    
    if (!self.currentVisit || self.currentVisit.cards.count < 1) {
        NSLog(@"%@ warning showModal called but there are no cards to display", self);
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverWillPresentModalNotification object:self];
    
    RVModalViewController *modalViewController = [[RVModalViewController alloc] init];
    modalViewController.delegate = self;
    modalViewController.cardSet = cardSet;
    modalViewController.options = options;
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];
    [currentViewController presentViewController:modalViewController animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidPresentModalNotification object:self];
}

#pragma mark - Utility 

- (void)updateVisitOpenTime {
    if (!self.currentVisit) {
        return;
    }
    
    self.currentVisit.openedAt = [NSDate date];
    [self.currentVisit save:nil failure:nil];
}

- (void)sendNotification {
    if (!self.currentVisit || self.currentVisit.cards.count < 1) {
        return;
    }
    
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.alertBody = self.currentVisit.welcomeMessage;
    if (self.config.notificationSoundName) {
        note.soundName = self.config.notificationSoundName;
    }
    [[UIApplication sharedApplication] presentLocalNotificationNow:note];
}

#pragma mark - Visit Manager Notifications

- (void)visitManagerDidEnterLocation:(NSNotification *)note {
    _currentVisit = [note.userInfo objectForKey:@"visit"];
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [self updateVisitOpenTime];
        
        if (self.config.autoPresentModal) {
            [self presentModal];
        }
    } else {
        [self sendNotification];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidEnterLocationNotification object:self];
}

- (void)visitManagerDidExitLocation:(NSNotification *)note {    
    
}

#pragma mark - RVModalViewControllerDelegate

- (void)modalViewControllerDidFinish:(RVModalViewController *)modalViewController {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverWillDismissModalNotification object:self];
    [modalViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidDismissModalNotification object:self];
}

- (void)modalViewController:(RVModalViewController *)modalViewController didDisplayCard:(RVCard *)card {
    NSDictionary *userInfo = @{ @"card": card };
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidDisplayCardNotification object:self userInfo:userInfo];
}

- (void)modalViewController:(RVModalViewController *)modalViewController didSwipeCard:(RVCard *)card {
    NSDictionary *userInfo = @{ @"card": card };
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidSwipeCardNotification object:self userInfo:userInfo];
}

#pragma mark - Application Notifications

- (void)applicationDidBecomeActive:(NSNotification *)note {
    if (self.currentVisit && !self.currentVisit.openedAt) {
        
        [self updateVisitOpenTime];
        
        if (self.config.autoPresentModal) {
            [self presentModal];
        }
    }
}

@end



@implementation RVConfig

+ (RVConfig *)defaultConfig {
    RVConfig *config = [[RVConfig alloc] init];
    config.allowedUserNotificationTypes = (UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound);
    config.notificationSoundName = UILocalNotificationDefaultSoundName;
    config.autoPresentModal = YES;
    config.serverURL = @"http://api.roverlabs.co/mobileapi/v1/";
    config.modalBackdropBlurRadius = 3;
    config.modalBackdropTintColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
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