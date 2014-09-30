//
//  RVModel.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-26.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModelProject.h"
#import "RVNetworkingManager.h"

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
    NSNumber *ID = [JSON objectForKey:@"id"];
    if (ID != (id)[NSNull null]) {
        self.ID = ID;
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
    NSDictionary *parameters = @{ modelName: [self toJSON] };
    
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

@end
