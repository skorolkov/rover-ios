//
//  RVModel+Mapping.h
//  Pods
//
//  Created by Ata Namvari on 2015-04-17.
//
//

#import "RVModel.h"

@interface RVModel (Mapping)

- (NSDictionary *)outboundMapping;
- (NSDictionary *)inboundMapping;
- (NSDictionary *)classMapping;
- (NSDictionary *)valueTransformers;
- (NSDictionary *)outboundValueTransformers;

- (Class)mappingClassForProperty:(NSString *)property dictionary:(NSDictionary *)dictionary;

@end
