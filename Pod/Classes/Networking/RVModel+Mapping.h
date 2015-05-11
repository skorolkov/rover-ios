//
//  RVModel+Mapping.h
//  Pods
//
//  Created by Ata Namvari on 2015-04-17.
//
//

#import "RVModel.h"

/** A category on RVModel to allow for custom JSON serialization.
 */
@interface RVModel (Mapping)

/** Returns a dictionary of property mappings to JSON keys.
 */
- (NSDictionary *)outboundMapping;

/** Returns a dictionary of JSON key mappings to properties.
 */
- (NSDictionary *)inboundMapping;

/** Returns a dictionary of custom class mapping.
 */
- (NSDictionary *)classMapping;

/** Returns a dictionary of value transformers for inbound mapping.
 */
- (NSDictionary *)valueTransformers;

/** Returns a dictionary of value transformers for outbound mapping.
 */
- (NSDictionary *)outboundValueTransformers;

/** Returns a class for custom mapping of a property.
 
 @param dictionary The JSON containing the property.
 */
- (Class)mappingClassForProperty:(NSString *)property dictionary:(NSDictionary *)dictionary;

@end
