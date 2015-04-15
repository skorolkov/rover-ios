//
//  Rover.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-23.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "Rover.h"

// Core
#import "RVRegionManager.h"
#import "RVVisitManager.h"

// Model
#import "RVCustomerProject.h"
#import "RVLog.h"

// UI
#import "RXVisitViewController.h"
#import "RXDetailViewController.h"
#import "RXModalViewController.h"

// Networking
#import "RVNetworkingManager.h"
#import "RVImagePrefetcher.h"


NSString *const kRoverWillPresentModalNotification = @"RoverWillPresentModalNotification";
NSString *const kRoverDidPresentModalNotification = @"RoverDidPresentModalNotification";

@interface Rover ()

@property (readonly, strong, nonatomic) RVConfig *config;
@property (nonatomic, strong) RVVisit *currentVisit;

@property (nonatomic, strong) UIViewController *modalViewController;

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
        
        if (config.serverURL) {
            RVNetworkingManager *networkingManager = [RVNetworkingManager sharedManager];
            networkingManager.baseURL = [NSURL URLWithString:config.serverURL];
        } else {
            NSLog(@"%@ warning empty server URL", self);
        }
        
        if ([config.applicationID length]) {
            [[RVNetworkingManager sharedManager] setAuthToken:config.applicationID];
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
    NSNotificationCenter *defaultNotificationCenter = [NSNotificationCenter defaultCenter];
    
    [defaultNotificationCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // Location Notifications
    [defaultNotificationCenter addObserver:self selector:@selector(visitManagerDidEnterLocation:) name:kRoverDidEnterLocationNotification object:nil];
    [defaultNotificationCenter addObserver:self selector:@selector(visitManagerDidPotentiallyExitLocation:) name:kRoverDidPotentiallyExitLocationNotification object:nil];
    [defaultNotificationCenter addObserver:self selector:@selector(visitManagerDidExpireVisit:) name:kRoverDidExpireVisitNotification object:nil];
    
    // Touchpoint Notifications
    [defaultNotificationCenter addObserver:self selector:@selector(visitManagerDidEnterTouchpoint:) name:kRoverDidEnterTouchpointNotification object:nil];
    [defaultNotificationCenter addObserver:self selector:@selector(visitManagerDidExitTouchpoint:) name:kRoverDidExitTouchpointNotification object:nil];
    
    // Visit Notificaitons
    [defaultNotificationCenter addObserver:self selector:@selector(roverDidCreateVisit:) name:kRoverDidCreateVisitNotification object:nil];
    [defaultNotificationCenter addObserver:self selector:@selector(roverDidVisitTouchpoint:) name:kRoverDidVisitTouchpointNotification object:nil];
    
    // Card Notifications
    [defaultNotificationCenter addObserver:self selector:@selector(roverDidDisplayCard:) name:kRoverDidDisplayCardNotification object:nil];
    [defaultNotificationCenter addObserver:self selector:@selector(roverDidSwipeCard:) name:kRoverDidSwipeCardNotification object:nil];
    [defaultNotificationCenter addObserver:self selector:@selector(roverDidClickCard:) name:kRoverDidClickCardNotification object:nil];
    
    // Modal Notifications
    [defaultNotificationCenter addObserver:self selector:@selector(roverDidDismissModal:) name:kRoverDidDismissModalNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    if ([self.currentVisit.visitedTouchpoints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVTouchpoint *touchpoint, NSDictionary *bindings) {
        return touchpoint.cards.count > 0;
    }]].count == 0) {
        NSLog(@"%@ warning showModal called but there are no cards to display", self);
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverWillPresentModalNotification object:self];

    _modalViewController = [[self.config.modalViewControllerClass alloc] init];
    
    if ([_modalViewController isKindOfClass:[RXVisitViewController class]]) {
        [((RXVisitViewController *)_modalViewController) setTouchpoints:self.currentVisit.visitedTouchpoints];
    }
    
    if ([_modalViewController isKindOfClass:[RXModalViewController class]]) {
        [((RXModalViewController *)_modalViewController) setBackdropBlurRadius:self.config.modalBackdropBlurRadius];
        [((RXModalViewController *)_modalViewController) setBackdropTintColor:self.config.modalBackdropTintColor];
    }
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];
    [currentViewController presentViewController:_modalViewController animated:YES completion:nil];
    
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
    if (self.currentVisit) {
        [[RVNetworkingManager sharedManager] trackEvent:event params:params visit:self.currentVisit];
    }
}

#pragma mark - Visit Manager Notifications

- (void)visitManagerDidEnterLocation:(NSNotification *)note {
    
    // This should be the only place where we set this iVar
    _currentVisit = [note.userInfo objectForKey:@"visit"];
    
    [[RVImagePrefetcher sharedImagePrefetcher] prefetchURLs:_currentVisit.allImageUrls];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidEnterLocationNotification object:self userInfo:note.userInfo];
    
    [self trackEvent:@"location.enter" params:nil];
    
    // Delegate
    if ([self.delegate respondsToSelector:@selector(roverVisit:didEnterLocation:)]) {
        [self.delegate roverVisit:_currentVisit didEnterLocation:_currentVisit.location];
    }
}

- (void)visitManagerDidPotentiallyExitLocation:(NSNotification *)note {
    //[[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidPotentiallyExitLocationNotification object:self userInfo:note.userInfo];
    
    [self trackEvent:@"location.exit" params:nil];
    
    // Delegate
    if ([self.delegate respondsToSelector:@selector(roverVisit:didPotentiallyExitLocation:aliveForAnother:)]) {
        RVVisit *visit = [note.userInfo objectForKey:@"visit"];
        [self.delegate roverVisit:visit didPotentiallyExitLocation:visit.location aliveForAnother:visit.keepAlive];
    }
}

- (void)visitManagerDidExpireVisit:(NSNotification *)note {
    //[[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidExpireVisitNotification object:self userInfo:note.userInfo];
    if ([self.delegate respondsToSelector:@selector(roverVisitDidExpire:)]) {
        RVVisit *visit = [note.userInfo objectForKey:@"visit"];
        [self.delegate roverVisitDidExpire:visit];
    }
}

- (void)visitManagerDidEnterTouchpoint:(NSNotification *)note {
    RVVisit *visit = [note.userInfo objectForKey:@"visit"];
    RVTouchpoint *touchpoint = [note.userInfo objectForKey:@"touchpoint"];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidEnterTouchpointNotification object:self userInfo:note.userInfo];
    
    
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
            
            if (self.config.autoPresentModal && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive && ![currentViewController isKindOfClass:_config.modalViewControllerClass] && ![currentViewController isKindOfClass:[RXDetailViewController class]]) {
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
    
    
    if ([self.delegate respondsToSelector:@selector(roverVisit:didEnterTouchpoint:)]) {
        [self.delegate roverVisit:visit didEnterTouchpoint:touchpoint];
    }

}

- (void)visitManagerDidExitTouchpoint:(NSNotification *)note {
    RVVisit *visit = [note.userInfo objectForKey:@"visit"];
    RVTouchpoint *touchpoint = [note.userInfo objectForKey:@"touchpoint"];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidExitTouchpointNotification object:self userInfo:note.userInfo];
    
    [self trackEvent:@"touchpoint.exit" params:@{@"touchpoint": touchpoint.ID}];
    
    if ([self.delegate respondsToSelector:@selector(roverVisit:didExitTouchpoint:)]) {
        [self.delegate roverVisit:visit didExitTouchpoint:touchpoint];
    }
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
    
    // TODO: delegate method for didOpenAppInTouchpoints:(NSArray *)touchpoints

}

#pragma mark - Visit Notification

- (void)roverDidCreateVisit:(NSNotification *)note {
    RVVisit *visit = [note.userInfo objectForKey:@"visit"];
    
    if ([self.delegate respondsToSelector:@selector(roverShouldCreateVisit:)]) {
        if (![self.delegate roverShouldCreateVisit:visit]) {
            visit.valid = NO;
            return;
        }
    }
    
    [[RVNetworkingManager sharedManager] postVisit:visit];
    
    if ([self.delegate respondsToSelector:@selector(roverDidCreateVisit:)]) {
        [self.delegate roverDidCreateVisit:visit];
    }
}

- (void)roverDidVisitTouchpoint:(NSNotification *)note {
    if (_modalViewController && [_modalViewController isKindOfClass:[RXVisitViewController class]]) {
        RVTouchpoint *touchpoint =[note.userInfo objectForKey:@"touchpoint"];
        [((RXVisitViewController *)_modalViewController) didAddTouchpoint:touchpoint];
    }
}

#pragma mark - Card Notificaitons

- (void)roverDidDisplayCard:(NSNotification *)note {
    RVCard *card = [note.userInfo objectForKey:@"card"];
    [self trackEvent:@"card.view" params:@{@"card": card.ID}];
    
    if ([self.delegate respondsToSelector:@selector(roverVisit:didDisplayCard:)]) {
        [self.delegate roverVisit:self.currentVisit didDisplayCard:card];
    }
}

- (void)roverDidSwipeCard:(NSNotification *)note {
    RVCard *card = [note.userInfo objectForKey:@"card"];
    [self trackEvent:@"card.discard" params:@{@"card": card.ID}];
    
    if ([self.delegate respondsToSelector:@selector(roverVisit:didDiscardCard:)]) {
        [self.delegate roverVisit:self.currentVisit didDiscardCard:card];
    }
}

- (void)roverDidClickCard:(NSNotification *)note {
    RVCard *card = [note.userInfo objectForKey:@"card"];
    NSURL *url = [note.userInfo objectForKey:@"url"];
    [self trackEvent:@"card.click" params:@{@"card": card.ID, @"url": url.absoluteString}];
    
    if ([self.delegate respondsToSelector:@selector(roverVisit:didClickCard:withURL:)]) {
        [self.delegate roverVisit:self.currentVisit didClickCard:card withURL:url];
    }
}

#pragma mark - Modal Notifications

- (void)roverDidDismissModal:(NSNotification *)note {
    _modalViewController = nil;
}

@end
