//
//  RVBlockValueTransformer.h
//  Pods
//
//  Created by Ata Namvari on 2015-04-17.
//
//

#import <Foundation/Foundation.h>

typedef id (^RVTransformationBlock)(id inputValue);

/** A block based value transformer.
 */
@interface RVBlockValueTransformer : NSObject

+ (instancetype)valueTransformerWithBlock:(RVTransformationBlock)tranformationBlock;
- (id)transformedValue:(id)value;

/** Value transformer to transform an NSArray of 4 numbers to a UIEdgeInset.
 */
+ (instancetype)UIEdgeInsetValueTransformer;

/** Value transformer to transform an NSArray of 4 numbers to a UIColor.
 */
+ (instancetype)UIColorValueTransformer;

/** Value transformer to transform an NSString to an RVBackgroundContentMode.
 */
+ (instancetype)backgroundContentModeValueTransformer;

/** Value transformer to transform an NSString to an NSURL.
 */
+ (instancetype)NSURLValueTransformer;

@end
