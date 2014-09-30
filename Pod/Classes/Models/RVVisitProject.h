//
//  RVVisitProject.h
//  Rover
//
//  Created by Sean Rucker on 2014-09-12.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RVVisit.h"

@interface RVVisit ()

@property (readonly, nonatomic) BOOL isAlive;
@property (strong, nonatomic) NSUUID *UUID;
@property (strong, nonatomic) NSNumber *major;
@property (strong, nonatomic) NSString *customerID;
@property (nonatomic) NSTimeInterval keepAlive;

@property (strong, nonatomic) UIColor *primaryBackgroundColor;
@property (strong, nonatomic) UIColor *primaryFontColor;
@property (strong, nonatomic) UIColor *secondaryBackgroundColor;
@property (strong, nonatomic) UIColor *secondaryFontColor;

@end