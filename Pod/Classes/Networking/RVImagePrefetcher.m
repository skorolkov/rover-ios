//
//  RVImagePrefetcher.m
//  Pods
//
//  Created by Ata Namvari on 2015-03-18.
//
//

#import "RVImagePrefetcher.h"
#import <SDWebImage/UIImage+MultiFormat.h>
#import <SDWebImage/SDWebImageManager.h>

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@interface RVImagePrefetcher () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSMutableDictionary *downloadTasks;

@end

@implementation RVImagePrefetcher

+ (instancetype)sharedImagePrefetcher {
    static RVImagePrefetcher *sharedPrefetcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPrefetcher = [[self alloc] init];
    });
    return sharedPrefetcher;
}

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration;
        
        // if iOS 7
        // configuration  = blah balh balh
        if ([NSURLSessionConfiguration respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]) {
            configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"roverBacgroundImagePrefetchSession"];
        } else {
            configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"roverBacgroundImagePrefetchSession"];
        }
        
        self.urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        self.downloadTasks = [NSMutableDictionary new];
    }
    return self;
}

- (void)prefetchURLs:(NSArray *)urls {
    SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
    [urls enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        BOOL cacheExists = [imageManager cachedImageExistsForURL:url];
        if (!cacheExists) {
            
            NSURLSessionDownloadTask *downloadTask = [self.urlSession downloadTaskWithURL:url];
            
            [self.downloadTasks setObject:@(downloadTask.taskIdentifier) forKey:url];
            
            [downloadTask resume];
        }
    }];
}

#pragma mark - NSURLSessionDownloadTaskDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSData *imageData = [NSData dataWithContentsOfURL:location];
    [[SDWebImageManager sharedManager] saveImageToCache:[UIImage sd_imageWithData:imageData] forURL:downloadTask.originalRequest.URL];
    
}

@end
