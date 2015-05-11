//
//  RVCustomer.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-27.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCustomer.h"

NSString *const kRVCustomerKey = @"RVCustomerKey";

@interface RVCustomer ()

@property (strong, nonatomic) NSMutableDictionary *attributes;

@end

@implementation RVCustomer {
    NSString *_customerID;
}

+ (RVCustomer *)cachedCustomer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:kRVCustomerKey];
    
    RVCustomer *customer;
    if (encodedObject) {
        customer = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    } else {
        customer = [RVCustomer new];
    }
    
    return customer;
}

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

#pragma mark - Properties

- (NSString *)customerID {
    if ([_customerID length]) {
        return _customerID;
    }

    CFUUIDRef identifier = CFUUIDCreate(NULL);
    _customerID = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, identifier));
    [self cache];
    
    return _customerID;
}

- (void)setCustomerID:(NSString *)customerID {
    if ([_customerID isEqualToString:customerID]) {
        return;
    }
    _customerID = customerID;
    self.dirty = YES;
}

- (void)setName:(NSString *)name {
    if ([_name isEqualToString:name]) {
        return;
    }
    _name = name;
    self.dirty = YES;
}

- (void)setEmail:(NSString *)email {
    if ([_email isEqualToString:email]) {
        return;
    }
    _email = email;
    self.dirty = YES;
}

- (void)setDirty:(BOOL)dirty {
    _dirty = dirty;
    [self cache];
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _dirty = NO;
        self.attributes = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        _customerID = [decoder decodeObjectForKey:@"customerID"];
        _name = [decoder decodeObjectForKey:@"name"];
        _email = [decoder decodeObjectForKey:@"email"];
        _dirty = [decoder decodeBoolForKey:@"dirty"];
        
        NSMutableDictionary *attributes = [decoder decodeObjectForKey:@"attributes"];
        if (attributes != nil) {
            self.attributes = attributes;
        }
    }
        
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.customerID forKey:@"customerID"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeBool:self.dirty forKey:@"dirty"];
    [encoder encodeObject:self.attributes forKey:@"attributes"];
}

#pragma mark - Cache

- (void)cache {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:kRVCustomerKey];
    [defaults synchronize];
}

#pragma mark - Attribute Methods

- (void)set:(NSString *)attribute to:(id)value {
    id existingValue = [self get:attribute];
    if ([existingValue isEqual:value]) {
        return;
    }
    attribute = [self parameterize:attribute];
    [self.attributes setObject:value forKey:attribute];
    self.dirty = YES;
}

- (id)get:(NSString *)attribute {
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
