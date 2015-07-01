//
//  RVSimpleExperience.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import "RVNearbyExperience.h"
#import "Rover.h"
#import <SDWebImage/UIButton+WebCache.h>

@interface RVNearbyExperience ()

@property (nonatomic, strong) RXRecallMenu *recallMenu;
@property (nonatomic, strong) NSMutableDictionary *menuItemsDictionary;
@property (nonatomic, strong) RXModalTransition *modalTransition;
@property (nonatomic, strong) RVTouchpoint *openedTouchpoint;

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
        RXMenuItem *menuItem = [self menuItemForTouchpoint:touchpoint];
        if (touchpoint.cards.count > 0) {
            [self.recallMenu addItem:menuItem animated:self.recallMenu.isVisible];
        }
    }
    
    if (!self.recallMenu.isVisible && ![Rover shared].modalViewController) {
        [self.recallMenu show:YES completion:nil];
    }
    

    // ONLY present local notifications when the app is in the background
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        // Do nothing
    } else {
        // Send local notification
        
        for (RVTouchpoint *touchpoint in touchpoints) {
            if (touchpoint.notification && !touchpoint.notificationDelivered) {
                [[Rover shared] presentLocalNotification:touchpoint.notification userInfo:@{@"visitID": visit.ID,
                                                                                            @"touchpointID": touchpoint.ID}];
            }
        }
    }
    
    // Mark touchpoints as visited
    
    for (RVTouchpoint *touchpoint in touchpoints) {
        touchpoint.notificationDelivered = YES;
    }
}

- (void)roverVisit:(RVVisit *)visit didExitTouchpoints:(NSArray *)touchpoints {
    for (RVTouchpoint *touchpoint in touchpoints) {
        RXMenuItem *menuItem = [self menuItemForTouchpoint:touchpoint];
        [self.recallMenu removeItem:menuItem animated:YES];
    }
    
    if (self.recallMenu.itemCount == 0) {
        [self.recallMenu hide:YES completion:nil];
    }
}

- (void)roverDidDismissModalViewController {
    [self.recallMenu show:YES completion:nil];
}

- (void)roverVisitDidExpire:(RVVisit *)visit {
    if (self.recallMenu.isExpanded) {
        [self.recallMenu collapse:YES completion:nil];
    }
    [self.recallMenu hide:YES completion:nil];
}

- (void)roverWillDismissModalViewController:(UIViewController *)modalViewController {
    if ([[Rover shared].currentVisit.currentTouchpoints containsObject:_openedTouchpoint]) {
        modalViewController.transitioningDelegate = self.modalTransition;
    }
}

- (void)didReceiveRoverNotificationWithUserInfo:(NSDictionary *)userInfo {
    NSString *visitID = [userInfo objectForKey:@"visitID"];
    RVVisit *currentVisit = [Rover shared].currentVisit;
    if (![currentVisit.ID isEqualToString:visitID]) {
        return;
    }
    
    NSString *touchpointID = [userInfo objectForKey:@"touchpointID"];
    RVTouchpoint *touchpoint = [currentVisit touchpointWithID:touchpointID];
    if (touchpoint) {
        if ([Rover shared].modalViewController) {
            [[Rover shared].modalViewController dismissViewControllerAnimated:YES completion:^{
                [self presentModalForTouchpoint:touchpoint];
            }];
        } else {
            [self presentModalForTouchpoint:touchpoint];
        }
    }
}

- (void)didOpenApplicationDuringVisit:(RVVisit *)visit {
    if ([Rover shared].currentVisit && !self.recallMenu.isVisible && ![Rover shared].modalViewController) {
        [self.recallMenu show:YES completion:nil];
    }
}

#pragma mark - Actions

- (void)menuItemClicked:(RXMenuItem *)menuItem {
    RVTouchpoint *touchpoint = [[Rover shared].currentVisit.touchpoints objectAtIndex:menuItem.tag];
    [self presentModalForTouchpoint:touchpoint];
}

#pragma mark - Helpers

- (RXMenuItem *)menuItemForTouchpoint:(RVTouchpoint *)touchpoint {
    RXMenuItem *menuItem = [self.menuItemsDictionary objectForKey:touchpoint.ID];
    if (!menuItem) {
        menuItem = [RXMenuItem new];
        
        RVVisit *visit = [Rover shared].currentVisit;
        
        [menuItem setTag:[visit.touchpoints indexOfObject:touchpoint]];
        [menuItem setTitle:touchpoint.title forState:UIControlStateNormal];
        [menuItem sd_setBackgroundImageWithURL:touchpoint.avatarURL forState:UIControlStateNormal];
        [menuItem addTarget:self action:@selector(menuItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuItemsDictionary setObject:menuItem forKey:touchpoint.ID];
    }
    return menuItem;
}

- (void)presentModalForTouchpoint:(RVTouchpoint *)touchpoint {
    _openedTouchpoint = touchpoint;
    [self.recallMenu collapse:self.recallMenu.isVisible completion:^{
        [self.recallMenu hide:self.recallMenu.isVisible completion:^{
            if (touchpoint) {
                [[Rover shared] presentModalWithTouchpoints:@[touchpoint]];
            }
        }];
    }];
}

@end
