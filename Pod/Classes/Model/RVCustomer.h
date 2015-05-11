//
//  RVCustomer.h
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVModel.h"

/** The RVCustomer class represents the current user of your app. You shouldn't create an instance of the RVCustomer class directly. Instead, you access the current customer object from the `cachedCustomer` class method. After setting the name, email or customer attributes on a customer, the customer will automatically be persisted to the Rover Platform the next time the customer visits a location.
 */
@interface RVCustomer : RVModel <NSCoding>

@property (strong, nonatomic) NSString *customerID;

/** The name of the current customer. After setting this property you should call the save method to persist your changes to the Rover Platform.
 */
@property (strong, nonatomic) NSString *name;

/** The email address of the current customer. After setting this property you should call the save method to persist your changes to the Rover Platform.
 */
@property (strong, nonatomic) NSString *email;

/** Along with the name and email address of your customer you can set additional properties that are you unique to your application.
 @param attribute A unique string to identify the attribute. Only lowercase letters, numbers and the underscore (_) character should be used. E.g. @"annual_salary"
 @param to The value of the attribute. Strings, numbers and boolean values are all valid types of attributes. E.g. @10000, @"male" and YES are all valid options.
 */
- (void)set:(NSString *)attribute to:(id)value;

/** Use this method to access any attributes that have been set on the customer.
 @param attribute The unique string used to identify the attribute.
 @see setAttribute:value:
 */
- (id)get:(NSString *)attribute;

+ (RVCustomer *)cachedCustomer;

@property (readonly, nonatomic) BOOL dirty;

@end