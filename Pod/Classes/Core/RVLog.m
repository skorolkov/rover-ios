//
//  RVLog.m
//  Rover
//
//  Created by Sean Rucker on 2014-07-16.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVLog.h"
#import "RVVisit.h"

NSString *const kRoverDidExitLocationNotification = @"RoverDidExitLocationNotification";
NSString *const kRoverAlreadyVisitingNotification = @"RoverAlreadyVisitingNotification";

NSString *const kRoverWillPostVisitNotification = @"RoverWillPostVisitNotification";
NSString *const kRoverDidPostVisitNotification = @"RoverDidPostVisitNotification";
NSString *const kRoverPostVisitFailedNotification = @"RoverPostVisitFailedNotification";

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

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:[RVVisit class] userInfo:userInfo];
    });

}