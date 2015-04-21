//
//  RVVisitManager.h
//  Rover
//
//  Created by Sean Rucker on 2014-07-29.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RVVisit;
@class RVLocation;
@class RVTouchpoint;
@protocol RVVisitManagerDelegate;

@interface RVVisitManager : NSObject

@property (nonatomic, weak) NSObject <RVVisitManagerDelegate> *delegate;
@property (strong, nonatomic, readonly) RVRegionManager *regionManager;
@property (strong, nonatomic, readonly) RVVisit *latestVisit;

@end

@protocol RVVisitManagerDelegate <NSObject>

@optional
// NOT MAIN THREAD
- (BOOL)visitManager:(RVVisitManager *)manager shouldCreateVisit:(RVVisit *)visit;

- (void)visitManager:(RVVisitManager *)manager didEnterLocation:(RVLocation *)location visit:(RVVisit *)visit;
- (void)visitManager:(RVVisitManager *)manager didPotentiallyExitLocation:(RVLocation *)location visit:(RVVisit *)visit;
- (void)visitManager:(RVVisitManager *)manager didExpireVisit:(RVVisit *)visit;

- (void)visitManager:(RVVisitManager *)manager didEnterTouchpoint:(RVTouchpoint *)touchpoint visit:(RVVisit *)visit;
- (void)visitManager:(RVVisitManager *)manager didExitTouchpoint:(RVTouchpoint *)touchpoint visit:(RVVisit *)visit;

@end
