//
//  RootViewController.m
//  Rover App
//
//  Created by Sean Rucker on 2014-09-11.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RootViewController.h"
#import "NewOffersViewController.h"
#import "CustomModalViewController.h"

#import <Rover/Rover.h>

@interface RootViewController () <RVModalViewControllerDelegate>

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
    //[[Rover shared] presentModal];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentViewController = (UIViewController *)[Rover findCurrentViewController:rootViewController];
    CustomModalViewController *vc = [CustomModalViewController new];
    vc.delegate = self;
    [currentViewController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Application Notifications

- (void)applicationDidBecomeActive {
    RVVisit *currentVisit = [[Rover shared] currentVisit];
    if (currentVisit.unreadCards.count > 0 && !currentVisit.openedAt) {
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

#pragma mark - ModalViewController delegate

- (void)modalViewControllerDidFinish:(RVModalViewController *)modalViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end