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
#import "RVVisit.h"
#import "RVLog.h"
#import "RVNotificationCenter.h"
#import "RVModel.h"

#import "RXModalViewController.h"
#import "RXDetailViewController.h"

#import <SDWebImage/SDWebImagePrefetcher.h>
#import "RVImagePrefetcher.h"

NSString *const kRoverDidExitTouchpointNotification = @"RoverDidExitTouchpointNotification";
NSString *const kRoverDidEnterTouchpointNotification = @"RoverDidEnterTouchpointNotification";
NSString *const kRoverDidEnterLocationNotification = @"RoverDidEnterLocationNotification";
NSString *const kRoverDidExpireVisitNotification = @"RoverDidExpireVisitNotification";
NSString *const kRoverWillPresentModalNotification = @"RoverWillPresentModalNotification";
NSString *const kRoverDidPresentModalNotification = @"RoverDidPresentModalNotification";
NSString *const kRoverWillDismissModalNotification = @"RoverWillDismissModalNotification";
NSString *const kRoverDidDismissModalNotification = @"RoverDidDismissModalNotification";
NSString *const kRoverDidDisplayCardNotification = @"RoverDidDisplayCardNotification";
NSString *const kRoverDidSwipeCardNotification = @"RoverDidSwipeCardNotification";


@interface Rover ()

@property (nonatomic, strong) RVVisit *currentVisit;

@end

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

- (RVVisit *)currentVisit {
    RVRegionManager *regionManager = [RVRegionManager sharedManager];
    if (_currentVisit && regionManager.currentRegions.count > 0) {
        CLBeaconRegion *beaconRegion = regionManager.currentRegions.anyObject;
        if ([_currentVisit isInLocationRegion:beaconRegion]) {
            return _currentVisit;
        };
    }
    
    RVVisitManager *visitManager = [RVVisitManager sharedManager];
    if (visitManager.latestVisit.isAlive) {
        return visitManager.latestVisit;
    }
    
    return nil;
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
    
    // Location Notifications
    [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(visitManagerDidEnterLocation:) name:kRVVisitManagerDidEnterLocationNotification object:nil];
    [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(visitManagerDidPotentiallyExitLocation:) name:kRVVisitManagerDidPotentiallyExitLocationNotification object:nil];
    [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(visitManagerDidExpireVisit:) name:kRVVisitManagerDidExpireVisitNotification object:nil];
    
    // Touchpoint Notifications
    [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(visitManagerDidEnterTouchpoint:) name:kRVVisitManagerDidEnterTouchpointNotification object:nil];
    [[RVNotificationCenter defaultCenter] addObserver:self selector:@selector(visitManagerDidExitTouchpoint:) name:kRVVisitManagerDidExitTouchpointNotification object:nil];
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

- (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor
{
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:UUID major:major minor:minor identifier:UUID.UUIDString];
    [[RVNotificationCenter defaultCenter] postNotificationName:kRVRegionManagerDidEnterRegionNotification object:[RVRegionManager sharedManager] userInfo:@{ @"beaconRegion": beaconRegion }];
}

- (void)presentModal {
    
    //<<<<<<< HEAD
    //    if (!_currentVisit || _currentVisit.cards.count < 1) {
    //        NSLog(@"%@ warning showModal called but there are no cards to display", self);
    //        //return;
    //    }
    //=======
    ////    if (!self.currentVisit || self.currentVisit.cards.count < 1) {
    ////        NSLog(@"%@ warning showModal called but there are no cards to display", self);
    ////        //return;
    ////    }
    //>>>>>>> lots of ui
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverWillPresentModalNotification object:self];

    RXModalViewController *modalViewController = [RXModalViewController new];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];
    [currentViewController presentViewController:modalViewController animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidPresentModalNotification object:self];
}

#pragma mark - Utility 

- (void)updateVisitOpenTime {
    if (!_currentVisit) {
        return;
    }
    
    //_currentVisit.openedAt = [NSDate date];
    //[_currentVisit save:nil failure:nil];
}

- (void)sendNotification:(NSString *)message {
    // TODO: consider the case where a noti has already been delivered (want to be silent)
    
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.alertBody = message;
    
    if (self.config.notificationSoundName) {
        note.soundName = self.config.notificationSoundName;
    }
    [[UIApplication sharedApplication] presentLocalNotificationNow:note];
}

#pragma mark - Visit Manager Notifications

- (void)visitManagerDidEnterLocation:(NSNotification *)note {
    // TODO: theres an error doing this cause of RVVisitController and how its observing a deallocated object
    // CHANGING MAJOR NUMBERS CAUSES THIS
    // IT SHOULD FAIL GRADEFULLy
    _currentVisit = [note.userInfo objectForKey:@"visit"];
    
    [[RVImagePrefetcher sharedImagePrefetcher] prefetchURLs:_currentVisit.allImageUrls];
    
    
    // TODO: redo all this
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [self updateVisitOpenTime];
        
        if (self.config.autoPresentModal) {
            [self presentModal];
        }
    } else {
        //[self sendNotification];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidEnterLocationNotification object:self];
    
    // Location tracking - NOTE: this should move somewhere else when geofencing and stuff
    
    [_currentVisit trackEvent:@"location.enter" params:nil];
}

- (void)visitManagerDidPotentiallyExitLocation:(NSNotification *)note {
    [_currentVisit trackEvent:@"location.exit" params:nil];
}

- (void)visitManagerDidExpireVisit:(NSNotification *)note {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidExpireVisitNotification object:self];
}

- (void)visitManagerDidEnterTouchpoint:(NSNotification *)note {
    _currentVisit = [note.userInfo objectForKey:@"visit"];
    RVTouchpoint *touchpoint = [note.userInfo objectForKey:@"touchpoint"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidEnterTouchpointNotification object:self];
    
    // Touchpoint tracking
    
    [_currentVisit trackEvent:@"touchpoint.enter" params:@{@"touchpoint": touchpoint.ID}];
    
    // Card delivered tracking

    [touchpoint.cards enumerateObjectsUsingBlock:^(RVCard *card, NSUInteger idx, BOOL *stop) {
        [_currentVisit trackEvent:@"card.deliver" params:@{ @"card": card.ID }];
    }];
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        // do something else (banner or something)
        
        // Touchpoint tracking
        [self.currentVisit trackEvent:@"touchpoint.open" params:@{@"touchpoint": touchpoint.ID}];

        touchpoint.notificationDelivered = YES;
    } else if (!touchpoint.notificationDelivered) {
        
        if (touchpoint.notification) {
            [self sendNotification:touchpoint.notification];
        }
        
        touchpoint.notificationDelivered = YES;
    }
}

- (void)visitManagerDidExitTouchpoint:(NSNotification *)note {
    RVTouchpoint *touchpoint = [note.userInfo objectForKey:@"touchpoint"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidExitTouchpointNotification object:self];

    [self.currentVisit trackEvent:@"touchpoint.exit" params:@{@"touchpoint": touchpoint.ID}];
}


#pragma mark - Application Notifications

- (void)applicationDidBecomeActive:(NSNotification *)note {

    
    // TODO: do a card count check as well
    
    
    // Auto Modal
    
    if (self.config.autoPresentModal && self.currentVisit && _currentVisit.visitedTouchpoints.count > 0 ) {
        
        // TODO: must do a check for custom modal classes
        
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];

        // TODO: do class from string cause RX may not be present
        
        if ([currentViewController isKindOfClass:[RXDetailViewController class]]) {
            [currentViewController dismissViewControllerAnimated:YES completion:nil];
        } else if (![currentViewController isKindOfClass:[RXModalViewController class]]) {
            [self presentModal];
        }
    }
    
    // Touchpoint tracking
    
    if (self.currentVisit && self.currentVisit.currentTouchpoints) {
        [self.currentVisit.currentTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
            [self.currentVisit trackEvent:@"touchpoint.open" params:@{@"touchpoint": touchpoint.ID}];
        }];
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