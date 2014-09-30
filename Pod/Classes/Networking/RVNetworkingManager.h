//
//  RVNetworkingManager.h
//  Rover
//
//  Created by Sean Rucker on 2014-06-26.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVModel.h"

@interface RVNetworkingManager : NSObject

+ (id)sharedManager;

@property (strong, nonatomic) NSString *authToken;
@property (strong, nonatomic) NSURL *baseURL;
@property (nonatomic) BOOL loggingEnabled;

- (void)sendRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(NSDictionary *data))success failure:(void (^)(NSError *error))failure;

@end
