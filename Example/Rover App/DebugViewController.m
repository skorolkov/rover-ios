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

@property (strong, nonatomic) NSMutableArray *logItems;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *beaconCountLabel;

@end

@implementation DebugViewController

- (void)viewDidLoad {
    self.logItems = [[NSMutableArray alloc] initWithCapacity:100];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roverDidPostNotification:) name:nil object:[Rover class]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addLogItem:(NSString *)description {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *time = [formatter stringFromDate:[NSDate date]];
    
    if (self.logItems.count > 9) {
        NSArray *subArray = [self.logItems subarrayWithRange:NSMakeRange(1, 9)];
        self.logItems = [NSMutableArray arrayWithArray:subArray];
    }
    
    [self.logItems addObject:@{ @"time": time,
                                @"description": description }];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.logItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *logItem = [self.logItems objectAtIndex:indexPath.row];
    cell.textLabel.text = [logItem objectForKey:@"description"];
    cell.detailTextLabel.text = [logItem objectForKey:@"time"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Rover Notifications

- (void)roverDidPostNotification:(NSNotification *)note {
    
    if ([note.name isEqualToString:@"RoverDidRangeBeaconsNotification"]) {
        NSNumber *count = [note.userInfo objectForKey:@"count"];
        self.beaconCountLabel.text = [NSString stringWithFormat:@"%@", count];
        
        if ([count integerValue] < 1) {
            // 231, 76, 60
            self.beaconCountLabel.textColor = [UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1.0];
        } else {
            // 26, 188, 156
            self.beaconCountLabel.textColor = [UIColor colorWithRed:26.0/255.0 green:188.0/255.0 blue:156.0/255.0 alpha:1.0];
        }
    } else {
        [self addLogItem:[note.userInfo objectForKey:@"description"]];
        NSLog(@"%@", [note.userInfo objectForKey:@"description"]);
    }
}

- (IBAction)simulateButtonPressed:(id)sender
{
    NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:@"6C21D507-C7F7-42C5-BA24-ADF3010BC612"];
    [Rover simulateBeaconWithUUID:UUID major:54378];
}

@end