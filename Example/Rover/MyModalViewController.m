//
//  MyModalViewController.m
//  Rover
//
//  Created by Ata Namvari on 2015-04-20.
//  Copyright (c) 2015 Rover Labs Inc. All rights reserved.
//

#import "MyModalViewController.h"
#import <Rover/RXCardViewCell.h>

@interface MyModalViewController ()

@end

@implementation MyModalViewController

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView heightForRowAtIndexPath:indexPath] + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        RXCardViewCell *cardCell = (RXCardViewCell *)cell;
        
        UIView *tempView = [UIView new];
        tempView.translatesAutoresizingMaskIntoConstraints = NO;
        tempView.backgroundColor = [UIColor yellowColor];
        [tempView addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:20]];
        
        [cardCell addBlockView:tempView];
    }
    
    return cell;
}

@end
