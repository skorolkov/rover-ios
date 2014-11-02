//
//  RootViewController.m
//  Rover App
//
//  Created by Sean Rucker on 2014-09-11.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RootViewController.h"
#import "NewOffersViewController.h"

#import <Rover/Rover.h>

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roverDidEnterLocation) name:kRoverDidEnterLocationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roverDidDisplayCardNotification) name:kRoverDidDisplayCardNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[NewOffersViewController class]]) {
        [self displayModal];
        return NO;
    }
    return YES;
}

- (void)updateBadgeNumber {
    RVVisit *visit = [[Rover shared] currentVisit];
    int badgeNumber = (int)[visit.unreadCards count];
    
    UITabBarItem *item = [self.tabBar.items objectAtIndex:3];
    item.badgeValue = badgeNumber > 0 ? [NSString stringWithFormat:@"%d", badgeNumber] : nil;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
}

- (void)displayModal {
//    [[Rover shared] presentModal];
    [[Rover shared] presentModalForCardSet:ModalViewCardSetTagsInclude withOptions:@{ RVModalViewOptionsTag: @[@"tutorial"] }];
}

#pragma mark - Application Notifications

- (void)applicationDidBecomeActive {
    if ([[Rover shared] currentVisit].unreadCards.count > 0) {
        [self displayModal];
    }
}

#pragma mark - Rover Notifications

- (void)roverDidEnterLocation {
    [self updateBadgeNumber];
}

- (void)roverDidDisplayCardNotification {
    [self updateBadgeNumber];
}

@end