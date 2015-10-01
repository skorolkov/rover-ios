//
//  RVVisit.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-26.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVVisit.h"
#import "RVLocation.h"
#import "RVTouchpoint.h"
#import "RVViewDefinition.h"
#import "RVCustomer.h"
#import "RVCard.h"
#import "RVOrganization.h"
#import "RVDeck.h"

#import "RVBlock.h"
#import "RVImageBlock.h"

#define kRVVersion @"0.33.0"


NSString *const kRVVisitManagerLatestVisitPersistenceKey = @"_roverLatestVisit";
NSString *const kRVVisitManagerLatestVisitVersionKey = @"_roverVersion";

@interface RVVisit ()

@property (nonatomic, strong) NSMutableArray *mVisitedTouchpoints;
@property (nonatomic, strong) NSSet *wildcardTouchpoints;

@end

@implementation RVVisit

#pragma mark - Class Methods

static RVVisit *_latestVisit;

+ (instancetype)latestVisit {

    
    if (_latestVisit) {
        return _latestVisit;
    }
    
    NSUserDefaults *standardDefault = [NSUserDefaults standardUserDefaults];
    NSString *version = [standardDefault objectForKey:kRVVisitManagerLatestVisitVersionKey];
    
    // TODO: make this global somehwere
    if (![version isEqualToString:kRVVersion]) {
        [self clearLatestVisit];
        [standardDefault setObject:kRVVersion forKey:kRVVisitManagerLatestVisitVersionKey];
    }
    
    NSData *visitData = [standardDefault objectForKey:kRVVisitManagerLatestVisitPersistenceKey];
    if (visitData) {
        _latestVisit = [NSKeyedUnarchiver unarchiveObjectWithData:visitData];
    }
    
    return _latestVisit;
}

+ (void)clearLatestVisit {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRVVisitManagerLatestVisitPersistenceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _latestVisit = nil;
}

+ (void)setLatestVisit:(RVVisit *)visit {
    _latestVisit = visit;
    [_latestVisit persistToDisk];
}

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
    [self.decks enumerateObjectsUsingBlock:^(RVDeck *deck, NSUInteger idx, BOOL *stop) {
        [deck.cards enumerateObjectsUsingBlock:^(RVCard *card, NSUInteger idx, BOOL *stop) {
            [card.viewDefinitions enumerateObjectsUsingBlock:^(RVViewDefinition *viewDefintion, NSUInteger idx, BOOL *stop) {
                [viewDefintion.blocks enumerateObjectsUsingBlock:^(RVBlock *block, NSUInteger idx, BOOL *stop) {
                    // image blocks
                    if ([block isKindOfClass:[RVImageBlock class]]) {
                        [array addObject:((RVImageBlock *)block).imageURL];
                    }
                    
                    // add background images
                    if (block.backgroundImageURL) {
                        [array addObject:block.backgroundImageURL];
                    }
                }];
                // add background image
                if (viewDefintion.backgroundImageURL) {
                    [array addObject:viewDefintion.backgroundImageURL];
                }
            }];
            
            // touchpoint avatar
            if (deck.avatarURL) {
                [array addObject:deck.avatarURL];
            }
        }];
    }];
        
    return [NSArray arrayWithArray:array];
}

- (void)setTimestamp:(NSDate *)timestamp
{
    self.beaconLastDetectedAt = timestamp;
    _timestamp = timestamp;
}

- (BOOL)isInLocationRegion:(CLBeaconRegion *)beaconRegion
{
    return [self.UUID.UUIDString isEqualToString:beaconRegion.proximityUUID.UUIDString]
        && [self.majorNumber isEqualToNumber:beaconRegion.major];
}

- (BOOL)isInLocationWithIdentifier:(NSString *)identifier {
    return [self.location.ID isEqualToString:identifier];
}

// TODO: use beacons array
//- (BOOL)isInTouchpointRegion:(CLBeaconRegion *)beaconRegion {
//    for (RVTouchpoint *touchpoint in self.currentTouchpoints) {
//        if ([touchpoint.minorNumber isEqualToNumber:beaconRegion.minor]) {
//            return YES;
//        }
//    }
//    return NO;
//}

- (BOOL)hasTouchpointWithIdentifier:(NSString *)identifier {
    for (RVTouchpoint *touchpoint in self.touchpoints) {
        if ([touchpoint.ID isEqualToString:identifier]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasTouchpointWithGimbalIdentifier:(NSString *)identifier {
    for (RVTouchpoint *touchpoint in self.touchpoints) {
        if ([touchpoint.gimbalPlaceId isEqualToString:identifier]) {
            return YES;
        }
    }
    return NO;
}

- (RVTouchpoint *)touchpointForRegion:(CLBeaconRegion *)beaconRegion
{
    return [self touchpointForMinor:beaconRegion.minor];
}

// TODO: use beacons array
//- (RVTouchpoint *)touchpointForMinor:(NSNumber *)minor
//{
//    __block RVTouchpoint *touchpoint = nil;
//    [self.touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *tp, NSUInteger idx, BOOL *stop) {
//        if ([tp.minorNumber isEqualToNumber:minor]) {
//            touchpoint = tp;
//            *stop = YES;
//        }
//    }];
//    return touchpoint;
//}

- (RVTouchpoint *)touchpointWithID:(NSString *)identifier {
    for (RVTouchpoint *touchpoint in self.touchpoints) {
        if ([touchpoint.ID isEqualToString:identifier]) {
            return touchpoint;
        }
    }
    return nil;
}

- (RVTouchpoint *)touchpointWithGimbalIdentifier:(NSString *)identifier {
    for (RVTouchpoint *touchpoint in self.touchpoints) {
        if ([touchpoint.gimbalPlaceId isEqualToString:identifier]) {
            return touchpoint;
        }
    }
    return nil;
}

- (NSSet *)wildcardTouchpoints {
    if (_wildcardTouchpoints) {
        return _wildcardTouchpoints;
    }
    
    _wildcardTouchpoints = [NSSet setWithArray:[self.touchpoints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVTouchpoint *touchpoint, NSDictionary *bindings) {
        return touchpoint.type == RVTouchpointTypeLocation;
    }]]];
    return _wildcardTouchpoints;
}

- (NSArray *)visitedTouchpoints
{
    return _mVisitedTouchpoints;
}

- (RVDeck *)deckWithID:(NSString *)ID {
    for (RVDeck *deck in self.decks) {
        if ([deck.ID isEqualToString:ID]) {
            return deck;
        }
    }
    return nil;
}

// TOOD: use beacons array
//- (NSArray *)observableRegions {
//    NSMutableArray *touchpointsToObserve = [NSMutableArray array];
//    [[[self.touchpoints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVTouchpoint *touchpoint, NSDictionary *bindings) {
//        // Filter for specific touchpoints
//        return touchpoint.type == RVTouchpointTypeBeacon;
//    }]] sortedArrayUsingComparator:^NSComparisonResult(RVTouchpoint *touchpoint1, RVTouchpoint *touchpoint2) {
//        // Sort by notification
//        if (touchpoint1.notification && !touchpoint2.notification) {
//            return NSOrderedAscending;
//        } else if (!touchpoint1.notification && touchpoint2.notification) {
//            return NSOrderedDescending;
//        }
//        return NSOrderedSame;
//    }] enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {
//        [touchpointsToObserve addObject:[[CLBeaconRegion alloc] initWithProximityUUID:self.UUID major:self.majorNumber.integerValue minor:touchpoint.minorNumber.integerValue identifier:touchpoint.ID]];
//    }];
//    return touchpointsToObserve;
//}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        _mVisitedTouchpoints = [NSMutableArray array];
        _currentTouchpoints = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Touchpoint Tracking

- (void)addToCurrentTouchpoints:(RVTouchpoint *)touchpoint {
    [self.currentTouchpoints addObject:touchpoint];
    if (!touchpoint.isVisited/*![_mVisitedTouchpoints containsObject:touchpoint]*/) {
        [self willChangeValueForKey:@"visitedTouchpoints"];
        touchpoint.isVisited = YES;
        [_mVisitedTouchpoints insertObject:touchpoint atIndex:0];
        [self didChangeValueForKey:@"visitedTouchpoints"];
    }
}

- (void)removeFromCurrentTouchpoints:(RVTouchpoint *)touchpoint {
    [self.currentTouchpoints removeObject:touchpoint];
}

#pragma mark - NSCoding

- (NSArray *)visitedTouchpointIDs {
    NSMutableArray *visitedTouchpoindIds = [NSMutableArray arrayWithCapacity:self.visitedTouchpoints.count];
    [self.visitedTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {
        [visitedTouchpoindIds insertObject:touchpoint.ID atIndex:idx];
    }];
    return visitedTouchpoindIds;
}

- (void)setVisitedTouchpointIDs:(NSArray *)ids {
    [ids enumerateObjectsUsingBlock:^(NSString *touchpointID, NSUInteger idx, BOOL *stop) {
        RVTouchpoint *touchpoint = [self touchpointWithID:touchpointID];
        if (touchpoint) {
            [_mVisitedTouchpoints insertObject:touchpoint atIndex:idx];
        } else {
            [_mVisitedTouchpoints insertObject:[NSNull null] atIndex:idx];
        }
    }];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.UUID forKey:@"UUID"];
    [encoder encodeObject:self.majorNumber forKey:@"majorNumber"];
    [encoder encodeObject:[NSNumber numberWithDouble:self.keepAlive] forKey:@"keepAlive"];
    [encoder encodeObject:self.timestamp forKey:@"timestamp"];
    [encoder encodeObject:self.organization forKey:@"organization"];
    [encoder encodeObject:self.location forKey:@"location"];
    // TODO: do we need customer? its already in [[Rover shared] customer]
    [encoder encodeObject:self.beaconLastDetectedAt forKey:@"beaconLastDetecedAt"];
    [encoder encodeObject:self.touchpoints forKey:@"touchpoints"];
    [encoder encodeObject:self.visitedTouchpointIDs forKey:@"visitedTouchpointIDs"];
    [encoder encodeObject:[NSNumber numberWithBool:self.simulate] forKey:@"simulate"];
    [encoder encodeObject:[NSNumber numberWithBool:self.locationEntered] forKey:@"locationEntered"];
    [encoder encodeObject:self.decks forKey:@"decks"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.UUID = [decoder decodeObjectForKey:@"UUID"];
        self.majorNumber = [decoder decodeObjectForKey:@"majorNumber"];
        self.keepAlive = [[decoder decodeObjectForKey:@"keepAlive"] doubleValue];
        self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
        self.organization = [decoder decodeObjectForKey:@"organization"];
        self.location = [decoder decodeObjectForKey:@"location"];
        // TODO: customer?
        self.beaconLastDetectedAt = [decoder decodeObjectForKey:@"beaconLastDetecedAt"];
        self.touchpoints = [decoder decodeObjectForKey:@"touchpoints"];
        
        [self setVisitedTouchpointIDs:[decoder decodeObjectForKey:@"visitedTouchpointIDs"]];
        
        self.simulate = [[decoder decodeObjectForKey:@"simulate"] boolValue];
        self.locationEntered = [[decoder decodeObjectForKey:@"locationEntered"] boolValue];
        self.decks = [decoder decodeObjectForKey:@"decks"];
    }
    return self;
}

#pragma mark - Persistence

- (void)persistToDisk {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:kRVVisitManagerLatestVisitPersistenceKey];
    [standardDefaults synchronize];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<RVVisit: UUID: %@, Major: %@, enteredAt: %@, beaconLastDetectedAt: %@, keepAlive: %f>",
            self.UUID, self.majorNumber, self.timestamp, self.beaconLastDetectedAt, self.keepAlive];
}

@end