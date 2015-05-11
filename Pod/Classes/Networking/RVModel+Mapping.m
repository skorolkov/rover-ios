//
//  RVModel+Mapping.m
//  Pods
//
//  Created by Ata Namvari on 2015-04-17.
//
//

#import "RVModel+Mapping.h"

#import "RVBlockValueTransformer.h"

#import "RVVisit.h"
#import "RVCustomer.h"
#import "RVLocation.h"
#import "RVTouchpoint.h"
#import "RVCard.h"
#import "RVViewDefinition.h"
#import "RVOrganization.h"

#import "RVImageBlock.h"
#import "RVTextBlock.h"
#import "RVBarcodeBlock.h"
#import "RVButtonBlock.h"
#import "RVHeaderBlock.h"

@implementation RVModel (Mapping)

- (NSDictionary *)outboundMapping { return @{@"id": @"ID"}; }

- (NSDictionary *)inboundMapping { return @{@"ID": @"id"}; }

- (NSDictionary *)classMapping { return @{}; }

- (NSDictionary *)valueTransformers { return @{}; }

- (NSDictionary *)outboundValueTransformers { return @{}; }

- (Class)mappingClassForProperty:(NSString *)property dictionary:(NSDictionary *)dictionary { return nil; }

@end

#pragma mark - RVVisit

@implementation RVVisit (Mapping)

- (NSDictionary *)outboundMapping {

    return @{@"id": @"ID",
             @"uuid": @"UUID.UUIDString",
             @"majorNumber": @"majorNumber",
             @"customer": @"customer",
             @"timestamp": @"timestamp",
             @"simulate": @"simulate",
             
             @"device": @":RVSystemInfo.platform",
             @"operatingSystem": @":RVSystemInfo.systemName",
             @"osVersion": @":RVSystemInfo.systemVersion",
             @"sdkVersion":@":RVSystemInfo.roverVersion"};
}

- (NSDictionary *)inboundMapping {
    return @{@"ID": @"id",
             @"keepAlive": @"keepAlive",
             @"location": @"location",
             @"touchpoints": @"touchpoints",
             @"organization": @"organization"};
}

- (NSDictionary *)classMapping {
    return @{@"location": [RVLocation class],
             @"touchpoints": [RVTouchpoint class],
             @"organization": [RVOrganization class]};
}

- (NSDictionary *)valueTransformers {
    return @{@"keepAlive": [RVBlockValueTransformer valueTransformerWithBlock:^id(id inputValue) {
                                NSInteger integer = [inputValue integerValue];
                                return [NSNumber numberWithInteger:integer * 60];
                            }]};
}

- (NSDictionary *)outboundValueTransformers {
    // This force of __NSCFBoolean is needed for 32-bit devices (iPhone 4S)
    return @{@"simulate": [RVBlockValueTransformer valueTransformerWithBlock:^id(id inputValue) {
        return [NSNumber numberWithBool:[inputValue boolValue]];
    }]};
}

@end

#pragma mark - RVCustomer

@implementation RVCustomer (Mapping)

- (NSDictionary *)outboundMapping {
    return @{@"customerId": @"customerID",
             @"name": @"name",
             @"email": @"email",
             @"traits": @"attributes"};
}

@end

#pragma mark - RVLocation

@implementation RVLocation (Mapping)

- (NSDictionary *)inboundMapping {
    return @{@"ID": @"id",
             @"meta": @"meta",
             @"title": @"title",
             @"address": @"address",
             @"city": @"city",
             @"province": @"province",
             @"postalCode": @"postalCode",
             @"latitude": @"latitude",
             @"longitude": @"longitude",
             @"radius": @"radius"};
}

@end

#pragma mark - RVOrganization

@implementation RVOrganization (Mapping)

- (NSDictionary *)inboundMapping {
    return @{@"ID": @"id",
             @"meta": @"meta",
             @"title": @"title"};
}

@end

#pragma mark - RVTouchpoint

@implementation RVTouchpoint (Mapping)

- (NSDictionary *)inboundMapping {
    return @{@"ID": @"id",
             @"meta": @"meta",
             @"trigger": @"trigger",
             @"minorNumber": @"minorNumber",
             @"title": @"title",
             @"notification": @"notification",
             @"cards": @"cards"};
}

- (NSDictionary *)valueTransformers {
    return @{@"trigger": [RVBlockValueTransformer valueTransformerWithBlock:^id(id inputValue) {
                                if ([inputValue isEqualToString:@"beacon"]) {
                                    return [NSNumber numberWithInteger:RVTouchpointTriggerMinorNumber];
                                } else {
                                    return [NSNumber numberWithInteger:RVTouchpointTriggerVisit];
                                }
                            }]};
}

- (NSDictionary *)classMapping {
    return @{@"cards": [RVCard class]};
}

@end

#pragma mark - RVCard

@implementation RVCard (Mapping)

- (NSDictionary *)inboundMapping {
    return @{@"ID": @"id",
             @"meta": @"meta",
             @"title": @"title",
             @"viewDefinitions": @"views"};
}

- (NSDictionary *)classMapping {
    return @{@"views": [RVViewDefinition class]};
}

@end

#pragma mark - RVViewDefinition

@implementation RVViewDefinition (Mapping)

- (NSDictionary *)inboundMapping {
    return @{@"ID": @"id",
             @"type": @"type",
             @"cornerRadius": @"borderRadius",
             @"margins": @"margin",
             @"blocks": @"blocks" /* TODO: this is bad */,
             @"backgroundColor": @"backgroundColor",
             @"backgroundImageURL": @"backgroundImageUrl",
             @"backgroundContentMode": @"backgroundContentMode"};
}

- (NSDictionary *)classMapping {
    return @{@"blocks": [RVBlock class]};
}

- (Class)mappingClassForProperty:(NSString *)property dictionary:(NSDictionary *)dictionary {
    if ([property isEqualToString:@"blocks"]) {
        NSString *type = [dictionary objectForKey:@"type"];
        if ([type isEqualToString:@"imageBlock"]) {
            return [RVImageBlock class];
        } else if ([type isEqualToString:@"textBlock"]) {
            return [RVTextBlock class];
        } else if ([type isEqualToString:@"barcodeBlock"]) {
            return [RVBarcodeBlock class];
        } else if ([type isEqualToString:@"buttonBlock"]) {
            return [RVButtonBlock class];
        } else if ([type isEqualToString:@"headerBlock"]) {
            return [RVHeaderBlock class];
        }
    }
    
    return nil;
}

- (NSDictionary *)valueTransformers {
    return @{@"type": [RVBlockValueTransformer valueTransformerWithBlock:^id(id inputValue) {
                if ([inputValue isEqualToString:@"detailView"]) {
                    return [NSNumber numberWithInteger:RVViewDefinitionTypeDetailView];
                } else {
                    return [NSNumber numberWithInteger:RVViewDefinitionTypeListView];
                }
             }],
             @"margin": [RVBlockValueTransformer UIEdgeInsetValueTransformer],
             @"backgroundContentMode": [RVBlockValueTransformer backgroundContentModeValueTransformer],
             @"backgroundImageUrl": [RVBlockValueTransformer NSURLValueTransformer],
             @"backgroundColor": [RVBlockValueTransformer UIColorValueTransformer]};
}

@end

#pragma mark - RVBlock

@implementation RVBlock (Mapping)

- (NSDictionary *)inboundMapping {
    return @{@"ID": @"id",
             @"backgroundColor": @"backgroundColor",
             @"borderColor": @"borderColor",
             @"padding": @"padding",
             @"borderWidth": @"borderWidth",
             @"url": @"url",
             @"backgroundImageURL": @"backgroundImageUrl",
             @"backgroundContentMode": @"backgroundContentMode"};
}

- (NSDictionary *)valueTransformers {
    return @{@"backgroundColor": [RVBlockValueTransformer UIColorValueTransformer],
             @"borderColor": [RVBlockValueTransformer UIColorValueTransformer],
             @"padding": [RVBlockValueTransformer UIEdgeInsetValueTransformer],
             @"borderWidth": [RVBlockValueTransformer UIEdgeInsetValueTransformer],
             @"backgroundImageUrl": [RVBlockValueTransformer NSURLValueTransformer],
             @"backgroundContentMode": [RVBlockValueTransformer backgroundContentModeValueTransformer],
             @"url": [RVBlockValueTransformer NSURLValueTransformer]};
}

@end

#pragma mark - RVImageBlock

@implementation RVImageBlock (Mapping)

- (NSDictionary *)inboundMapping {
    NSMutableDictionary *inboundMapping = [[super inboundMapping] mutableCopy];
    [inboundMapping addEntriesFromDictionary:@{ @"imagePath": @"imageUrl",
                                                @"aspectRatio": @"imageAspectRatio",
                                                @"yOffset": @"imageOffsetRatio",
                                                @"originalImageWidth": @"imageWidth",
                                                @"originalImageHeight": @"imageHeight"}];
             
    return [NSDictionary dictionaryWithDictionary:inboundMapping];
}

@end

#pragma mark - RVHeaderBlock

@implementation RVHeaderBlock (Mapping)

- (NSDictionary *)inboundMapping {
    NSMutableDictionary *inboundMapping = [[super inboundMapping] mutableCopy];
    [inboundMapping addEntriesFromDictionary:@{@"titleString": @"headerTitle",
                                               @"iconPath": @"iconPath"}];
    
    return [NSDictionary dictionaryWithDictionary:inboundMapping];
}

@end

#pragma mark - RVTextBlock

@implementation RVTextBlock (Mapping)

- (NSDictionary *)inboundMapping {
    NSMutableDictionary *inboundMapping = [[super inboundMapping] mutableCopy];
    [inboundMapping addEntriesFromDictionary:@{@"htmlString": @"textContent"}];
    
    return [NSDictionary dictionaryWithDictionary:inboundMapping];
}

@end

#pragma mark - RVButtonBlock

@implementation RVButtonBlock (Mapping)

- (NSDictionary *)inboundMapping {
    NSMutableDictionary *inboundMapping = [[super inboundMapping] mutableCopy];
    [inboundMapping addEntriesFromDictionary:@{@"labelString": @"buttonLabel",
                                               @"iconPath": @"iconPath"}];
    
    return [NSDictionary dictionaryWithDictionary:inboundMapping];
}

@end

#pragma mark - RVBarcodeBlock

@implementation RVBarcodeBlock (Mapping)

- (NSDictionary *)inboundMapping {
    NSMutableDictionary *inboundMapping = [[super inboundMapping] mutableCopy];
    [inboundMapping addEntriesFromDictionary:@{@"barcodeString": @"barcodeString",
                                               @"barcodeLabel": @"barcodeLabel",
                                               @"barcodeType": @"barcodeFormat"}];
    
    return [NSDictionary dictionaryWithDictionary:inboundMapping];
}

- (NSDictionary *)valueTransformers {
    NSMutableDictionary *valueTransformers = [[super valueTransformers] mutableCopy];
    [valueTransformers addEntriesFromDictionary:@{@"barcodeFormat": [RVBlockValueTransformer valueTransformerWithBlock:^id(id inputValue) {
        if ([inputValue isEqualToString:@"code128"]) {
            return [NSNumber numberWithInteger:RVBarcodeTypeCode128];
        } else {
            return [NSNumber numberWithInteger:RVBarcodeTypePLU];
        }
    }]}];
    
    return valueTransformers;
}

@end
