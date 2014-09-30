//
//  AppDelegate.m
//  Rover App
//
//  Created by Sean Rucker on 2014-07-15.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <Rover/Rover.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Staging
    NSString *appID = @"13dd067dd82c8d386a7d01eefe3ab555765f1c4e3a2e09b014615bf9a4e8f9b8";
    
    // Production
//    NSString *appID = @"eae9edb6352b8fec6618d3d9cb96f2e795e1c2df1ad5388af807b05d8dfcd7d6";
    
    [Rover setApplicationID:appID beaconUUIDs:@[@"6C21D507-C7F7-42C5-BA24-ADF3010BC612"]];    
    [Rover startMonitoring];
    
    return YES;
}

@end
