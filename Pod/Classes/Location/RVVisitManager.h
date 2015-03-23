//
//  RVVisitManager.h
//  Rover
//
//  Created by Sean Rucker on 2014-07-29.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kRVVisitManagerDidEnterLocationNotification;
extern NSString *const kRVVisitManagerDidExitLocationNotification;
extern NSString *const kRVVisitManagerDidEnterTouchpointNotification;
extern NSString *const kRVVisitManagerDidExitTouchpointNotification;

@class RVVisit;

@interface RVVisitManager : NSObject

+ (id)sharedManager;

@property (strong, nonatomic, readonly) RVVisit *latestVisit;

@end