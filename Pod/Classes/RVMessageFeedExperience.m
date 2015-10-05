//
//  RVRetailExperienceManager.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import "RVMessageFeedExperience.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RVMessageFeedExperience ()



@end

@implementation RVMessageFeedExperience

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalTransitionManager = [RXModalTransition new];
    }
    return self;
}

- (RXRecallButton *)recallButton {
    if (_recallButton || ![Rover shared].currentVisit) {
        return _recallButton;
    }
    
    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    _recallButton = [[RXRecallButton alloc] initWithCustomView:avatarImageView initialPosition:RXRecallButtonPositionBottomRight];
    [_recallButton addTarget:self action:@selector(recallButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    RVTouchpoint *locationTouchpoint = [Rover shared].currentVisit.visitedTouchpoints.firstObject;
    RVDeck *deck = [[Rover shared].currentVisit deckWithID:locationTouchpoint.deckId];
    if (deck) {
        [avatarImageView sd_setImageWithURL:deck.avatarURL];
    }
    
    return _recallButton;
}

#pragma mark - RoverDelegate

- (void)roverVisit:(RVVisit *)visit didEnterTouchpoints:(NSArray *)touchpoints {
    
    // Update the current modal view controller if it is present
    
    if ([[Rover shared].modalViewController isKindOfClass:[RXVisitViewController class]]) {
        RXVisitViewController *visitViewController = (RXVisitViewController *)[Rover shared].modalViewController;
        
        // Construct the set of decks for the touchpoints
        NSMutableSet *decks = [NSMutableSet set];
        for (RVTouchpoint *touchpoint in touchpoints) {
            RVDeck *deck = [visit deckWithID:touchpoint.deckId];
            if (deck) {
                [decks addObject:deck];
            }
        }
        
        
        NSMutableArray *decksDifference = [NSMutableArray arrayWithArray:decks.allObjects];
        [decksDifference removeObjectsInArray:visitViewController.decks];
        
        NSMutableArray *decksWithCards = [[decksDifference filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVDeck *deck, NSDictionary *bindings) {
            return deck.cards.count > 0;
        }]] mutableCopy];
        
        if (decksWithCards.count > 0) {
            [visitViewController addDecks:decksWithCards];
        }
    } else {
        // Otherwise if the modal is not open show the recall button
        if (!self.recallButton.isVisible) {
            [self.recallButton show];
        }
    }
    
    
    [touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {
        
        RVDeck *deck = [visit deckWithID:touchpoint.deckId];
        if (deck) {
            // If the app is in not in the foreground present local notification
            
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                // Do Nothing
            } else if (!deck.delivered) {
                
                if (deck.notification) {
                    [[Rover shared] presentLocalNotification:deck.notification userInfo:@{@"visitID": visit.ID}];
                }
                
            }
            
            // Mark the deck as delivered, so we only send notifications once per deck
            deck.delivered = YES;
        }
        
    }];
}

- (void)didReceiveRoverNotificationWithUserInfo:(NSDictionary *)userInfo {
    NSString *visitID = [userInfo objectForKey:@"visitID"];
    RVVisit *currentVisit = [Rover shared].currentVisit;
    if (![currentVisit.ID isEqualToString:visitID]) {
        return;
    }
    
    if (![Rover shared].modalViewController) {
        [self presentModalForVisit:currentVisit];
    } else {
        // TODO: this doesnt set the animation stuff for RXMODALVIEWCONTROLLER
        RXModalViewController *modalViewController = (RXModalViewController *)[[Rover shared] modalViewController];
        [modalViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)roverDidDismissModalViewController {
    [self.recallButton show];
}

- (void)roverVisitDidExpire:(RVVisit *)visit {
    [self.recallButton hide:YES completion:nil];
    _recallButton = nil;
}

- (void)roverWillDisplayModalViewController:(UIViewController *)modalViewController {
    modalViewController.transitioningDelegate = self.modalTransitionManager;
}

- (void)didOpenApplicationDuringVisit:(RVVisit *)visit {
    if ([Rover shared].currentVisit && !self.recallButton.isVisible && ![Rover shared].modalViewController) {
        [self.recallButton show];
    }
}

#pragma mark - RXRecallButton Action

- (void)recallButtonClicked:(RXDraggableView *)draggableView {
    [self presentModalForVisit:[Rover shared].currentVisit];
}

#pragma mark - Helper

- (void)presentModalForVisit:(RVVisit *)visit {
    NSMutableSet *decks = [NSMutableSet set];
    for (RVTouchpoint *touchpoint in visit.visitedTouchpoints) {
        RVDeck *deck = [visit deckWithID:touchpoint.deckId];
        if (deck) {
            [decks addObject:deck];
        }
    }
    
    if (!self.recallButton.isVisible) {
        [[Rover shared] presentModalWithDecks:decks.allObjects];
    } else {
        [self.recallButton hide:YES completion:^{
            [[Rover shared] presentModalWithDecks:decks.allObjects];
        }];
    }
}

@end
