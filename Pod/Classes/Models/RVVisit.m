//
//  RVVisit.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-26.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModelProject.h"
#import "RVVisitProject.h"
#import "RVCardProject.h"
#import "RVLocation.h"
#import "RVTouchpoint.h"

#import "RVBlock.h"
#import "RVImageBlock.h"

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

- (NSString *)welcomeMessage {
    if ([_welcomeMessage length] < 1) {
        return @"Welcome!";
    }
    
    return _welcomeMessage;
}

- (NSArray *)allImageUrls {
    NSMutableArray *array = [NSMutableArray array];
//    [self.touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {
//        [touchpoint.cards enumerateObjectsUsingBlock:^(RVCard *card, NSUInteger idx, BOOL *stop) {
//            [card.listviewBlocks enumerateObjectsUsingBlock:^(RVBlock *block, NSUInteger idx, BOOL *stop) {
//                if ([block isKindOfClass:[RVImageBlock class]]) {
//                    [array insertObject:((RVImageBlock *)block).imageURL atIndex:array.count];
//                }
//            }];
//        }];
//    }];
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

- (void)setEnteredAt:(NSDate *)enteredAt
{
    self.beaconLastDetectedAt = enteredAt;
    _enteredAt = enteredAt;
}

- (BOOL)isInRegion:(CLBeaconRegion *)beaconRegion
{
    return [self.UUID.UUIDString isEqualToString:beaconRegion.proximityUUID.UUIDString]
        && [self.major isEqualToNumber:beaconRegion.major];
}

- (RVTouchpoint *)touchpointForRegion:(CLBeaconRegion *)beaconRegion
{
    return [self touchpointForMinor:beaconRegion.minor];
}

- (RVTouchpoint *)touchpointForMinor:(NSNumber *)minor
{
    __block RVTouchpoint *touchpoint = nil;
    [self.touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *tp, NSUInteger idx, BOOL *stop) {
        if ([tp.minor isEqualToNumber:minor]) {
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
            [touchpointsWithNotification addObject:[[CLBeaconRegion alloc] initWithProximityUUID:self.UUID major:self.major.integerValue minor:touchpoint.minor.integerValue identifier:self.UUID.UUIDString]];
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
    
    // UUID
    NSString *UUID = [JSON objectForKey:@"uuid"];
    if (UUID && UUID != (id)[NSNull null]  && [UUID length] > 0) {
        self.UUID = [[NSUUID alloc] initWithUUIDString:UUID];
    }
    
    // major
    NSNumber *major = [JSON objectForKey:@"major"];
    if (major && major != (id)[NSNull null]) {
        self.major = major;
    }
    
    // customerID
    NSString *customerID = [JSON objectForKey:@"customer_id"];
    if (customerID && customerID != (id)[NSNull null] && [customerID length] > 0) {
        self.customerID = customerID;
    }
    
    // keepAlive
    NSNumber *keepAlive = [JSON objectForKey:@"keepAlive"];
    if (keepAlive && keepAlive != (id)[NSNull null]) {
        self.keepAlive = [keepAlive doubleValue] * 60;
    }
    
    NSDateFormatter *dateFormatter = [self dateFormatter];
    
    // enteredAt
    NSString *enteredAt = [JSON objectForKey:@"entered_at"];
    if (enteredAt && enteredAt != (id)[NSNull null] && [enteredAt length] > 0) {
        self.enteredAt = [dateFormatter dateFromString:enteredAt];
    }
    
    // exitedAt
    NSString *exitedAt = [JSON objectForKey:@"exited_at"];
    if (exitedAt && exitedAt != (id)[NSNull null] && [exitedAt length] > 0) {
        self.exitedAt = [dateFormatter dateFromString:exitedAt];
    }
    
    // openedAt
    NSString *openedAt = [JSON objectForKey:@"opened_at"];
    if (openedAt && openedAt != (id)[NSNull null] && [openedAt length] > 0) {
        self.openedAt = [dateFormatter dateFromString:openedAt];
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
    NSMutableDictionary *JSON = [[super toJSON] mutableCopy];
    
    // UUID
    if (self.UUID) {
        [JSON setObject:self.UUID.UUIDString forKey:@"uuid"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"uuid"];
    }
    
    // major
    if (self.major) {
        [JSON setObject:self.major forKey:@"major"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"major"];
    }
    
    // customerID
    if (self.customerID) {
        [JSON setObject:self.customerID forKey:@"customer_id"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"customer_id"];
    }
    
    
    NSDateFormatter *dateFormatter = [self dateFormatter];
    
    // enteredAt
    if (self.enteredAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.enteredAt] forKey:@"entered_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"entered_at"];
    }
    
    // exitedAt
    if (self.exitedAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.exitedAt] forKey:@"exited_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"exited_at"];
    }
    
    // openedAt
    if (self.openedAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.openedAt] forKey:@"opened_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"opened_at"];
    }
    
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

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.UUID forKey:@"UUID"];
    [encoder encodeObject:self.major forKey:@"major"];
    [encoder encodeObject:self.customerID forKey:@"customerID"];
    [encoder encodeObject:self.welcomeMessage forKey:@"welcomeMessage"];
    [encoder encodeObject:[NSNumber numberWithDouble:self.keepAlive] forKey:@"keepAlive"];
    [encoder encodeObject:self.primaryBackgroundColor forKey:@"primaryBackgroundColor"];
    [encoder encodeObject:self.primaryFontColor forKey:@"primaryFontColor"];
    [encoder encodeObject:self.secondaryBackgroundColor forKey:@"secondaryBackgroundColor"];
    [encoder encodeObject:self.secondaryFontColor forKey:@"secondaryFontColor"];
    [encoder encodeObject:self.enteredAt forKey:@"enteredAt"];
    [encoder encodeObject:self.exitedAt forKey:@"exitedAt"];
    [encoder encodeObject:self.openedAt forKey:@"openedAt"];
    [encoder encodeObject:self.beaconLastDetectedAt forKey:@"beaconLastDetecedAt"];
    [encoder encodeObject:self.touchpoints forKey:@"touchpoints"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [self init])) {
        //decode properties, other class vars
        self.UUID = [decoder decodeObjectForKey:@"UUID"];
        self.major = [decoder decodeObjectForKey:@"major"];
        self.customerID = [decoder decodeObjectForKey:@"customerID"];
        self.welcomeMessage = [decoder decodeObjectForKey:@"welcomeMessage"];
        //self.keepAlive = [[decoder decodeObjectForKey:@"keepAlive"] doubleValue];
        self.primaryBackgroundColor = [decoder decodeObjectForKey:@"primaryBackgroundColor"];
        self.primaryFontColor = [decoder decodeObjectForKey:@"primaryFontColor"];
        self.secondaryBackgroundColor = [decoder decodeObjectForKey:@"secondaryBackgroundColor"];
        self.secondaryFontColor = [decoder decodeObjectForKey:@"secondaryFontColor"];
        self.enteredAt = [decoder decodeObjectForKey:@"enteredAt"];
        self.exitedAt = [decoder decodeObjectForKey:@"exitedAt"];
        self.openedAt = [decoder decodeObjectForKey:@"openedAt"];
        self.beaconLastDetectedAt = [decoder decodeObjectForKey:@"beaconLastDetecedAt"];
        self.touchpoints = [decoder decodeObjectForKey:@"touchpoints"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<RVVisit: UUID: %@, Major: %@, enteredAt: %@, beaconLastDetectedAt: %@, keepAlive: %f>",
            self.UUID, self.major, self.enteredAt, self.beaconLastDetectedAt, self.keepAlive];
}

@end