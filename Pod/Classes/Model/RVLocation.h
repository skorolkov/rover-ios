//
//  RVLocation.h
//  Rover
//
//  Created by Ata Namvari on 2014-11-24.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModel.h"
#import <CoreLocation/CoreLocation.h>

@interface RVLocation : RVModel

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *radius;

- (CLLocation *)CLLocation;

@end
