//
//  RVRetailExperienceManager.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import "RVRetailExperience.h"
#import "Rover.h"

@implementation RVRetailExperience

#pragma mark - RoverDelegate

- (void)roverVisit:(RVVisit *)visit didEnterTouchpoints:(NSArray *)touchpoints {
    
    // Update the current modal view controller if it is present
    
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

        // If the app is in the foreground present modal, otherwise send a local notification
        
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
        
        // Mark the touchpoint as visited, so we only send notifications once per touchpoint
        
        touchpoint.notificationDelivered = YES;
    }];
}

- (void)applicationDidBecomeActiveDuringVisit:(RVVisit *)visit {
    // Auto Modal
    if (visit.visitedTouchpoints.count > 0) {
        
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];
        
        if ([currentViewController isKindOfClass:[RXDetailViewController class]]) {
            
            // If already in a Detail view, dismiss the view and go back to the card view
            
            [currentViewController dismissViewControllerAnimated:YES completion:nil];
        } else if (![currentViewController isKindOfClass:[[Rover shared] configValueForKey:@"modalViewControllerClass"]]) {
            
            // Present the card modal
            
            [self presentModalForVisit:visit];
        }
    }
}

#pragma mark - Helper

- (void)presentModalForVisit:(RVVisit *)visit {
    
    [[Rover shared] presentModalWithTouchpoints:[[visit.visitedTouchpoints reverseObjectEnumerator] allObjects]];
}

@end
