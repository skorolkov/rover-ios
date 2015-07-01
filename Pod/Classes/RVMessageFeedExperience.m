//
//  RVRetailExperienceManager.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import "RVMessageFeedExperience.h"
#import "Rover.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RVMessageFeedExperience ()

@property (nonatomic, strong) RXRecallButton *recallButton;
@property (nonatomic, strong) RXModalTransition *modalTransitionManager;

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
    [_recallButton addTarget:self action:@selector(draggableViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [avatarImageView sd_setImageWithURL:[Rover shared].currentVisit.organization.avatarURL];
    
    return _recallButton;
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
    } else {
        // Otherwise if the modal is not open show the recall button
        if (!self.recallButton.isVisible) {
            [self.recallButton show:YES completion:nil];
        }
    }
    
    
    [touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {

        // If the app is in not in the foreground present local notification
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            // Do Nothing
        } else if (!touchpoint.notificationDelivered) {
            
            if (touchpoint.notification) {
                [[Rover shared] presentLocalNotification:touchpoint.notification userInfo:@{@"visitID": visit.ID}];
            }
            
        }
        
        // Mark the touchpoint as visited, so we only send notifications once per touchpoint
        touchpoint.notificationDelivered = YES;
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
    [self.recallButton show:YES completion:nil];
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
        [self.recallButton show:YES completion:nil];
    }
}

#pragma mark - RXDraggableViewDelegate

- (void)draggableViewClicked:(RXDraggableView *)draggableView {
    [self.recallButton hide:YES completion:^{
        [self presentModalForVisit:[Rover shared].currentVisit];
    }];
}

#pragma mark - Helper

- (void)presentModalForVisit:(RVVisit *)visit {
    [self.recallButton hide:self.recallButton.isVisible completion:^{
        [[Rover shared] presentModalWithTouchpoints:visit.visitedTouchpoints];
    }];
}



@end
