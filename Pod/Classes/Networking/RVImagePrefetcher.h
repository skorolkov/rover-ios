//
//  RVImagePrefetcher.h
//  Pods
//
//  Created by Ata Namvari on 2015-03-18.
//
//

#import <Foundation/Foundation.h>

@interface RVImagePrefetcher : NSObject

+ (instancetype)sharedImagePrefetcher;

- (void)prefetchURLs:(NSArray *)urls;

@end
