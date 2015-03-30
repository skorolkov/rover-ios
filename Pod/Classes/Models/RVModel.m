//
//  RVModel.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-26.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModelProject.h"
#import "RVNetworkingManager.h"

extern inline NSObject* RVNullSafeValueFromObject(NSObject *object) {
    if (object) {
        return object;
    }
    return [NSNull null];
}

@implementation RVModel

#pragma mark - Paths

- (NSString *)modelName {
    // TODO: Throw an exception if this ever gets called. Should be overridden by each sub class.
    return @"";
}

- (NSString *)createPath {
    return [NSString stringWithFormat:@"%@s", [self modelName]];
}

- (NSString *)updatePath {
    return [NSString stringWithFormat:@"%@s/%@", [self modelName], self.ID];
}

- (BOOL)isPersisted {
    return self.ID != nil;
}

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000ZZZZZ"];
    });
    return dateFormatter;
}

#pragma mark - Serialization

- (id)initWithJSON:(NSDictionary *)JSON {
    self = [super init];
    if (self) {
        [self updateWithJSON:JSON];
    }
    return self;
}

- (void)updateWithJSON:(NSDictionary *)JSON {
    id ID = [JSON objectForKey:@"id"];
    if (ID != (id)[NSNull null]) {
        if ([ID isKindOfClass:[NSString class]]) {
            self.ID = ID;
        } else {
            // Number
            self.ID = [ID stringValue];
        }
    }
    
    
    // meta
    NSDictionary *meta = [JSON objectForKey:@"meta"];
    if (meta && meta != (id)[NSNull null]) {
        _meta = meta;
    }
}

- (NSDictionary *)toJSON {
    if (self.ID) {
        return @{ @"id": self.ID };
    } else {
        return @{ @"id": [NSNull null] };
    }
}

#pragma mark - Networking

- (void)save:(void (^)(void))success failure:(void (^)(NSString *))failure {
    NSString *method;
    NSString *path;
    
    if ([self isPersisted]) {
        method = @"PUT";
        path = [self updatePath];
    } else {
        method = @"POST";
        path = [self createPath];
    }
    
    NSString *modelName = [self modelName];
    NSDictionary *parameters = [self toJSON];
    
    [[RVNetworkingManager sharedManager] sendRequestWithMethod:method path:path parameters:parameters success:^(NSDictionary *data) {
        NSDictionary *JSON = [data objectForKey:modelName];
        
        if (JSON) {
            [self updateWithJSON:JSON];
        }
        
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        NSString *reason = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        NSLog(@"Save failed: %@", reason);
        
        if (failure) {
            failure(reason);
        }
    }];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.ID forKey:@"ID"];
    [encoder encodeObject:self.meta forKey:@"meta"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [self init])) {
        //decode properties, other class vars
        self.ID = [decoder decodeObjectForKey:@"ID"];
        self.meta = [decoder decodeObjectForKey:@"meta"];
    }
    return self;
}

@end
