//
//  RVModel.h
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSObject* RVNullSafeValueFromObject(NSObject *object);

/** RVModel is the base class for all models in the Rover SDK. It should never be instantiated directly and should be considered an abstract class.
 */
@interface RVModel : NSObject <NSCoding>

/** The unique ID used to store the model on the Rover platform. For the most part this property is only used internally and  can be safely ignored.
 
 The one potentially useful case for this property is to determine if a model has been saved. If the ID property of a model is not set, it means it has not been persisted to the Rover platform.
 */
@property (strong, nonatomic) NSString *ID;

/** Any meta data associated with the model.
 */
@property (nonatomic, strong) NSDictionary *meta;


- (BOOL)isPersisted;
- (NSString *)modelName;

@end
