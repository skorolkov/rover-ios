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
    
    // SuperMart
    //NSString *appID = @"1480a683aadb602fc71f678f79dbbb0ae93ed272e90d9aa92e31f519c86883f8";
    //NSArray *beaconUUIDs = @[@"EDA978A7-513C-442A-9364-3F14E74F80EC"];
    NSString *appID = @"13dd067dd82c8d386a7d01eefe3ab555765f1c4e3a2e09b014615bf9a4e8f9b8";
    NSArray *beaconUUIDs = @[@"6C21D507-C7F7-42C5-BA24-ADF3010BC612"];
    
    [Rover setApplicationID:appID beaconUUIDs:beaconUUIDs];
    [Rover startMonitoring];
    
    //[Rover setCustomerID:@"AMCOLECTORNUMBERGOESHERE"];
    
    return YES;
}

/*
- (void)signUpSuccess:(NSDictionary *)attrs {
    
    NSString *gender = [attrs objectForKey:@"gender"];
    NSString *phone = [attrs objectForKey:@"phone"];
    
    // THIS IS UGLY AND CONFUSING
    
    [Rover getCustomer:^(RVCustomer *customer, NSString *error) {
        
        if (customer) {
            [customer setAttribute:@"gender" value:gender];
            [customer setAttribute:@"phone" value:phone];
            [customer save:^{
                // good!
            } failure:^(NSString *reason) {
                // something went wrong.. now what?
            }];
        } else {
            // something went wrong, fetching the customer
        }
    }];
    
    // THIS IS PRETTY
    
    [Rover set:@"phone" to:phone];
    [Rover set:@"gender" to:gender];
    
    /* behind the scenes this needs to queue up some customer properties that need to be saved. they need to be store in NSUserDefaults so if the phone dies and app restarts before there is  ahcance to save they can be saved next time. The properties should be saved when the customer visits a store and should be set *jsut* before the POST /visits. I.e. queue up a PUT /customers call right before the POST /visits. The customer call MUST be done first in case the properties are needed for segmentation.
     */
//}

@end
