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
    
    // name
    NSString *name = [JSON objectForKey:@"name"];
    if (name != (id)[NSNull null] && [name length] > 0) {
        self.name = name;
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
    
    // organizationName
    NSString *organizationName = [JSON objectForKey:@"organization_name"];
    if (organizationName != (id)[NSNull null] && [organizationName length] > 0) {
        self.organizationName = organizationName;
    }

    // organizationId
    NSString *organizationId = [JSON objectForKey:@"organization_id"];
    if (organizationId != (id)[NSNull null] && [organizationId length] > 0) {
        self.organizationId = organizationId;
    }
    
    // logoURL
    NSString *logoURLString = [JSON objectForKey:@"logo_url"];
    if (logoURLString != (id)[NSNull null] && [logoURLString length] > 0) {
        self.logoURL = [NSURL URLWithString:logoURLString];
    }
}


- (CLLocation *)CLLocation
{
    return [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.address forKey:@"address"];
    [encoder encodeObject:self.city forKey:@"city"];
    [encoder encodeObject:self.province forKey:@"province"];
    [encoder encodeObject:self.postalCode forKey:@"postalCode"];
    [encoder encodeObject:self.latitude forKey:@"latitude"];
    [encoder encodeObject:self.longitude forKey:@"longitude"];
    [encoder encodeObject:self.radius forKey:@"radius"];
    [encoder encodeObject:self.organizationName forKey:@"organizationName"];
    [encoder encodeObject:self.organizationId forKey:@"organizationId"];
    [encoder encodeObject:self.logoURL forKey:@"logoURL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.name = [decoder decodeObjectForKey:@"name"];
        self.address = [decoder decodeObjectForKey:@"address"];
        self.province = [decoder decodeObjectForKey:@"province"];
        self.postalCode = [decoder decodeObjectForKey:@"postalCode"];
        self.latitude = [decoder decodeObjectForKey:@"latitude"];
        self.longitude = [decoder decodeObjectForKey:@"longitude"];
        self.radius = [decoder decodeObjectForKey:@"radius"];
        self.organizationName = [decoder decodeObjectForKey:@"organizationName"];
        self.organizationId = [decoder decodeObjectForKey:@"organizationId"];
        self.logoURL = [decoder decodeObjectForKey:@"logoURL"];
    }
    return self;
}


@end
