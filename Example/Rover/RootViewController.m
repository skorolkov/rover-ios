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

- (void)displayModal {
    [[Rover shared] presentModal];
}


@end