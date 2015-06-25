//
//  RVSimpleExperience.m
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import "RVNearbyExperience.h"
#import "Rover.h"

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
        RXMenuItem *menuItem = [self menuItemWithIdentifier:touchpoint.ID];
        [menuItem setTag:[visit.touchpoints indexOfObject:touchpoint]];
        [menuItem setTitle:touchpoint.title forState:UIControlStateNormal];
        [menuItem addTarget:self action:@selector(menuItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.recallMenu addItem:menuItem animated:self.recallMenu.isVisible];
    }
    
    if (!self.recallMenu.isVisible && ![Rover shared].modalViewController) {
        [self.recallMenu show:YES completion:nil];
    }
    
    // If app is in the foreground present the recall button
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        // Do nothing
    } else {
        // Send local notification
        
        for (RVTouchpoint *touchpoint in touchpoints) {
            if (touchpoint.notification && !touchpoint.notificationDelivered) {
                [[Rover shared] presentLocalNotification:touchpoint.notification];
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
        RXMenuItem *menuItem = [self menuItemWithIdentifier:touchpoint.ID];
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

#pragma mark - Actions

- (void)menuItemClicked:(RXMenuItem *)menuItem {
    RVTouchpoint *touchpoint = [[Rover shared].currentVisit.touchpoints objectAtIndex:menuItem.tag];
    _openedTouchpoint = touchpoint;
    [self.recallMenu collapse:YES completion:^{
        [self.recallMenu hide:YES completion:^{
            [[Rover shared] presentModalWithTouchpoints:@[touchpoint]];
        }];
    }];
}

#pragma mark - Helper

- (RXMenuItem *)menuItemWithIdentifier:(NSString *)identifier {
    RXMenuItem *menuItem = [self.menuItemsDictionary objectForKey:identifier];
    if (!menuItem) {
        menuItem = [RXMenuItem new];
        
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        [menuItem setBackgroundColor:color];
        
        [self.menuItemsDictionary setObject:menuItem forKey:identifier];
    }
    return menuItem;
}

@end
