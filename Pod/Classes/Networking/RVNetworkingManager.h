//
//  RVNetworkingManager.h
//  Rover
//
//  Created by Sean Rucker on 2014-06-26.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVModel.h"

@class RVVisit;

@interface RVNetworkingManager : NSObject

/** The singleton instance of the Rover networking manager.
 */
+ (id)sharedManager;

/** The Application ID found on the settings page of the [Rover Admin Console](http://app.roverlabs.co/).
 */
@property (strong, nonatomic) NSString *applicationID;

/** Don't change this.
 */
@property (strong, nonatomic) NSURL *serverURL;

/** Sends an HTTP request to the Rover API server. This method is asynchronous.
 */
- (void)sendRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(NSDictionary *data))success failure:(void (^)(NSError *error))failure;

/** Posts a visit object to the Rover API server. This is a synchronous method and should always be called from a background thread.
 */
- (void)postVisit:(RVVisit *)visit;

/** Posts an event to the Rover API server. The event param must be of format ":object.:action".
 */
- (void)trackEvent:(NSString *)event params:(NSDictionary *)params visit:(RVVisit *)visit;

@end
