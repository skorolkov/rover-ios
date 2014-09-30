//
//  RVCustomer.h
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVModel.h"

/** The RVCustomer class represents the current user of your app. You shouldn't create an instance of the RVCustomer class directly. Instead, you access the current customer object from the getCustomer: method on the Rover class.
 */
@interface RVCustomer : RVModel

/** You should not set this property directly. Instead, use the setCustomerID: method on the Rover class. You do not need to save the customer object after setting this property.
 */
@property (readonly, strong, nonatomic) NSString *customerID;

/** The name of the current customer. After setting this property you should call the save method to persist your changes to the Rover Platform.
 */
@property (strong, nonatomic) NSString *name;

/** The email address of the current customer. After setting this property you should call the save method to persist your changes to the Rover Platform.
 */
@property (strong, nonatomic) NSString *email;

/** Along with the name and email address of your customer you can set additional properties that are you unique to your application. After setting attributes on a customer you should call the save:failure: method to persiste your changes to the Rover Platform.
 @param attribute A unique string to identify the attribute. Only lowercase letters, numbers and the underscore (_) character should be used. E.g. @"annual_salary"
 @param value The value of the attribute. Strings, numbers and boolean values are all valid types of attributes. E.g. @10000, @"male" and YES are all valid options.
 */
- (void)setAttribute:(NSString *)attribute value:(id)value;

/** Use this method to access any attributes that have been set on the customer.
 @param attribute The unique string used to identify the attribute.
 @see setAttribute:value:
 */
- (id)getAttribute:(NSString *)attribute;

@end