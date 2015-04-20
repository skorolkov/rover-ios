//
//  RVLog.h
//  Rover
//
//  Created by Sean Rucker on 2014-07-16.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kRoverDidExitLocationNotification;
extern NSString *const kRoverAlreadyVisitingNotification;

extern NSString *const kRoverWillPostVisitNotification;
extern NSString *const kRoverDidPostVisitNotification;
extern NSString *const kRoverPostVisitFailedNotification;

extern NSString *const kRoverWillUpdateExitTimeNotification;
extern NSString *const kRoverDidUpdateExitTimeNotification;
extern NSString *const kRoverUpdateExitTimeFailedNotification;

extern NSString *const kRoverDidEnterRegionNotification;
extern NSString *const kRoverDidExitRegionNotification;
extern NSString *const kRoverDidDetermineStateNotification;
extern NSString *const kRoverDidRangeBeaconsNotification;

void RVLog(NSString *name, NSDictionary *data);