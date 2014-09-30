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

@class RVVisit;

@interface RVVisitManager : NSObject

+ (id)sharedManager;

@end