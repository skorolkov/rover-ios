//
//  ViewController.m
//  Rover App
//
//  Created by Sean Rucker on 2014-07-15.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "DebugViewController.h"
#import <Rover/Rover.h>

@interface DebugViewController ()

@property (nonatomic, strong) UIView *instoreHeaderView;

@end

@implementation DebugViewController

- (void)viewDidLoad {


}

- (IBAction)simulateButtonPressed:(id)sender {
    NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:@"7931D3AA-299B-4A12-9FCC-D66F2C5D2462"];
    [[Rover shared] simulateBeaconWithUUID:UUID major:18347 minor:23905];
}

@end