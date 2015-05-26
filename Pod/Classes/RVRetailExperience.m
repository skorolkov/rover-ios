//
//  RVRetailExperienceManager.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import "RVRetailExperience.h"
#import "Rover.h"

#import "RXDraggableView.h"
#import "RXCardsIcon.h"

@interface RVRetailExperience () {
    CGPoint _lastPosition;
}

@property (nonatomic, strong) RXDraggableView *draggableView;

@end

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


/// CHATHEAD STUFF

- (RXDraggableView *)draggableView {
    if (_draggableView) {
        return _draggableView;
    }
    
    UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
    
    CGPoint initialPosition = CGPointMake(currentWindow.frame.size.width - (64/2) - 30, currentWindow.frame.size.height - (64/2) - 30);
    
    _draggableView = [[RXDraggableView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    _draggableView.center = CGPointMake(currentWindow.frame.size.width + 62, initialPosition.y);
    _draggableView.backgroundColor = [UIColor whiteColor];
    _draggableView.layer.cornerRadius = 32;
    _draggableView.layer.shadowColor = [UIColor blackColor].CGColor;
    _draggableView.layer.shadowOffset = CGSizeMake(0, 2);
    _draggableView.layer.shadowOpacity = .5;
    _draggableView.layer.shadowRadius = 4;
    _draggableView.delegate = self;
    
    RXCardsIcon *cardsIcon = [[RXCardsIcon alloc] initWithFrame:CGRectMake(12, 12, 38, 38)];
    [_draggableView addSubview:cardsIcon];
    
    
    _lastPosition = initialPosition;
    
    
    return _draggableView;
}

- (void)roverDidDismissModalViewController {
    UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (!self.draggableView.superview) {
        [currentWindow addSubview:self.draggableView];
    }
    
    [UIView animateWithDuration:.3
                     animations:^{
                         self.draggableView.center = _lastPosition;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)roverVisitDidExpire:(RVVisit *)visit {
    UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (!self.draggableView.superview) {
        [currentWindow addSubview:self.draggableView];
    }
    
    [UIView animateWithDuration:.3
                     animations:^{
                         self.draggableView.center = _lastPosition;
                     }
                     completion:^(BOOL finished) {
                         [self.draggableView removeFromSuperview];
                     }];
}

- (void)draggableViewClicked:(RXDraggableView *)draggableView {
    _lastPosition = self.draggableView.center;
    
    [UIView animateWithDuration:.3
                     animations:^{
                         self.draggableView.center = CGPointMake(self.draggableView.anchoredEdge == RXDraggableEdgeRight ? self.draggableView.superview.frame.size.width + 62 : - 62,self.draggableView.center.y);
                     }
                     completion:^(BOOL finished) {
                         
                         [self presentModalForVisit:[Rover shared].currentVisit];
                     }];
    
}

@end
