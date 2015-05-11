//
//  RVBlockValueTransformer.m
//  Pods
//
//  Created by Ata Namvari on 2015-04-17.
//
//

#import "RVBlockValueTransformer.h"

#import "RVBackgroundImage.h"

@interface RVBlockValueTransformer ()

@property (nonatomic, copy) RVTransformationBlock tranfomationBlock;

@end

@implementation RVBlockValueTransformer

#pragma mark - Class Methods

+ (instancetype)valueTransformerWithBlock:(RVTransformationBlock)tranformationBlock {
    RVBlockValueTransformer *blockValueTransformer = [[RVBlockValueTransformer alloc] init];
    blockValueTransformer.tranfomationBlock = tranformationBlock;
    
    return blockValueTransformer;
}

+ (instancetype)UIEdgeInsetValueTransformer {
    return [self valueTransformerWithBlock:^id(NSArray *inputValue) {
        return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake([inputValue[0] floatValue], [inputValue[3] floatValue], [inputValue[2] floatValue], [inputValue[1] floatValue])];
    }];
}

+ (instancetype)UIColorValueTransformer {
    return [self valueTransformerWithBlock:^id(id inputValue) {
        return [UIColor colorWithRed:[inputValue[0] floatValue]/255.f green:[inputValue[1] floatValue]/255.f blue:[inputValue[2] floatValue]/255.f alpha:[inputValue[3] floatValue]];
    }];
}

+ (instancetype)backgroundContentModeValueTransformer {
    return [self valueTransformerWithBlock:^id(id inputValue) {
        return [NSNumber numberWithInteger:RVBackgroundContentModeFromString(inputValue)];
    }];
}

+ (instancetype)NSURLValueTransformer {
    return [self valueTransformerWithBlock:^id(id inputValue) {
        return [NSURL URLWithString:inputValue];
    }];
}

- (id)transformedValue:(id)value {
    return self.tranfomationBlock(value);
}

@end
