//
//  RVLog.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-16.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVLog.h"
#import "Rover.h"

NSString *const kRoverDidExitLocationNotification = @"RoverDidExitLocationNotification";
NSString *const kRoverAlreadyVisitingNotification = @"RoverAlreadyVisitingNotification";

NSString *const kRoverWillPostVisitNotification = @"RoverWillPostVisitNotification";
NSString *const kRoverDidPostVisitNotification = @"RoverDidPostVisitNotification";
NSString *const kRoverPostVisitFailedNotification = @"RoverPostVisitFailedNotification";

NSString *const kRoverWillUpdateCustomerNotification = @"RoverWillUpdateCustomerNotification";
NSString *const kRoverDidUpdateCustomerNotification = @"RoverDidUpdateCustomerNotification";
NSString *const kRoverUpdateCustomerFailedNotification = @"RoverUpdateCustomerFailedNotification";

NSString *const kRoverWillUpdateExitTimeNotification = @"RoverWillUpdateExitTimeNotification";
NSString *const kRoverDidUpdateExitTimeNotification = @"RoverDidUpdateExitTimeNotification";
NSString *const kRoverUpdateExitTimeFailedNotification = @"RoverUpdateExitTimeFailedNotification";

NSString *const kRoverDidEnterRegionNotification = @"RoverDidEnterRegionNotification";
NSString *const kRoverDidExitRegionNotification = @"RoverDidExitRegionNotification";
NSString *const kRoverDidDetermineStateNotification = @"RoverDidDetermineStateNotification";
NSString *const kRoverDidRangeBeaconsNotification = @"RoverDidRangeBeaconsNotification";

void RVLog(NSString *name, NSDictionary *data) {
    NSString *description = [name copy];

    if ([description hasPrefix:@"Rover"]) {
        description = [description substringFromIndex:[@"Rover" length]];
    }
    
    if ([description hasSuffix:@"Notification"]) {
        description = [description substringToIndex:[description length] - [@"Notification" length]];
    }
    
    if (data) {
        NSString *values = [[data allValues] componentsJoinedByString:@", "];
        description = [NSString stringWithFormat:@"%@: %@", description, values];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:data];
    [userInfo addEntriesFromDictionary:@{ @"description": description }];
    
//    dispatch_queue_t currentQueue = dispatch_get_current_queue();
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    
//    if (currentQueue == mainQueue) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:name object:[Rover class] userInfo:userInfo];
//    } else {
//        dispatch_sync(mainQueue, ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:name object:[Rover class] userInfo:userInfo];
//        });
//    }

    [[NSNotificationCenter defaultCenter] postNotificationName:name object:[Rover class] userInfo:userInfo];

}