//
//  ViewController.m
//  Rover App
//
//  Created by Sean Rucker on 2014-07-15.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "DebugViewController.h"
#import <Rover/Rover.h>


@interface Rover ()

@property (nonatomic, strong) RVVisitManager *visitManager;

@end

@interface DebugViewController ()

@end

@implementation DebugViewController

- (void)viewDidLoad {


}

- (IBAction)simulateButtonPressed:(id)sender {
    NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:@"7931D3AA-299B-4A12-9FCC-D66F2C5D2462"];
    [[Rover shared] simulateBeaconWithUUID:UUID major:18347 minor:48847 duration:60];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[Rover shared] simulateBeaconWithUUID:UUID major:18347 minor:62298 duration:12];
//    });
}

- (IBAction)showModalPressed:(id)sender {
    //[[Rover shared] presentModalWithTouchpoints:[Rover shared].currentVisit.visitedTouchpoints];
    NSLog(@" - - - BeaconRegions: %@", [Rover shared].visitManager.regionManager.monitoredRegions);
    
    NSLog(@" - - - GeofenceRegions: %@", [Rover shared].visitManager.circularRegionManager.monitoredRegions);
}

@end