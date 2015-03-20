//
//  RVVisit.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-26.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModelProject.h"
#import "RVVisit.h"
#import "RVCardProject.h"
#import "RVLocation.h"
#import "RVTouchpoint.h"
#import "RVViewDefinition.h"
#import "RVCustomer.h"

#import "RVBlock.h"
#import "RVImageBlock.h"

#import "RVNetworkingManager.h"

#pragma mark - SystemCalls

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


@interface RVVisit ()

@property (nonatomic, strong) NSMutableArray *mVisitedTouchpoints;

@end

@implementation RVVisit

#pragma mark - Overridden Properties

- (NSString *)modelName {
    return @"visit";
}

#pragma mark - Properties

- (BOOL)isAlive {
    NSDate *now = [NSDate date];
    NSTimeInterval elapsed = [now timeIntervalSinceDate:self.beaconLastDetectedAt];
    return elapsed < self.keepAlive;
}

- (NSArray *)allImageUrls {
    NSMutableArray *array = [NSMutableArray array];
    [self.touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {
        [touchpoint.cards enumerateObjectsUsingBlock:^(RVCard *card, NSUInteger idx, BOOL *stop) {
            [card.viewDefinitions enumerateObjectsUsingBlock:^(RVViewDefinition *viewDefintion, NSUInteger idx, BOOL *stop) {
                [viewDefintion.blocks enumerateObjectsUsingBlock:^(RVBlock *block, NSUInteger idx, BOOL *stop) {
                    if ([block isKindOfClass:[RVImageBlock class]]) {
                        [array insertObject:((RVImageBlock *)block).imageURL atIndex:array.count];
                    }
                    
                    // add background images
                }];
                // add background image
            }];
        }];
    }];
    return [NSArray arrayWithArray:array];
}

- (NSArray *)unreadCards {
//    NSIndexSet *indexes = [self.cards indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        RVCard *card = (RVCard *)obj;
//        return card.isUnread;
//    }];
//    return [self.cards objectsAtIndexes:indexes];
}

- (NSArray *)savedCards {
//    NSIndexSet *indexes = [self.cards indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        RVCard *card = (RVCard *)obj;
//        return card.likedAt ? YES : NO;
//    }];
//    return [self.cards objectsAtIndexes:indexes];
}

- (void)setTimestamp:(NSDate *)timestamp
{
    self.beaconLastDetectedAt = timestamp;
    _timestamp = timestamp;
}

- (BOOL)isInRegion:(CLBeaconRegion *)beaconRegion
{
    return [self.UUID.UUIDString isEqualToString:beaconRegion.proximityUUID.UUIDString]
        && [self.majorNumber isEqualToNumber:beaconRegion.major];
}

- (RVTouchpoint *)touchpointForRegion:(CLBeaconRegion *)beaconRegion
{
    return [self touchpointForMinor:beaconRegion.minor];
}

- (RVTouchpoint *)touchpointForMinor:(NSNumber *)minor
{
    __block RVTouchpoint *touchpoint = nil;
    [self.touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *tp, NSUInteger idx, BOOL *stop) {
        if ([tp.minorNumber isEqualToNumber:minor]) {
            touchpoint = tp;
            *stop = YES;
        }
    }];
    return touchpoint;
}

- (NSArray *)visitedTouchpoints
{
    return _mVisitedTouchpoints;
}

- (NSArray *)observableRegions {
    NSMutableArray *touchpointsWithNotification = [NSMutableArray array];
    [self.touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {
        if (touchpoint.notification && ![touchpoint.notification isEqualToString:@""]) {
            [touchpointsWithNotification addObject:[[CLBeaconRegion alloc] initWithProximityUUID:self.UUID major:self.majorNumber.integerValue minor:touchpoint.minorNumber.integerValue identifier:self.UUID.UUIDString]];
        }
    }];
    return touchpointsWithNotification;
}

- (void)setCurrentTouchpoint:(RVTouchpoint *)currentTouchpoint
{
    if (![_mVisitedTouchpoints containsObject:currentTouchpoint]) {
        // TODO: research better KVO patterns
        [self willChangeValueForKey:@"visitedTouchpoints"];
        [_mVisitedTouchpoints insertObject:currentTouchpoint atIndex:0];
        [self didChangeValueForKey:@"visitedTouchpoints"];
    }
    _currentTouchpoint = currentTouchpoint;
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        _mVisitedTouchpoints = [NSMutableArray array];
    }
    return self;
}

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];

    // TODO: investigate this (how does this impact [Rover shared].custome)
    // customer
//    NSString *customerID = [JSON objectForKey:@"customer"];
//    if (customerID && customerID != (id)[NSNull null] && [customerID length] > 0) {
//        self.customer = customerID;
//    }
    
    // keepAlive
    NSNumber *keepAlive = [JSON objectForKey:@"keepAlive"];
    if (keepAlive && keepAlive != (id)[NSNull null]) {
        self.keepAlive = [keepAlive doubleValue] * 60;
    }
    
    //location
    NSDictionary *locationData = [JSON objectForKey:@"location"];
    if (locationData) {
        RVLocation *location = [[RVLocation alloc] initWithJSON:locationData];
        self.location = location;
    }
    
    //touchpoints
    NSArray *touchpointsData = [JSON objectForKey:@"touchpoints"];
    if (touchpointsData && touchpointsData != (id)[NSNull null]) {
        NSMutableArray *touchpoints = [NSMutableArray arrayWithCapacity:[touchpointsData count]];
        [touchpointsData enumerateObjectsUsingBlock:^(NSDictionary *touchpointData, NSUInteger idx, BOOL *stop) {
            RVTouchpoint *touchpoint = [[RVTouchpoint alloc] initWithJSON:touchpointData];
            [touchpoints addObject:touchpoint];
        }];
        self.touchpoints = [touchpoints copy];
    }
    
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    
    // UUID
    [JSON setObject:RVNullSafeValueFromObject(self.UUID.UUIDString) forKey:@"uuid"];

    // major
    [JSON setObject:RVNullSafeValueFromObject(self.majorNumber) forKey:@"majorNumber"];

    // customer
    [JSON setObject:RVNullSafeValueFromObject([self.customer toJSON]) forKey:@"customer"];
    
    // device
    [JSON setObject:platform() forKey:@"device"];
    
    // operatingSystem
    [JSON setObject:[[UIDevice currentDevice] systemName] forKey:@"operatingSystem"];
    
    // operatingSystemVersion
    [JSON setObject:[[UIDevice currentDevice] systemVersion] forKey:@"osVersion"];
    
    // timestamp
    [JSON setObject:[[self dateFormatter] stringFromDate:self.timestamp] forKey:@"timestamp"];
    
    // version (SDK)
    // TODO: setup a compiler constant to handle this
    [JSON setObject:@"0.3.0" forKey:@"sdkVersion"];
    
    return JSON;
}


- (void)save:(void (^)(void))success failure:(void (^)(NSString *))failure
{
    [super save:^{
        [self persistToDefaults];
        if (success) {
            success();
        }
    } failure:failure];
}

- (void)persistToDefaults
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:@"_roverLatestVisit"];
    [standardDefaults synchronize];
}

- (void)trackEvent:(NSString *)event params:(NSDictionary *)params {
    NSLog(@"Tracking (%@)", event);
    
    NSArray *eventComponents = [event componentsSeparatedByString:@"."];
    
    NSMutableDictionary *eventParams = [NSMutableDictionary dictionaryWithDictionary:@{@"object": eventComponents[0],
                                                                                       @"action": eventComponents[1],
                                                                                       @"timestamp": [[self dateFormatter] stringFromDate:[NSDate date]]}];
    
    [eventParams addEntriesFromDictionary:params];
    
    NSString *path = [NSString stringWithFormat:@"%@/events", [self updatePath]];
    
    [[RVNetworkingManager sharedManager] sendRequestWithMethod:@"POST" path:path parameters:eventParams success:^(NSDictionary *data) {
        NSLog(@"%@ tracked successfully", event);
    } failure:^(NSError *error) {
        NSLog(@"%@ failed: %@",event, error);
    }];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.UUID forKey:@"UUID"];
    [encoder encodeObject:self.majorNumber forKey:@"major"];
    //[encoder encodeObject:self.customerID forKey:@"customerID"];
    //[encoder encodeObject:self.welcomeMessage forKey:@"welcomeMessage"];
    [encoder encodeObject:[NSNumber numberWithDouble:self.keepAlive] forKey:@"keepAlive"];
//    [encoder encodeObject:self.primaryBackgroundColor forKey:@"primaryBackgroundColor"];
//    [encoder encodeObject:self.primaryFontColor forKey:@"primaryFontColor"];
//    [encoder encodeObject:self.secondaryBackgroundColor forKey:@"secondaryBackgroundColor"];
//    [encoder encodeObject:self.secondaryFontColor forKey:@"secondaryFontColor"];
    [encoder encodeObject:self.timestamp forKey:@"timestamp"];
//    [encoder encodeObject:self.exitedAt forKey:@"exitedAt"];
   // [encoder encodeObject:self.openedAt forKey:@"openedAt"];
    [encoder encodeObject:self.beaconLastDetectedAt forKey:@"beaconLastDetecedAt"];
    [encoder encodeObject:self.touchpoints forKey:@"touchpoints"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [self init])) {
        //decode properties, other class vars
        self.UUID = [decoder decodeObjectForKey:@"UUID"];
        self.majorNumber = [decoder decodeObjectForKey:@"major"];
       // self.customerID = [decoder decodeObjectForKey:@"customerID"];
        //self.welcomeMessage = [decoder decodeObjectForKey:@"welcomeMessage"];
        //self.keepAlive = [[decoder decodeObjectForKey:@"keepAlive"] doubleValue];
//        self.primaryBackgroundColor = [decoder decodeObjectForKey:@"primaryBackgroundColor"];
//        self.primaryFontColor = [decoder decodeObjectForKey:@"primaryFontColor"];
//        self.secondaryBackgroundColor = [decoder decodeObjectForKey:@"secondaryBackgroundColor"];
//        self.secondaryFontColor = [decoder decodeObjectForKey:@"secondaryFontColor"];
        self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
        //self.exitedAt = [decoder decodeObjectForKey:@"exitedAt"];
        //self.openedAt = [decoder decodeObjectForKey:@"openedAt"];
        self.beaconLastDetectedAt = [decoder decodeObjectForKey:@"beaconLastDetecedAt"];
        self.touchpoints = [decoder decodeObjectForKey:@"touchpoints"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<RVVisit: UUID: %@, Major: %@, enteredAt: %@, beaconLastDetectedAt: %@, keepAlive: %f>",
            self.UUID, self.majorNumber, self.timestamp, self.beaconLastDetectedAt, self.keepAlive];
}

@end