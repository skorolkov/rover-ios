//
//  AppDelegate.m
//  Rover App
//
//  Created by Sean Rucker on 2014-07-15.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <Rover/Rover.h>

@interface AppDelegate () <RoverDelegate>

@end

@implementation AppDelegate
            
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RVConfig *config = [RVConfig defaultConfig];
    
    // When a visit is triggered/simulated the modal is displayed automatically
    config.autoPresentModal = YES;
    
    // In sandbox mode visit analytics arent tracked
    config.sandboxMode = YES;
    
    config.accumulatingTouchpoints = YES;
    
    Rover *rover = [Rover setup:config];
    
    [rover startMonitoring];
    
    return YES;
}

@end
