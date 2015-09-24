//
//  RXFixedViewController.m
//  Pods
//
//  Created by Ata Namvari on 2015-07-20.
//
//

#import "RXFixedViewController.h"

@interface RXFixedViewController ()

@end

@implementation RXFixedViewController

#pragma mark - Orientation

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
