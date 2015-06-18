//
//  RVRetailExperienceManager.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import "RVRetailExperience.h"
#import "Rover.h"

@interface RVRetailExperience ()

@property (nonatomic, strong) RXRecallButton *recallButton;
@property (nonatomic, strong) RXModalTransition *modalTransitionManager;

@end

@implementation RVRetailExperience

- (instancetype)init {
    self = [super init];
    if (self) {
        self.recallButton = [RXRecallButton new];
        [self.recallButton addTarget:self action:@selector(draggableViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.modalTransitionManager = [RXModalTransition new];
    }
    return self;
}

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
                if (![Rover shared].modalViewController) {
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

- (void)didOpenApplicationDuringVisit:(RVVisit *)visit {
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

- (void)roverDidDismissModalViewController {
    [self.recallButton show:YES completion:nil];
}

- (void)roverVisitDidExpire:(RVVisit *)visit {
    [self.recallButton hide:YES completion:nil];
}

- (void)roverWillDisplayModalViewController:(UIViewController *)modalViewController {
    modalViewController.transitioningDelegate = self.modalTransitionManager;
}

#pragma mark - RXDraggableViewDelegate

- (void)draggableViewClicked:(RXDraggableView *)draggableView {
    [self.recallButton hide:YES completion:^{
        [self presentModalForVisit:[Rover shared].currentVisit];
    }];
}

#pragma mark - Helper

- (void)presentModalForVisit:(RVVisit *)visit {
    if (self.recallButton.isVisible) {
        return;
    }
    
    [[Rover shared] presentModalWithTouchpoints:[[visit.visitedTouchpoints reverseObjectEnumerator] allObjects]];
}



@end
