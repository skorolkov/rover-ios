//
//  RVCustomer.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-27.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCustomerProject.h"
#import "RVNetworkingManager.h"

@interface RVCustomer ()

@property (strong, nonatomic) NSMutableDictionary *attributes;

@end

@implementation RVCustomer

#pragma mark - Overridden Properties

- (NSString *)modelName {
    return @"customer";
}

- (BOOL)isPersisted {
    return YES;
}

- (NSString *)updatePath {
    return [NSString stringWithFormat:@"%@s/%@", [self modelName], self.customerID];
}

#pragma mark - Overridden Methods 

- (void)updateWithJSON:(NSDictionary *)JSON {    
    // customerID
    NSString *customerID = [JSON objectForKey:@"customer_id"];
    if (customerID != (id)[NSNull null] && [customerID length] > 0) {
        self.customerID = customerID;
    }
    
    // name
    NSString *name = [JSON objectForKey:@"name"];
    if (name != (id)[NSNull null] && [name length] > 0) {
        self.name = name;
    }
    
    // email
    NSString *email = [JSON objectForKey:@"email"];
    if (email != (id)[NSNull null] && [email length] > 0) {
        self.email = email;
    }
    
    // attributes
    NSDictionary *attributes = [JSON objectForKey:@"attributes"];
    if (attributes != (id)[NSNull null]) {
        self.attributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    }
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *JSON = [NSMutableDictionary dictionaryWithCapacity:3];
    
    // customerID
    if (self.customerID) {
        [JSON setObject:self.customerID forKey:@"customer_id"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"customer_id"];
    }
    
    // name
    if (self.name) {
        [JSON setObject:self.name forKey:@"name"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"name"];
    }
    
    // email
    if (self.email) {
        [JSON setObject:self.email forKey:@"email"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"email"];
    }
    
    // attributes
    [JSON setObject:self.attributes forKey:@"attributes"];
    
    return JSON;
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        self.attributes = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    return self;
}

#pragma mark - Attribute Methods

- (void)setAttribute:(NSString *)attribute value:(id)value {
    attribute = [self parameterize:attribute];
    [self.attributes setObject:value forKey:attribute];
}

- (id)getAttribute:(NSString *)attribute {
    attribute = [self parameterize:attribute];
    id obj = [self.attributes objectForKey:attribute];
    return obj == (id)[NSNull null] ? nil : obj;
}

- (NSString *)parameterize:(NSString *)string {
    string = [string lowercaseString];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:NSRegularExpressionCaseInsensitive error:nil];
    string = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@"_"];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-z0-9_]+" options:NSRegularExpressionCaseInsensitive error:nil];
    string = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
    
    return string;
}

@end
