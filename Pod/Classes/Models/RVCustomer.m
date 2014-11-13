//
//  RVCustomer.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-27.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCustomerProject.h"
#import "RVNetworkingManager.h"
#import "RVLog.h"

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

- (void)setHasSeenTutorial:(BOOL)hasSeenTutorial
{
    _hasSeenTutorial = hasSeenTutorial;
    [self cache];
}

- (void)setDirty:(BOOL)dirty {
    _dirty = dirty;
    [self cache];
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
    NSMutableDictionary *JSON = [NSMutableDictionary dictionaryWithCapacity:4];
    
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
    if (self.attributes) {
        [JSON setObject:self.attributes forKey:@"attributes"];
    } else {
        [JSON setObject:@{} forKey:@"attributes"];
    }
    
    return JSON;
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
        _hasSeenTutorial = [decoder decodeBoolForKey:@"hasSeenTutorial"];
        
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
    [encoder encodeBool:self.hasSeenTutorial forKey:@"hasSeenTutorial"];
}

#pragma mark - Overridden Methods

- (void)save:(void (^)(void))success failure:(void (^)(NSString *))failure {
    RVLog(kRoverWillUpdateCustomerNotification, nil);
    
    [super save:^{
        RVLog(kRoverDidUpdateCustomerNotification, nil);
        
        if (self.dirty) {
            self.dirty = NO;
        }
        success();
    } failure:^(NSString *reason) {
        RVLog(kRoverUpdateCustomerFailedNotification, nil);
        failure(reason);
    }];
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
