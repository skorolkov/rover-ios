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
    
    // In-Store header
    UILabel *instoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 50)];
    instoreLabel.text = @"Currently Visiting";
    instoreLabel.backgroundColor = [UIColor grayColor];
    instoreLabel.textColor = [UIColor whiteColor];
    instoreLabel.textAlignment = NSTextAlignmentCenter;
    instoreLabel.font = [UIFont boldSystemFontOfSize:14];
    _instoreHeaderView = instoreLabel;
    _instoreHeaderView.hidden = YES;
    
    
    [self.view addSubview:_instoreHeaderView];
    
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleHeaderIfNecessary) name:kRoverDidEnterLocationNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleHeaderIfNecessary) name:UIApplicationDidBecomeActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleHeaderIfNecessary) name:kRoverDidExpireVisitNotification object:nil];
    

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)toggleHeaderIfNecessary {
    if ([Rover shared].currentVisit) {
        _instoreHeaderView.hidden = NO;
    } else {
        _instoreHeaderView.hidden = YES;
    }
}

- (IBAction)simulateButtonPressed:(id)sender {
    NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:@"7931D3AA-299B-4A12-9FCC-D66F2C5D2462"];
    [[Rover shared] simulateBeaconWithUUID:UUID major:18347 minor:23905];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[Rover shared] simulateBeaconWithUUID:UUID major:18347 minor:48847];
    });
}

@end