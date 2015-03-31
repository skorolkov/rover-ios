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
    RVConfig *config = [RVConfig defaultConfig];
    config.autoPresentModal = YES;
    config.sandboxMode = NO;
    
    Rover *rover = [Rover setup:config];
    
    RVCustomer *customer = [[Rover shared] customer];
    customer.customerID = @"1234567";
    [customer set:@"contractor" to:@YES];
    [customer set:@"MyLowes" to:@YES];
    [customer setName:@"John Smith"];
    
    [rover startMonitoring];
    
    return YES;
}

@end
