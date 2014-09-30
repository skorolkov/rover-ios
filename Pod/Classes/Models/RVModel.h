//
//  RVModel.h
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** RVModel is the base class for all models in the Rover SDK. It should never be instantiated directly and should be considered an abstract class.
 */
@interface RVModel : NSObject

/** The unique ID used to store the model on the Rover platform. For the most part this property is only used internally and  can be safely ignored.
 
 The one potentially useful case for this property is to determine if a model has been saved. If the ID property of a model is not set, it means it has not been persisted to the Rover platform.
 */
@property (readonly, strong, nonatomic) NSNumber *ID;

/** Any subclass of the RVModel class can be persisted to the Rover platform using the save method. For example, you can use this method on the current customer object to save attributes of your customer. After calling the save method your changes will be reflected in the [Rover Marketing Console](http://app.roverlabs.co/).
 @param success After successfully persisting the model to the Rover platform this block will be invoked.
 @param failure If anything goes wrong while persisting the model to the server this block will be invoked and the reason for the failure will be passed as to the block as a NSString.
 */
- (void)save:(void (^)(void))success failure:(void (^)(NSString *reason))failure;

@end
