//
//  RVVisitController.m
//  Pods
//
//  Created by Ata Namvari on 2015-02-25.
//
//

#import "RVVisitController.h"
#import "Rover.h"
#import "RVLog.h"

@interface RVTouchpointInfo : NSObject <RVVisitTouchpointInfo>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *indexTitle;
@property (nonatomic, assign) NSUInteger numberOfCards;
@property (nonatomic, strong) NSArray *cards;

@end

@implementation RVTouchpointInfo

- (NSUInteger)numberOfCards {
    return self.cards.count;
}

@end

@interface RVVisitController () {
    BOOL _observingCards;
    BOOL _observingTouchpointChanges;
}

@property (nonatomic, strong) RVVisit *visit;
@property (nonatomic, strong) NSArray *touchpoints;

@end

@implementation RVVisitController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self observeForTouchpointChanges];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterNewLocation:) name:kRoverWillPostVisitNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterNewLocation:) name:kRoverDidEnterLocationNotification object:nil];
    }
    return self;
}

// TODO: this must be done better
// http://stackoverflow.com/questions/990069/when-should-i-remove-observers-error-about-deallocating-objects-before-removing

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeTouchpointObserver];
    [self removeCardObservers];
    _touchpoints = nil;
}

#pragma mark - Observing Methods

- (void)observeForTouchpointChanges {
    _visit = nil;
    if (!_observingTouchpointChanges) {
        [self.visit addObserver:self forKeyPath:@"visitedTouchpoints" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    _observingTouchpointChanges = YES;
}

- (void)removeTouchpointObserver {
    if (_observingTouchpointChanges) {
        [self.visit removeObserver:self forKeyPath:@"visitedTouchpoints" context:nil];
    }
    _observingTouchpointChanges = NO;
}

- (void)removeCardObservers {
    if (!_observingCards) {
        return;
    }
    
    [_touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {
        [touchpoint.cards enumerateObjectsUsingBlock:^(RVCard *card, NSUInteger idx, BOOL *stop) {
            [self removeObserverForCard:card];
        }];
    }];
    _observingCards = NO;
}

- (void)removeObserverForCard:(RVCard *)card {
    [card removeObserver:self forKeyPath:@"isDeleted"];
}


- (RVVisit *)visit {
    if (_visit) {
        return _visit;
    }
    
    _visit = [[Rover shared] currentVisit];
    return _visit;
}

- (NSPredicate *)predicate {
    return [NSPredicate predicateWithFormat:@"isDeleted = NO"];
}

#pragma mark - Public Properties

- (NSIndexPath *)indexPathForCard:(RVCard *)card {
    __block NSIndexPath *indexPath;
    [_touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger touchpointIdx, BOOL *touchpointsLoopStop) {
        [touchpoint.cards enumerateObjectsUsingBlock:^(RVCard *tCard, NSUInteger cardIdx, BOOL *cardsLoopStop) {
            if (tCard == card) {
                indexPath = [NSIndexPath indexPathForRow:cardIdx inSection:touchpointIdx];
                *cardsLoopStop = YES;
                *touchpointsLoopStop = YES;
            }
        }];
    }];
    return indexPath;
}

- (RVCard *)cardAtIndexPath:(NSIndexPath *)indexPath {
    return ((RVTouchpoint *)_touchpoints[indexPath.section]).cards[indexPath.row];
}

- (NSArray *)touchpoints {
    if (_touchpoints) {
        return _touchpoints;
    }
    
    NSMutableArray *touchpoints = [NSMutableArray array];
    [self.visit.visitedTouchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger touchpointIdx, BOOL *stop) {
        RVTouchpointInfo *touchpointInfo = [RVTouchpointInfo new];
        touchpointInfo.name = touchpoint.name;
        //touchpointInfo.indexTitle = touchpoint.indexTitle;
        touchpointInfo.cards = [touchpoint.cards filteredArrayUsingPredicate:self.predicate];
        
        // TODO: possibly move this out
        // Observe for card deletion
        [touchpointInfo.cards enumerateObjectsUsingBlock:^(RVCard *card, NSUInteger cardIdx, BOOL *stop) {
            [card addObserver:self forKeyPath:@"isDeleted" options:NSKeyValueObservingOptionNew context:(__bridge void *)(card)];
        }];
        _observingCards = YES;
        
        [touchpoints insertObject:touchpointInfo atIndex:touchpointIdx];
    }];
    
    _touchpoints = [NSArray arrayWithArray:touchpoints];
    
    return _touchpoints;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object class] == [RVVisit class]) {
        
        [self removeCardObservers];
        // Clear cache
        _touchpoints = nil;
        
        // TODO: consider deletion
        // New touchpoint
        if ([self.delegate respondsToSelector:@selector(controller:didChangeTouchpoint:atIndex:forChangeType:)]) {
            [self.delegate controller:self didChangeTouchpoint:[change objectForKey:NSKeyValueChangeNewKey][0] atIndex:0 forChangeType:RVVisitChangeInsert];
        }
    } else {
        
        // card delete
        
        NSIndexPath *indexPath = [self indexPathForCard:(__bridge RVCard *)(context)];
        
        [self removeCardObservers];
        _touchpoints = nil;
        
        if ([self.delegate respondsToSelector:@selector(controller:didChangeCard:atIndexPath:forChangeType:)]) {
            
            [self.delegate controller:self didChangeCard:object atIndexPath:indexPath forChangeType:RVVisitChangeDelete];
        }
    }
}

#pragma mark - Rover Notifications

- (void)willEnterNewLocation:(NSNotification *)note {
    [self removeTouchpointObserver];
    [self removeCardObservers];
}

- (void)didEnterNewLocation:(NSNotification *)note {
    [self observeForTouchpointChanges];
}


@end
