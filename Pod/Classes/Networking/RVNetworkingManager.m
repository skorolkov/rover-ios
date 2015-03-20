//
//  RVNetworkingManager.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-26.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVNetworkingManager.h"

NSString *const kRVNetworkingManagerErrorDomain = @"co.roverlabs.error";
NSString *const kRVNetworkingManagerFailingURLResponseErrorKey = @"com.roverlabs.error.response";

@interface RVNetworkingManager()

@property NSURLSession *session;
@property NSURLSessionConfiguration *sessionConfig;

@end

@implementation RVNetworkingManager

#pragma mark - Class methods

+ (id)sharedManager
{
    static RVNetworkingManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:self.sessionConfig];
        
        _loggingEnabled = NO;
    }
    return self;
}

#pragma mark - Public Methods

- (void)sendRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
    [self sendRequest:request success:success failure:failure];
}

#pragma mark - Utility Methods

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    NSURL *URL = [self.baseURL URLByAppendingPathComponent:path];
    
    // Add query string
    if (parameters && [method isEqualToString:@"GET"]) {
        NSMutableArray *items = [NSMutableArray array];
        [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [items addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }];
        NSString *q = [NSString stringWithFormat:@"?%@", [items componentsJoinedByString:@"&"]];
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [URL absoluteString], q]];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = method;
    
    if (parameters && ![method isEqualToString:@"GET"]) {
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (self.authToken) {
        [request setValue:self.authToken forHTTPHeaderField:@"Authorization"];
    }
    
    return request;
}

- (void)sendRequest:(NSURLRequest *)request success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        if (HTTPResponse.statusCode == 200) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *JSON = [self parseJSONFromData:data];
                    success(JSON);
                });
            }
        } else if (HTTPResponse.statusCode == 204) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(nil);
                });
            }
        } else if (HTTPResponse.statusCode == 406) {
            if (failure) {
                NSDictionary *JSON = [self parseJSONFromData:data];
                NSString *description = [JSON objectForKey:@"error"];
                NSError *error = [self errorForResponse:HTTPResponse withDescription:description];
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        } else {
            if (failure) {
                NSError *error = [self errorForResponse:HTTPResponse withDescription:nil];
                NSDictionary *errorResponse = [self parseJSONFromData:data];
                NSString *errorMessage = [errorResponse objectForKey:@"message"];
                if (errorMessage) {
                    NSLog(@"ROVER-ERROR: %@", errorMessage);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        }
    }];
    
    [dataTask resume];
}
                  
- (NSDictionary *)parseJSONFromData:(NSData *)data {
    NSError *JSONError;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
    if (JSONError) {
        NSLog(@"%@", JSONError);
        return nil;
    } else {
        return JSON;
    }
}

- (NSError *)errorForResponse:(NSHTTPURLResponse *)response withDescription:(NSString *)description {
    NSString *statusCodeDescription = [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode];
    
    if (!description) {
        description = [NSString stringWithFormat:@"%@ (%ld)", statusCodeDescription, (long)response.statusCode];
    }
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description,
                               NSURLErrorFailingURLErrorKey:response.URL};
    
    return [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
}

@end
