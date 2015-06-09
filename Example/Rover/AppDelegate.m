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

@property (nonatomic, strong) RVRetailExperience *roverExperience;

@end

@implementation AppDelegate
            
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RVConfig *config = [RVConfig defaultConfig];
    
    // In sandbox mode visit analytics arent tracked
    config.sandboxMode = YES;
    
    //config.experience = RVExperienceRetail;
    
    Rover *rover = [Rover setup:config];
    
    _roverExperience = [[RVSimpleExperience alloc] init];
    rover.delegate = _roverExperience;
    
    [rover startMonitoring];
    
    return YES;
}

@end
