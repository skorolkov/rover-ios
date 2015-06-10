//
//  RVSimpleExperience.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import "RVSimpleExperience.h"
#import "Rover.h"

@interface RVSimpleExperience () <RXDraggableViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) RXRecallButton *recallButton;
@property (nonatomic, strong) UIActionSheet *touchpointsActionSheet;

@end

@implementation RVSimpleExperience

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.recallButton = [RXRecallButton new];
        self.recallButton.delegate = self;
    }
    return self;
}

#pragma mark - RoverDelegate

- (void)roverVisit:(RVVisit *)visit didEnterTouchpoints:(NSArray *)touchpoints {
    
    // If app is in the foreground present the recall button
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        if (!self.recallButton.isVisible && !_touchpointsActionSheet) {
            [self.recallButton show:YES completion:nil];
        }
        if (_touchpointsActionSheet) {
            [_touchpointsActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
            [self presentActionSheetForTouchpoints:[visit.currentTouchpoints allObjects]];
        }
    } else /*if (!touchpoint.notificationDelivered)*/ {
        
        // Send local notification
        
        for (RVTouchpoint *touchpoint in touchpoints) {
            if (touchpoint.notification) {
                [[Rover shared] presentLocalNotification:touchpoint.notification];
                touchpoint.notificationDelivered = YES;
            }
        }
    }
}

- (void)roverDidDismissModalViewController {
    [self.recallButton show:YES completion:nil];
}

- (void)roverVisitDidExpire:(RVVisit *)visit {
    [self.recallButton hide:YES completion:nil];
}

- (void)didOpenApplicationDuringVisit:(RVVisit *)visit {
    if (!self.recallButton.isVisible && !_touchpointsActionSheet && ![Rover shared].modalViewController) {
        [self.recallButton show:YES completion:nil];
    }
}

#pragma mark - RXDraggableViewDelegate

- (void)draggableViewClicked:(RXDraggableView *)draggableView {
    RVVisit *visit = [Rover shared].currentVisit;
    if (visit.currentTouchpoints.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rover" message:@"Not currently in any touchpoints" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self.recallButton hide:YES completion:^{
        [self presentActionSheetForTouchpoints:[visit.currentTouchpoints allObjects]];
    }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case -1:
            break;
        case 0:
            [self.recallButton show:YES completion:nil];
            break;
            
        default: {
            NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
            RVTouchpoint *touchpoint = [self touchpointWithTitle:title];
            [[Rover shared] presentModalWithTouchpoints:@[touchpoint]];
        }
            break;
    }
    _touchpointsActionSheet = nil;
}

#pragma mark - Helper

- (void)presentActionSheetForTouchpoints:(NSArray *)touchpoints {
    _touchpointsActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a current touchpoint to open:"
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:nil];
    for (RVTouchpoint *touchpoint in touchpoints) {
        [_touchpointsActionSheet addButtonWithTitle:touchpoint.title];
    }
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [_touchpointsActionSheet showInView:currentWindow];
}

- (RVTouchpoint *)touchpointWithTitle:(NSString *)title {
    __block RVTouchpoint *touchpoint;
    [[Rover shared].currentVisit.touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *tp, NSUInteger idx, BOOL *stop) {
        if ([tp.title isEqualToString:title]) {
            touchpoint = tp;
            *stop = YES;
        }
    }];
    return touchpoint;
}

@end
