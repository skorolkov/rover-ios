//
//  RVRetailExperienceManager.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import "RVRetailExperience.h"

@implementation RVRetailExperience

#pragma mark - RVExperienceManager

- (void)roverVisit:(RVVisit *)visit didEnterTouchpoints:(NSArray *)touchpoints {
    
    // Current Modal Update
    if ([[Rover shared].modalViewController isKindOfClass:[RXVisitViewController class]]) {
        RXVisitViewController *visitViewController = (RXVisitViewController *)[Rover shared].modalViewController;
        
        NSMutableArray *touchpointsDifference = [NSMutableArray arrayWithArray:touchpoints];
        [touchpointsDifference removeObjectsInArray:visitViewController.touchpoints];
        
        NSMutableArray *touchpointsWithCards = [[touchpointsDifference filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVTouchpoint *touchpoint, NSDictionary *bindings) {
            return touchpoint.cards.count > 0;
        }]] mutableCopy];
        
        if (touchpointsWithCards.count > 0) {
            [visitViewController addTouchpoints:touchpointsWithCards];
        }
    }
    
    
    [touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {

        // Modal / Notification
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            
            if (!touchpoint.notificationDelivered ) {
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];
                
                if (![currentViewController isKindOfClass:[[Rover shared] configValueForKey:@"modalViewControllerClass"]] && ![currentViewController isKindOfClass:[RXDetailViewController class]]) {
                    [self presentModalForVisit:visit];
                }
            }
            
        } else if (!touchpoint.notificationDelivered) {
            
            if (touchpoint.notification) {
                [[Rover shared] presentLocalNotification:touchpoint.notification];
            }
            
        }
        
        touchpoint.notificationDelivered = YES;
    }];
}

- (void)applicationDidBecomeActiveDuringVisit:(RVVisit *)visit {
    // Auto Modal
    if (visit.visitedTouchpoints.count > 0) {
        
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];
        
        if ([currentViewController isKindOfClass:[RXDetailViewController class]]) {
            [currentViewController dismissViewControllerAnimated:YES completion:nil];
        } else if (![currentViewController isKindOfClass:[[Rover shared] configValueForKey:@"modalViewControllerClass"]]) {
            
            [self presentModalForVisit:visit];
        }
    }
}

#pragma mark - Helper

- (void)presentModalForVisit:(RVVisit *)visit {
    
    [[Rover shared] presentModalWithTouchpoints:[[visit.visitedTouchpoints reverseObjectEnumerator] allObjects]];
}

@end
