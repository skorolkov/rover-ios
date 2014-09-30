//
//  RonaViewController.m
//  Rover App
//
//  Created by Sean Rucker on 2014-08-18.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RonaViewController.h"
#import <Rover/Rover.h>

@interface RonaViewController ()

@end

@implementation RonaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:@"6C21D507-C7F7-42C5-BA24-ADF3010BC612"];
    [Rover simulateBeaconWithUUID:UUID major:1];
}

@end
