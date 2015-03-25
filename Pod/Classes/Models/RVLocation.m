//
//  RVLocation.m
//  Rover
//
//  Created by Ata Namvari on 2014-11-24.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVLocation.h"
#import "RVModelProject.h"

@implementation RVLocation

#pragma mark - Overridden Properties

- (NSString *)modelName {
    return @"location";
}

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    
    // title
    NSString *title = [JSON objectForKey:@"title"];
    if (title != (id)[NSNull null] && [title length] > 0) {
        self.title = title;
    }
    
    // address
    NSString *address = [JSON objectForKey:@"address"];
    if (address != (id)[NSNull null] && [address length] > 0) {
        self.address = address;
    }
    
    // city
    NSString *city = [JSON objectForKey:@"city"];
    if (city != (id)[NSNull null] && [city length] > 0) {
        self.city = city;
    }
    
    // province
    NSString *province = [JSON objectForKey:@"province"];
    if (province != (id)[NSNull null] && [province length] > 0) {
        self.province = province;
    }
    
    // postalCode
    NSString *postalCode = [JSON objectForKey:@"postal_code"];
    if (postalCode != (id)[NSNull null] && [postalCode length] > 0) {
        self.postalCode = postalCode;
    }
    
    // latitude
    NSNumber *latitude = [JSON objectForKey:@"latitude"];
    if (latitude != (id)[NSNull null]) {
        self.latitude = latitude;
    }

    // longitude
    NSNumber *longitude = [JSON objectForKey:@"longitude"];
    if (longitude != (id)[NSNull null]) {
        self.longitude = longitude;
    }

    // radius
    NSNumber *radius = [JSON objectForKey:@"radius"];
    if (radius != (id)[NSNull null]) {
        self.radius = radius;
    }
}


- (CLLocation *)CLLocation
{
    return [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
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
