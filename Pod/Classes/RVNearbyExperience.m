//
//  RVSimpleExperience.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import "RVNearbyExperience.h"
#import <SDWebImage/UIButton+WebCache.h>

@interface RVNearbyExperience ()

@property (nonatomic, strong) NSMutableDictionary *menuItemsDictionary;
@property (nonatomic, strong) RVDeck *openedDeck;

@property (nonatomic, strong) NSMutableSet *interactedDecks;

@end

@implementation RVNearbyExperience

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.recallMenu = [[RXRecallMenu alloc] init];
        self.menuItemsDictionary = [NSMutableDictionary dictionary];
        
        self.modalTransition = [RXModalTransition new];
    }
    return self;
}

#pragma mark - RoverDelegate

- (void)roverVisit:(RVVisit *)visit didEnterTouchpoints:(NSArray *)touchpoints {
    
    for (RVTouchpoint *touchpoint in touchpoints) {
        
        RVDeck *deck = [visit deckWithID:touchpoint.deckId];
        if (deck && ![self.interactedDecks containsObject:deck]) {
            
            RXMenuItem *menuItem = [self menuItemForDeck:deck];
            if (deck.cards.count > 0) {
                [self.recallMenu addItem:menuItem animated:self.recallMenu.isVisible];
            }
            
            
            [self.interactedDecks addObject:deck];
        }
        
        
        // ONLY present local notifications when the app is in the background
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            // Do nothing
        } else {
            // Send local notification
            
            if (deck.notification && !deck.delivered) {
                [[Rover shared] presentLocalNotification:deck.notification userInfo:@{@"visitID": visit.ID,
                                                                                      @"deckID": deck.ID}];
            }
        }
        
        
        // Mark deck as visited
        deck.delivered = YES;
    }
    
    // TODO: need to do a check to see if we have any items in the menu
    if (!self.recallMenu.isVisible && ![Rover shared].modalViewController) {
        [self.recallMenu show];
    }
    
}

- (void)roverVisit:(RVVisit *)visit didExitTouchpoints:(NSArray *)touchpoints {
    for (RVTouchpoint *touchpoint in touchpoints) {
        
        RVDeck *deck = [visit deckWithID:touchpoint.deckId];
        if (deck) {
            // Remove from interactedDecks if no other current touchpoint has the same deck
            BOOL otherTouchpointsHaveDeck = NO;
            for (RVTouchpoint *currentTP in visit.currentTouchpoints) {
                if ([currentTP.deckId isEqualToString:deck.ID]) {
                    otherTouchpointsHaveDeck = YES;
                    break;
                }
            }
            if (!otherTouchpointsHaveDeck) {
                [self.interactedDecks removeObject:deck];
                
                
                RXMenuItem *menuItem = [self menuItemForDeck:deck];
                [self.recallMenu removeItem:menuItem animated:YES];
            }
        }
        
    }
    
    if (self.recallMenu.itemCount == 0) {
        [self.recallMenu collapse:YES completion:nil];
        [self.recallMenu hide:YES completion:nil];
    }
}

- (void)roverDidDismissModalViewController {
    [self.recallMenu show];
}

- (void)roverVisitDidExpire:(RVVisit *)visit {
    if (self.recallMenu.isExpanded) {
        [self.recallMenu collapse:YES completion:nil];
    }
    [self.recallMenu hide:YES completion:nil];
}

- (void)roverWillDismissModalViewController:(UIViewController *)modalViewController {
    RVVisit *currentVisit = [Rover shared].currentVisit;
    
    for (RVTouchpoint *touchpoint in currentVisit.currentTouchpoints) {
        
        if ([touchpoint.deckId isEqualToString:_openedDeck.ID]) {
            modalViewController.transitioningDelegate = self.modalTransition;
            return;
        }
        
    }
}

- (void)didReceiveRoverNotificationWithUserInfo:(NSDictionary *)userInfo {
    NSString *visitID = [userInfo objectForKey:@"visitID"];
    RVVisit *currentVisit = [Rover shared].currentVisit;
    if (![currentVisit.ID isEqualToString:visitID]) {
        return;
    }
    
    NSString *deckID = [userInfo objectForKey:@"deckID"];
    RVDeck *deck = [currentVisit deckWithID:deckID];
    if (deck) {
        if ([Rover shared].modalViewController) {
            [[Rover shared].modalViewController dismissViewControllerAnimated:YES completion:^{
                [self presentModalForDeck:deck];
            }];
        } else {
            [self presentModalForDeck:deck];
        }
    }
}

- (void)didOpenApplicationDuringVisit:(RVVisit *)visit {
    if (!self.recallMenu.isVisible && ![Rover shared].modalViewController && visit.currentTouchpoints.count > 0) {
        NSMutableSet *currentDecks = [NSMutableSet set];
        for (RVTouchpoint *touchpoint in visit.currentTouchpoints) {
            RVDeck *deck = [visit deckWithID:touchpoint.deckId];
            if (deck) {
                [currentDecks addObject:deck];
            }
        }
        
        if (currentDecks.count > self.recallMenu.itemCount) {
            for (RXMenuItem *item in self.recallMenu.items) {
                [self.recallMenu removeItem:item animated:NO];
            }
            for (RVDeck *deck in currentDecks) {
                [self.recallMenu addItem:[self menuItemForDeck:deck] animated:NO];
            }
        }
        
        [self.recallMenu show];
    }
}

#pragma mark - Actions

- (void)menuItemClicked:(RXMenuItem *)menuItem {
    RVDeck *deck = [[Rover shared].currentVisit.decks objectAtIndex:menuItem.tag];
    [self presentModalForDeck:deck];
}

#pragma mark - Helpers

- (RXMenuItem *)menuItemForDeck:(RVDeck *)deck {
    RXMenuItem *menuItem = [self.menuItemsDictionary objectForKey:deck.ID];
    if (!menuItem) {
        menuItem = [RXMenuItem new];
        
        RVVisit *visit = [Rover shared].currentVisit;
        
        [menuItem setTag:[visit.decks indexOfObject:deck]];
        [menuItem setTitle:deck.title forState:UIControlStateNormal];
        [menuItem sd_setBackgroundImageWithURL:deck.avatarURL forState:UIControlStateNormal];
        [menuItem addTarget:self action:@selector(menuItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuItemsDictionary setObject:menuItem forKey:deck.ID];
    }
    return menuItem;
}

- (void)presentModalForDeck:(RVDeck *)deck {
    _openedDeck = deck;
    [self.recallMenu collapse:self.recallMenu.isVisible completion:^{
        [self.recallMenu hide:self.recallMenu.isVisible completion:^{
            if (deck) {
                [[Rover shared] presentModalWithDecks:@[deck]];
            }
        }];
    }];
}

@end
