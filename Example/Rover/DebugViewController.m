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
@property (nonatomic, strong) UIView *instoreHeaderView;

@end

@implementation DebugViewController

- (void)viewDidLoad {
    self.logItems = [[NSMutableArray alloc] initWithCapacity:100];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // In-Store header
    UILabel *instoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
    instoreLabel.text = @"Currently Visiting";
    instoreLabel.backgroundColor = [UIColor grayColor];
    instoreLabel.textColor = [UIColor whiteColor];
    instoreLabel.textAlignment = NSTextAlignmentCenter;
    instoreLabel.font = [UIFont boldSystemFontOfSize:14];
    _instoreHeaderView = instoreLabel;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roverDidPostNotification:) name:nil object:[Rover class]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleHeaderIfNecessary) name:kRoverDidEnterLocationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleHeaderIfNecessary) name:UIApplicationDidBecomeActiveNotification object:nil];
    

}


//- (void)viewDidAppear:(BOOL)animated {
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    CGRect screenFrame = [UIScreen mainScreen].bounds;
//    window.bounds = CGRectMake(0, -20, screenFrame.size.width, screenFrame.size.height - 40);
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -140, screenFrame.size.width, 140)];
//    view.backgroundColor = [UIColor redColor];
//    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicked)]];
//    [window addSubview:view];
//}
//
//- (void)clicked {
//    NSLog(@"Clicked the top bar");
//}

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
            self.beaconCountLabel.textColor = [UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1.0];
        } else {
            self.beaconCountLabel.textColor = [UIColor colorWithRed:26.0/255.0 green:188.0/255.0 blue:156.0/255.0 alpha:1.0];
        }
    } else {
        [self addLogItem:[note.userInfo objectForKey:@"description"]];
        NSLog(@"%@", [note.userInfo objectForKey:@"description"]);
    }
}

- (void)toggleHeaderIfNecessary {
    if ([Rover shared].currentVisit) {
        self.tableView.tableHeaderView = _instoreHeaderView;
    } else {
        self.tableView.tableHeaderView = nil;
    }
}

- (IBAction)simulateButtonPressed:(id)sender {
    NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:@"D68807C4-486E-4615-84C0-60A03FD0FD25"];
    [[Rover shared] simulateBeaconWithUUID:UUID major:52643 minor:19039];
}

@end