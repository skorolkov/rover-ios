//
//  RVSystemInfo.h
//  Pods
//
//  Created by Ata Namvari on 2015-04-20.
//
//

#import <Foundation/Foundation.h>

@interface RVSystemInfo : NSObject

+ (NSString *)platform;
+ (NSString *)systemName;
+ (NSString *)systemVersion;
+ (NSString *)roverVersion;

@end
