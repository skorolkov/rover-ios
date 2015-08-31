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

@property (nonatomic, strong) RVNearbyExperience *roverExperience;

@end

@implementation AppDelegate
            
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self redirectConsoleLogToDocumentFolder];
    
    RVConfig *config = [RVConfig defaultConfig];
    
    // In sandbox mode visit analytics arent tracked
    config.sandboxMode = NO;
    
    //config.experience = RVExperienceRetail;
    
    Rover *rover = [Rover setup:config];
    
    _roverExperience = [[RVMessageFeedExperience alloc] init];
    rover.delegate = _roverExperience;
    
    [rover startMonitoring];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if ([[Rover shared] handleDidReceiveLocalNotification:notification]) {
        return;
    }
}

- (void) redirectConsoleLogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    freopen([logPath fileSystemRepresentation],"a+",stderr);
}

@end
