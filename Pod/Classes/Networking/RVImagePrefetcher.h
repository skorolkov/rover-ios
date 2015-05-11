//
//  RVImagePrefetcher.h
//  Pods
//
//  Created by Ata Namvari on 2015-03-18.
//
//

#import <Foundation/Foundation.h>

/** An image prefetcher that can download image files in the background and save them to SDWebImage's shared cache.
 */
@interface RVImagePrefetcher : NSObject

+ (instancetype)sharedImagePrefetcher;

/** Initiates the background download process for all NSURLs in urls.
 */
- (void)prefetchURLs:(NSArray *)urls;

@end
