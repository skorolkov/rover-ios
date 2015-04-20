//
//  RVMapper.h
//  Pods
//
//  Created by Ata Namvari on 2015-04-17.
//
//

#import <Foundation/Foundation.h>

@class RVModel;

@interface RVMapper : NSObject

+ (NSDateFormatter *)dateFormatter;

- (NSDictionary *)JSONfromObject:(RVModel *)object;
- (void)mapJSON:(NSDictionary *)JSON toObject:(RVModel *)object;

@end
