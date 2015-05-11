//
//  RVMapper.h
//  Pods
//
//  Created by Ata Namvari on 2015-04-17.
//
//

#import <Foundation/Foundation.h>

@class RVModel;

/** A Mapper/JSON serializer that leverages the RVModel+Mapping category.
 */
@interface RVMapper : NSObject

/** ISO 8601 compliant date formatter.
 */
+ (NSDateFormatter *)dateFormatter;

/* Returns an NSDictionary representing a payload from an RVModel.
 */
- (NSDictionary *)JSONfromObject:(RVModel *)object;

/* Maps values from a JSON dictionary to an instance of RVModel.
 */
- (void)mapJSON:(NSDictionary *)JSON toObject:(RVModel *)object;

@end
