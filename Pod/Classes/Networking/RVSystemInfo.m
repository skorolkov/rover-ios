//
//  RVSystemInfo.m
//  Pods
//
//  Created by Ata Namvari on 2015-04-20.
//
//

#import "RVSystemInfo.h"


#include <sys/sysctl.h>
NSString * getSysInfoByName(char *typeSpecifier)
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

NSString * platform()
{
    return getSysInfoByName("hw.machine");
}

@implementation RVSystemInfo

+ (NSString *)roverVersion {
    return @"0.30.8";
}

+ (NSString *)platform {
    return platform();
}

+ (NSString *)systemName {
    return [[UIDevice currentDevice] systemName];
}

+ (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

@end
