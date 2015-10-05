//
//  Rover.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-23.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "Rover.h"

#import "RXFixedViewController.h"

@interface Rover () <RVVisitManagerDelegate, RXVisitViewControllerDelegate>

@property (readonly, strong, nonatomic) RVConfig *config;
@property (nonatomic, strong) RVVisitManager *visitManager;
@property (nonatomic, strong) RVVisit *currentVisit;
@property (nonatomic, strong) id<RoverDelegate> defaultDelegate;
@property (nonatomic, strong) UIViewController *modalViewController;
@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIWindow *applicationKeyWindow;

@end

@implementation Rover {
    RVCustomer *_customer;
    id<RoverDelegate> _delegate;
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

#pragma mark - Properties

- (RVCustomer *)customer {
    if (_customer) {
        return _customer;
    }
    
    _customer = [RVCustomer cachedCustomer];
    return _customer;
}

- (RVVisit *)currentVisit {
    if (_currentVisit && _visitManager.regionManager.currentRegions.count > 0) {
        CLBeaconRegion *beaconRegion = _visitManager.regionManager.currentRegions.anyObject;
        //if ([_currentVisit isInLocationRegion:beaconRegion]) {
            return _currentVisit;
        //};
    }
    
    if (_visitManager.latestVisit.isAlive) {
        return _visitManager.latestVisit;
    }
    
    return nil;
}

- (id<RoverDelegate>)delegate {
    if (_delegate) {
        return _delegate;
    }
    
    if (self.config.experience == RVExperienceNearby) {
        _defaultDelegate = [RVNearbyExperience new];
    } else if (self.config.experience == RVExperienceMessageFeed) {
        _defaultDelegate = [RVMessageFeedExperience new];
    }
    
    _delegate = _defaultDelegate;
    
    return _delegate;
}

- (void)setDelegate:(id<RoverDelegate>)delegate {
    _defaultDelegate = nil;
    _delegate = delegate;
}

#pragma mark - Initialization

- (instancetype)initWithConfig:(RVConfig *)config {
    self = [super init];
    if (self) {
        _config = config;
        
        _visitManager = [RVVisitManager new];
        _visitManager.delegate = self;
        
        if (config.serverURL) {
            RVNetworkingManager *networkingManager = [RVNetworkingManager sharedManager];
            networkingManager.baseURL = [NSURL URLWithString:config.serverURL];
        } else {
            NSLog(@"%@ warning empty server URL", self);
        }
        
        if ([config.applicationToken length]) {
            [[RVNetworkingManager sharedManager] setAuthToken:config.applicationToken];
        } else {
            NSLog(@"%@ warning empty application token", self);
        }
        
        if ([config.beaconUUIDs count]) {
            [_visitManager.regionManager setBeaconUUIDs:config.beaconUUIDs];
        } else {
            NSLog(@"%@ warning empty beacon uuids", self);
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public methods

- (id)configValueForKey:(NSString *)key {
    return [_config valueForKey:key];
}

- (void)startMonitoring {
    [_visitManager.regionManager startMonitoring];
}

- (void)stopMonitoring {
    [_visitManager.regionManager stopMonitoring];
}

- (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor duration:(NSTimeInterval)duration
{
    [_visitManager.regionManager simulateRegionEnterWithBeaconUUID:UUID major:major minor:minor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_visitManager.regionManager simulateRegionExitWithBeaconUUID:UUID major:major minor:minor];
    });
}

- (void)simulateBeaconWithUUID:(NSUUID *)UUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor {
    [self simulateBeaconWithUUID:UUID major:major minor:minor duration:30];
}

#pragma mark - Utility

- (void)presentModalWithDecks:(NSArray *)decks {
    
    if ([decks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVDeck *deck, NSDictionary *bindings) {
        return deck.cards.count > 0;
    }]].count == 0) {
        NSLog(@"%@ warning showModal called but there are no cards to display", self);
        return;
    }
    
    _modalViewController = [[self.config.modalViewControllerClass alloc] init];
    
    // Delegate
    if ([self.delegate respondsToSelector:@selector(roverWillDisplayModalViewController:)]) {
        [self.delegate roverWillDisplayModalViewController:_modalViewController];
    }
    
    if ([_modalViewController isKindOfClass:[RXVisitViewController class]]) {
        ((RXVisitViewController *)_modalViewController).delegate = self;
        
        [((RXVisitViewController *)_modalViewController) setDecks:[[decks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVDeck *deck, NSDictionary *bindings) {
            return deck.cards.count > 0;
        }]] mutableCopy]];
    }
    
    if ([_modalViewController isKindOfClass:[RXModalViewController class]]) {
        [((RXModalViewController *)_modalViewController) setBackdropBlurRadius:self.config.modalBackdropBlurRadius];
        [((RXModalViewController *)_modalViewController) setBackdropTintColor:self.config.modalBackdropTintColor];
    }
    
    //UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    //UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];
    //[currentViewController presentViewController:_modalViewController animated:YES completion:nil];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
    }
    
    // safety net in case our window becomes key for whatever reason
    _applicationKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    _window = [[UIWindow alloc] initWithFrame:frame];
    _window.hidden = NO;
    [_window setRootViewController:[RXFixedViewController new]];
    [_window.rootViewController presentViewController:_modalViewController animated:YES completion:nil];
    
    // Delegate
    if ([self.delegate respondsToSelector:@selector(roverDidDisplayModalViewController:)]) {
        [self.delegate roverDidDisplayModalViewController:_modalViewController];
    }
}

- (void)presentLocalNotification:(NSString *)message userInfo:(NSDictionary *)userInfo {
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.alertBody = message;
    
    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [userInfoDict setValue:@YES forKey:@"_rover"];
    note.userInfo = [NSDictionary dictionaryWithDictionary:userInfoDict];
    
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

#pragma mark - RVVisitManagerDelegate

- (void)visitManager:(RVVisitManager *)manager didEnterLocation:(RVLocation *)location visit:(RVVisit *)visit {
    // This should be the only place where we set this iVar
    _currentVisit = visit;
    
    [[RVImagePrefetcher sharedImagePrefetcher] prefetchURLs:_currentVisit.allImageUrls];

    // Delegate
    if ([self.delegate respondsToSelector:@selector(roverVisit:didEnterLocation:)]) {
        [self.delegate roverVisit:_currentVisit didEnterLocation:_currentVisit.location];
    }
}

- (void)visitManager:(RVVisitManager *)manager didPotentiallyExitLocation:(RVLocation *)location visit:(RVVisit *)visit {
    // Delegate
    if ([self.delegate respondsToSelector:@selector(roverVisit:didPotentiallyExitLocation:aliveForAnother:)]) {
        [self.delegate roverVisit:visit didPotentiallyExitLocation:visit.location aliveForAnother:visit.keepAlive];
    }
}

- (void)visitManager:(RVVisitManager *)manager didExpireVisit:(RVVisit *)visit {
    // Delegate
    if ([self.delegate respondsToSelector:@selector(roverVisitDidExpire:)]) {
        [self.delegate roverVisitDidExpire:visit];
    }
    
    _currentVisit = nil;
}

- (void)visitManager:(RVVisitManager *)manager didEnterTouchpoints:(NSArray *)touchpoints visit:(RVVisit *)visit {
    
    for (RVTouchpoint *touchpoint in touchpoints) {
        
        // Touchpoint Tracking
        [self trackEvent:@"touchpoint.enter" params:@{@"touchpoint": touchpoint.ID}];
        
        // TODO: get better with card tracking and using the `delivered` flag on RVDeck
        // Card Delivered Tracking
        RVDeck *deck = [visit deckWithID:touchpoint.deckId];
        if (deck) {
            for (RVCard *card in deck.cards) {
                [self trackEvent:@"card.deliver" params:@{@"card": card.ID}];
            }
        }
        
    }
    
    // Delegate
    if ([self.delegate respondsToSelector:@selector(roverVisit:didEnterTouchpoints:)]) {
        [self.delegate roverVisit:visit didEnterTouchpoints:touchpoints];
    }
    
}

- (void)visitManager:(RVVisitManager *)manager didExitTouchpoints:(NSArray *)touchpoints visit:(RVVisit *)visit {
    
    // Touchpoint tracking
    [touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {
        [self trackEvent:@"touchpoint.exit" params:@{@"touchpoint": touchpoint.ID}];
    }];
    
    // Delegate
    if ([self.delegate respondsToSelector:@selector(roverVisit:didExitTouchpoints:)]) {
        [self.delegate roverVisit:visit didExitTouchpoints:touchpoints];
    }
}

- (BOOL)visitManager:(RVVisitManager *)manager shouldCreateVisit:(RVVisit *)visit {
    visit.simulate = self.config.sandboxMode;
    
    // Delegate
    if ([self.delegate respondsToSelector:@selector(roverShouldCreateVisit:)]) {
        if (![self.delegate roverShouldCreateVisit:visit]) {
            return NO;
        }
    }
    
    [[RVNetworkingManager sharedManager] postVisit:visit];
    
    // Delegate
    if ([self.delegate respondsToSelector:@selector(roverDidCreateVisit:)]) {
        [self.delegate roverDidCreateVisit:visit];
    }
    
    return YES;
}


#pragma mark - Application Notifications

- (void)applicationDidFinishLaunching:(NSNotification *)note {
    // This async is needed because a UIWindow without a rootViewController may be added
    // at this point. There is no error, but this is just to silence the warning and also
    // differ any experience logic till after the launch
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self didOpenApplication];
        
        UILocalNotification *localNotification = [note.userInfo objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localNotification) {
            [self handleDidReceiveLocalNotification:localNotification];
        }
    });
}

- (void)applicationWillEnterForeground:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self didOpenApplication];
    });
}

- (void)didOpenApplication {
    if (self.currentVisit) {
        
        // Delegate
        if ([self.delegate respondsToSelector:@selector(didOpenApplicationDuringVisit:)]) {
            [self.delegate didOpenApplicationDuringVisit:self.currentVisit];
        }
    }
}

- (BOOL)handleDidReceiveLocalNotification:(UILocalNotification *)notification {
    if ([notification.userInfo objectForKey:@"_rover"] && self.currentVisit) {
        if ([self.delegate respondsToSelector:@selector(didReceiveRoverNotificationWithUserInfo:)]) {
            [self.delegate didReceiveRoverNotificationWithUserInfo:notification.userInfo];
        }
        return YES;
    }
    return NO;
}

#pragma mark - RXVisitViewControllerDelegate

- (void)visitViewController:(RXVisitViewController *)viewController didDisplayCard:(RVCard *)card {
    [self trackEvent:@"card.view" params:@{@"card": card.ID}];
    
    if ([self.delegate respondsToSelector:@selector(roverVisit:didDisplayCard:)]) {
        [self.delegate roverVisit:self.currentVisit didDisplayCard:card];
    }
}

- (void)visitViewController:(RXVisitViewController *)viewController didDiscardCard:(RVCard *)card {
    [self trackEvent:@"card.discard" params:@{@"card": card.ID}];
    
    if ([self.delegate respondsToSelector:@selector(roverVisit:didDiscardCard:)]) {
        [self.delegate roverVisit:self.currentVisit didDiscardCard:card];
    }
}

- (void)visitViewController:(RXVisitViewController *)viewController didClickCard:(RVCard *)card URL:(NSURL *)url {
    [self trackEvent:@"card.click" params:@{@"card": card.ID, @"url": url.absoluteString}];
    
    if ([self.delegate respondsToSelector:@selector(roverVisit:didClickCard:withURL:)]) {
        [self.delegate roverVisit:self.currentVisit didClickCard:card withURL:url];
    }
}

- (void)visitViewControllerDidGetDismissed:(RXVisitViewController *)viewController {
    _modalViewController = nil;
    _window.rootViewController = nil;
    _window = nil;
    
    if ([self.delegate respondsToSelector:@selector(roverDidDismissModalViewController)]) {
        [self.delegate roverDidDismissModalViewController];
    }
}

- (void)visitViewControllerWillGetDismissed:(RXVisitViewController *)viewController {
    [_applicationKeyWindow makeKeyWindow];
    _applicationKeyWindow = nil;
    if ([self.delegate respondsToSelector:@selector(roverWillDismissModalViewController:)]) {
        [self.delegate roverWillDismissModalViewController:viewController];
    }
}

@end
