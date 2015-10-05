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
#import "RVBeaconRegion.h"

#import "RVBlock.h"
#import "RVImageBlock.h"

#define kRVVersion @"3.0.0"


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

- (BOOL)isInLocationWithIdentifier:(NSString *)identifier {
    return [self.location.ID isEqualToString:identifier];
}

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

- (BOOL)respondsToRegion:(CLRegion *)region {
    for (RVTouchpoint *touchpoint in self.touchpoints) {
        if ([touchpoint respondsToRegion:region]) {
            return YES;
        }
    }
    return NO;
}

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

- (NSArray *)touchpointsForRegion:(CLRegion *)region {
    return [self.touchpoints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVTouchpoint *touchpoint, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [touchpoint respondsToRegion:region];
    }]];
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

- (NSOrderedSet *)observableRegions {
    NSMutableOrderedSet *observableRegions = [NSMutableOrderedSet orderedSet];
    
    NSArray *sortedTouchpoints = [self.touchpoints sortedArrayUsingComparator:^NSComparisonResult(RVTouchpoint *tp1, RVTouchpoint *tp2) {
        RVDeck *deck1 = [self deckWithID:tp1.deckId];
        RVDeck *deck2 = [self deckWithID:tp2.deckId];
        
        // Sort by notification
        if (deck1.notification && !deck2.notification) {
            return NSOrderedAscending;
        } else if (!deck1.notification && deck2.notification) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    for (RVTouchpoint *touchpoint in sortedTouchpoints) {
        for (RVBeaconRegion *beaconRegion in touchpoint.beaconRegions) {
            NSString *identifier = [NSString stringWithFormat:@"%@:%@:%@", beaconRegion.UUID.UUIDString, beaconRegion.majorNumber, beaconRegion.minorNumber];
            CLBeaconRegion *clBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconRegion.UUID
                                                                                     major:beaconRegion.majorNumber.integerValue
                                                                                     minor:beaconRegion.minorNumber.integerValue
                                                                                identifier:identifier];
            //                          [observableRegions addObject:clBeaconRegion];
        }
    }
    
    return [NSOrderedSet orderedSetWithOrderedSet:observableRegions];
}

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
    
    [encoder encodeObject:self.beaconRegion forKey:@"beaconRegion"];
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
        self.beaconRegion = [decoder decodeObjectForKey:@"beaconRegion"];
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
    return [NSString stringWithFormat:@"<RVVisit: enteredAt: %@, beaconLastDetectedAt: %@, keepAlive: %f>",
            self.timestamp, self.beaconLastDetectedAt, self.keepAlive];
}

@end