//
//  RVSimpleExperience.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import "RVSimpleExperience.h"
#import "Rover.h"

@interface RVSimpleExperience () <UIActionSheetDelegate>

@property (nonatomic, strong) RXRecallMenu *recallMenu;
@property (nonatomic, strong) NSMutableDictionary *menuItemsDictionary;

@end

@implementation RVSimpleExperience

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.recallMenu = [[RXRecallMenu alloc] init];
        self.menuItemsDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - RoverDelegate

- (void)roverVisit:(RVVisit *)visit didEnterTouchpoints:(NSArray *)touchpoints {
    
    // If app is in the foreground present the recall button
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        //if (!self.recallMenu.isVisible) {
        //}
        
        
        [self.recallMenu show:YES completion:nil];
        
        for (RVTouchpoint *touchpoint in touchpoints) {
            RXMenuItem *menuItem = [self menuItemWithIdentifier:touchpoint.ID];
            [menuItem setTitle:touchpoint.title forState:UIControlStateNormal];
            [self.recallMenu addItem:menuItem animated:YES];
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

- (void)roverVisit:(RVVisit *)visit didExitTouchpoints:(NSArray *)touchpoints {
    for (RVTouchpoint *touchpoint in touchpoints) {
        RXMenuItem *menuItem = [self menuItemWithIdentifier:touchpoint.ID];
        [self.recallMenu removeItem:menuItem animated:YES];
    }
}

- (void)roverDidDismissModalViewController {
    [self.recallMenu show:YES completion:nil];
}

- (void)roverVisitDidExpire:(RVVisit *)visit {
    [self.recallMenu hide:YES completion:nil];
}

- (void)didOpenApplicationDuringVisit:(RVVisit *)visit {
    //if (!self.recallButton.isVisible && ![Rover shared].modalViewController) {
    //    [self.recallButton show:YES completion:nil];
    //}
}

#pragma mark - Helper

- (RXMenuItem *)menuItemWithIdentifier:(NSString *)identifier {
    RXMenuItem *menuItem = [self.menuItemsDictionary objectForKey:identifier];
    if (!menuItem) {
        menuItem = [RXMenuItem new];
        [self.menuItemsDictionary setObject:menuItem forKey:identifier];
    }
    return menuItem;
}

@end
