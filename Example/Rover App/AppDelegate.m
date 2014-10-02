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
    NSString *appID = @"1480a683aadb602fc71f678f79dbbb0ae93ed272e90d9aa92e31f519c86883f8";
    
    // Production
//    NSString *appID = @"eae9edb6352b8fec6618d3d9cb96f2e795e1c2df1ad5388af807b05d8dfcd7d6";
    
    [Rover setApplicationID:appID beaconUUIDs:@[@"EDA978A7-513C-442A-9364-3F14E74F80EC"]];    
    [Rover startMonitoring];
    
    return YES;
}

@end
