//
//  RVMapper.m
//  Pods
//
//  Created by Ata Namvari on 2015-04-17.
//
//

#import "RVMapper.h"
#import "RVModel+Mapping.h"
#import "RVSystemInfo.h"

@implementation RVMapper

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000ZZZZZ"];
    });
    return dateFormatter;
}

- (NSDictionary *)JSONfromObject:(RVModel *)object {
    
    NSMutableDictionary *JSON = [[NSMutableDictionary alloc] init];
    
    
    NSDictionary *outboundValueTransformers = [object outboundValueTransformers];
    
    // TODO: do nullsafe stuff
    
    NSDictionary *outboundMapping = [object outboundMapping];
    [outboundMapping enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        // Special Attributes
        if ([obj hasPrefix:@":RVSystemInfo"]) {
            NSString *selectorString = [obj substringFromIndex:14];
            NSString *systenValue = [RVSystemInfo performSelector:NSSelectorFromString(selectorString)];
            [JSON setValue:systenValue forKey:key];
            return;
        }
        
        id value = [object valueForKeyPath:obj];
        
        // outboundValueTransform
        NSValueTransformer *outboundValueTransformer = [outboundValueTransformers objectForKey:key];
        if (outboundValueTransformer) {
            value = [outboundValueTransformer transformedValue:value];
        }
        
        if (value) {
            if ([value isKindOfClass:[NSDate class]]) {
                [JSON setObject:[[RVMapper dateFormatter] stringFromDate:value] forKey:key];
            } else if ([value isKindOfClass:[RVModel class]]) {
                [JSON setObject:[self JSONfromObject:value] forKey:key];
            } else {
                [JSON setObject:value forKey:key];
            }
        }
    }];
    
    return JSON;

}

- (void)mapJSON:(NSDictionary *)JSON toObject:(RVModel *)object {
    NSDictionary *inboundMapping = [object inboundMapping];
    NSDictionary *classMapping = [object classMapping];
    NSDictionary *valueTransformers = [object valueTransformers];
    
    [inboundMapping enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id value = [JSON objectForKey:obj];
        
        if (value == nil || value == (id)[NSNull null]) {
            return;
        }
    
        Class klass = [classMapping objectForKey:obj];
        
        // TODO: do the null checks
        
        if (klass) {
            if ([value isKindOfClass:[NSArray class]]) {
                
                NSArray *valueArray = value;
                
                NSMutableArray *arrayOfNestedObjects = [NSMutableArray arrayWithCapacity:valueArray.count];
                
                [valueArray enumerateObjectsUsingBlock:^(id val, NSUInteger idx, BOOL *stop) {
                    Class cls = [object mappingClassForProperty:obj dictionary:val];
                    
                    if (!cls) {
                        cls = klass;
                    }
                    
                    RVModel *nestedObject = [cls new];
                    
                    [self mapJSON:val toObject:nestedObject];
                    
                    [arrayOfNestedObjects insertObject:nestedObject atIndex:idx];
                }];
                
                [object setValue:arrayOfNestedObjects forKey:key];
            } else {
                Class cls = [object mappingClassForProperty:obj dictionary:value];
                
                if (!cls) {
                    cls = klass;
                }
                
                RVModel *nestedObject = [cls new];
                
                [self mapJSON:value toObject:nestedObject];
                
                [object setValue:nestedObject forKey:key];
                
            }
        } else {

            NSValueTransformer *valueTransformer = [valueTransformers objectForKey:obj];
            
            if (valueTransformer) {
                [object setValue:[valueTransformer transformedValue:value] forKey:key];
            } else {
                [object setValue:value forKey:key];
            }
            
    }
        
    }];
    
}


@end
