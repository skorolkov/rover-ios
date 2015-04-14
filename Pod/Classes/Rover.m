//
//  Rover.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-23.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "Rover.h"
#import "RVRegionManager.h"
#import "RVVisitManager.h"
#import "RVCustomerProject.h"
#import "RVLog.h"
#import "RVNotificationCenter.h"


// UI
#import "RXVisitViewController.h"
#import "RXDetailViewController.h"
#import "RXModalViewController.h"

// Networking
#import "RVNetworkingManager.h"
#import "RVImagePrefetcher.h"

@interface Rover ()

@property (readonly, strong, nonatomic) RVConfig *config;
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

- (BOOL)isCurrentlyVisiting {
    RVRegionManager *regionManager = [RVRegionManager sharedManager];
    if (_currentVisit && regionManager.currentRegions.count > 0) {
        CLBeaconRegion *beaconRegion = regionManager.currentRegions.anyObject;
        if ([_currentVisit isInLocationRegion:beaconRegion]) {
            return YES;
        };
    }
    
    RVVisitManager *visitManager = [RVVisitManager sharedManager];
    if (visitManager.latestVisit.isAlive) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Initialization

- (instancetype)initWithConfig:(RVConfig *)config {
    self = [super init];
    if (self) {
        _config = config;
        
        
        // By default Rover looks for RVNetowrkingManager
        
        Class networkingClass = NSClassFromString(@"RVNetworkingManager");
        __unused id networkingManager = [networkingClass performSelector:@selector(sharedManager)];

        
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
    
    // Visit Notificaiton
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roverDidCreateVisit:) name:kRoverDidCreateVisitNotification object:nil];
    
    // Card Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roverDidDisplayCard:) name:kRoverDidDisplayCardNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roverDidSwipeCard:) name:kRoverDidSwipeCardNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roverDidClickCard:) name:kRoverDidClickCardNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[RVNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public methods

- (id)configValueForKey:(NSString *)key {
    return [_config valueForKey:key];
}

- (void)startMonitoring {
    [[RVRegionManager sharedManager] startMonitoring];
}

- (void)stopMonitoring {
    [[RVRegionManager sharedManager] stopMonitoring];
}

- (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor
{
    [[RVRegionManager sharedManager] simulateBeaconWithUUID:UUID major:major minor:minor];
}

- (void)presentModal {
    
    if ([[RVVisit latestVisit].visitedTouchpoints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVTouchpoint *touchpoint, NSDictionary *bindings) {
        return touchpoint.cards.count > 0;
    }]].count == 0) {
        NSLog(@"%@ warning showModal called but there are no cards to display", self);
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverWillPresentModalNotification object:self];

    UIViewController *modalViewController = [[self.config.modalViewControllerClass alloc] init];
    
    if ([modalViewController isKindOfClass:[RXVisitViewController class]]) {
        [modalViewController performSelector:@selector(setVisitedTouchpoints:) withObject:self.currentVisit.visitedTouchpoints];
    }
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];
    [currentViewController presentViewController:modalViewController animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidPresentModalNotification object:self];
}

#pragma mark - Utility

- (void)sendNotification:(NSString *)message {
    // TODO: consider the case where the first noti has already been delivered (want to be silent)
    
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.alertBody = message;
    
    if (self.config.notificationSoundName) {
        note.soundName = self.config.notificationSoundName;
    }
    [[UIApplication sharedApplication] presentLocalNotificationNow:note];
}

- (void)trackEvent:(NSString *)event params:(NSDictionary *)params {
    NSLog(@"tacking %@ - load: %@", event, params);
    [[RVNetworkingManager sharedManager] trackEvent:event params:params visit:self.currentVisit];
}

#pragma mark - Visit Manager Notifications

- (void)visitManagerDidEnterLocation:(NSNotification *)note {
    
    // This should be the only place where we set this iVar
    _currentVisit = [note.userInfo objectForKey:@"visit"];
    
    [[RVImagePrefetcher sharedImagePrefetcher] prefetchURLs:_currentVisit.allImageUrls];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidEnterLocationNotification object:self userInfo:note.userInfo];
    
    [self trackEvent:@"location.enter" params:nil];
}

- (void)visitManagerDidPotentiallyExitLocation:(NSNotification *)note {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidPotentiallyExitLocationNotification object:self userInfo:note.userInfo];
    
    [self trackEvent:@"location.exit" params:nil];
}

- (void)visitManagerDidExpireVisit:(NSNotification *)note {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidExpireVisitNotification object:self userInfo:note.userInfo];
}

- (void)visitManagerDidEnterTouchpoint:(NSNotification *)note {
    RVTouchpoint *touchpoint = [note.userInfo objectForKey:@"touchpoint"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidEnterTouchpointNotification object:self userInfo:note.userInfo];
    
    
    // Touchpoint Tracking
    [self trackEvent:@"touchpoint.enter" params:@{@"touchpoint": touchpoint.ID}];
    
    // Card Delivered Tracking
    [touchpoint.cards enumerateObjectsUsingBlock:^(RVCard *card, NSUInteger idx, BOOL *stop) {
        [self trackEvent:@"card.deliver" params:@{@"card": card.ID}];
    }];
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        // do something else (banner or something)
        
        // Touchpoint Tracking
        [self trackEvent:@"touchpoint.open" params:@{@"touchpoint": touchpoint.ID}];
        
        if (!touchpoint.notificationDelivered) {
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];
            Class detailViewControllerClass = NSClassFromString(@"RXDetailViewController");
            
            
            if (self.config.autoPresentModal && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive && ![currentViewController isKindOfClass:_config.modalViewControllerClass] && ![currentViewController isKindOfClass:detailViewControllerClass]) {
                [self presentModal];
            }
        }
        
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidExitTouchpointNotification object:self userInfo:note.userInfo];
    
    [self trackEvent:@"touchpoint.exit" params:@{@"touchpoint": touchpoint.ID}];
}


#pragma mark - Application Notifications

- (void)applicationDidBecomeActive:(NSNotification *)note {

    if (self.currentVisit) {
        // Touchpoint Tracking
        [self.currentVisit.currentTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, BOOL *stop) {
            [self trackEvent:@"touchpoint.open" params:@{@"touchpoint": touchpoint.ID}];
        }];
        
        // Auto Modal
        if (self.config.autoPresentModal && self.currentVisit.visitedTouchpoints.count > 0) {

            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];
            
            if ([currentViewController isKindOfClass:[RXDetailViewController class]]) {
                [currentViewController dismissViewControllerAnimated:YES completion:nil];
            } else if (![currentViewController isKindOfClass:_config.modalViewControllerClass]) {
                
                [self presentModal];
            }
        }
    }

}

#pragma mark - Visit Notification

- (void)roverDidCreateVisit:(NSNotification *)note {
    RVVisit *visit = [note.userInfo objectForKey:@"visit"];
    [[RVNetworkingManager sharedManager] postVisit:visit];
}

#pragma mark - Card Notificaitons

- (void)roverDidDisplayCard:(NSNotification *)note {
    RVCard *card = [note.userInfo objectForKey:@"card"];
    [self trackEvent:@"card.view" params:@{@"card": card.ID}];
}

- (void)roverDidSwipeCard:(NSNotification *)note {
    RVCard *card = [note.userInfo objectForKey:@"card"];
    [self trackEvent:@"card.discard" params:@{@"card": card.ID}];
}

- (void)roverDidClickCard:(NSNotification *)note {
    RVCard *card = [note.userInfo objectForKey:@"card"];
    NSURL *url = [note.userInfo objectForKey:@"url"];
    [self trackEvent:@"card.click" params:@{@"card": card.ID, @"url": url.absoluteString}];
}

@end


@implementation RVConfig

+ (RVConfig *)defaultConfig {
    RVConfig *config = [[RVConfig alloc] init];
    config.allowedUserNotificationTypes = (UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound);
    config.notificationSoundName = UILocalNotificationDefaultSoundName;
    config.autoPresentModal = YES;
    config.sandboxMode = NO;
    config.modalViewControllerClass = [RXModalViewController class];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Rover" ofType:@"plist"];
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:path];
    
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

- (void)registerModalViewControllerClass:(Class)modalViewControllerClass {
    if (![modalViewControllerClass isSubclassOfClass:[UIViewController class]]) {
        NSLog(@"%@ warning - you must register a valid UIViewController class", self);
        return;
    }
    _modalViewControllerClass = modalViewControllerClass;
}

@end