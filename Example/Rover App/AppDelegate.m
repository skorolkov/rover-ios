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
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    // SuperMart
    NSString *appID = @"1480a683aadb602fc71f678f79dbbb0ae93ed272e90d9aa92e31f519c86883f8";
    NSArray *beaconUUIDs = @[@"EDA978A7-513C-442A-9364-3F14E74F80EC"];
    
    [Rover setApplicationID:appID beaconUUIDs:beaconUUIDs];
    [Rover startMonitoring];
    
    return YES;
}

@end
