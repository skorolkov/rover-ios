//
//  RVSimpleExperience.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import "RVSimpleExperience.h"
#import "Rover.h"

@implementation RVSimpleExperience

#pragma mark - RoverDelegate


- (void)roverVisit:(RVVisit *)visit didEnterTouchpoints:(NSArray *)touchpoints {
    
    // If the modal view controller is currently present, set and reload its content
    
    if ([[Rover shared].modalViewController isKindOfClass:[RXVisitViewController class]]) {
        RXVisitViewController *visitViewController = (RXVisitViewController *)[Rover shared].modalViewController;
        
        NSMutableArray *touchpointsDifference = [NSMutableArray arrayWithArray:touchpoints];
        [touchpointsDifference removeObjectsInArray:visitViewController.touchpoints];
        
        NSMutableArray *touchpointsWithCards = [[touchpointsDifference filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVTouchpoint *touchpoint, NSDictionary *bindings) {
            return touchpoint.cards.count > 0;
        }]] mutableCopy];
        
        if (touchpointsWithCards.count > 0) {
            [visitViewController setTouchpoints:touchpointsWithCards];
            [visitViewController.tableView reloadData];
        }
    }
    
    
    [touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {
        
        // If app is in the foreground present the modal
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];
            
            if (![currentViewController isKindOfClass:[[Rover shared] configValueForKey:@"modalViewControllerClass"]] && ![currentViewController isKindOfClass:[RXDetailViewController class]]) {
                [[Rover shared] presentModalWithTouchpoints:[visit.currentTouchpoints allObjects]];
            }

            
        } else if (!touchpoint.notificationDelivered) {
            
            // Send local notification
            
            if (touchpoint.notification) {
                [[Rover shared] presentLocalNotification:touchpoint.notification];
            }
            
        }
        
        // Mark the touchpoint as visited, so we only send notifications once per touchpoint
        
        touchpoint.notificationDelivered = YES;
    }];
}

- (void)roverVisit:(RVVisit *)visit didExitTouchpoints:(NSArray *)touchpoints {
    // Modal
    UIViewController *modalViewController = [Rover shared].modalViewController;
    
    if (modalViewController) {
        if ([modalViewController isKindOfClass:[RXVisitViewController class]]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                RXVisitViewController *visitModalViewController = (RXVisitViewController *)modalViewController;
                
                [visitModalViewController setTouchpoints:[[visit.currentTouchpoints allObjects] mutableCopy]];
                [visitModalViewController.tableView reloadData];
                
                if (visitModalViewController.touchpoints.count == 0) {
                    [visitModalViewController dismissViewControllerAnimated:YES completion:nil];
                }
            });
        }
    }
}


@end
