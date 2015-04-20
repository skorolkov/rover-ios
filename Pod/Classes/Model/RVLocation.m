//
//  RVLocation.m
//  Rover
//
//  Created by Ata Namvari on 2014-11-24.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVLocation.h"

@implementation RVLocation

#pragma mark - Overridden Properties

- (NSString *)modelName {
    return @"location";
}

- (CLLocation *)CLLocation
{
    return [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc

    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.title forKey:@"title"];

    [encoder encodeObject:self.address forKey:@"address"];
    [encoder encodeObject:self.city forKey:@"city"];
    [encoder encodeObject:self.province forKey:@"province"];
    [encoder encodeObject:self.postalCode forKey:@"postalCode"];
    [encoder encodeObject:self.latitude forKey:@"latitude"];
    [encoder encodeObject:self.longitude forKey:@"longitude"];
    [encoder encodeObject:self.radius forKey:@"radius"];
}


- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [self init])) {
        self.title = [decoder decodeObjectForKey:@"title"];
        self.address = [decoder decodeObjectForKey:@"address"];
        self.city = [decoder decodeObjectForKey:@"city"];

        self.province = [decoder decodeObjectForKey:@"province"];
        self.postalCode = [decoder decodeObjectForKey:@"postalCode"];
        self.latitude = [decoder decodeObjectForKey:@"latitude"];
        self.longitude = [decoder decodeObjectForKey:@"longitude"];
        self.radius = [decoder decodeObjectForKey:@"radius"];


    }
    return self;
}


@end
