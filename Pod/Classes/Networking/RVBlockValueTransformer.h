//
//  RVBlockValueTransformer.h
//  Pods
//
//  Created by Ata Namvari on 2015-04-17.
//
//

#import <Foundation/Foundation.h>

typedef id (^RVTransformationBlock)(id inputValue);

@interface RVBlockValueTransformer : NSObject

+ (instancetype)valueTransformerWithBlock:(RVTransformationBlock)tranformationBlock;
- (id)transformedValue:(id)value;


// Convenience Methods

+ (instancetype)UIEdgeInsetValueTransformer;
+ (instancetype)UIColorValueTransformer;
+ (instancetype)backgroundContentModeValueTransformer;
+ (instancetype)NSURLValueTransformer;

@end
