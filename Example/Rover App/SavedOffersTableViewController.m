//
//  OffersTableViewController.m
//  Rover App
//
//  Created by Sean Rucker on 2014-09-11.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "SavedOffersTableViewController.h"
#import <Rover/Rover.h>

@interface SavedOffersTableViewController ()

@property (strong, nonatomic) NSArray *cards;

@end

@implementation SavedOffersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadCards) forControlEvents:UIControlEventValueChanged];
    
    [self.refreshControl beginRefreshing];
    [self reloadCards];
}

- (void)reloadCards {
    [Rover getCards:^(NSArray *cards, NSString *error) {
        self.cards = cards;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    RVCard *card = [self.cards objectAtIndex:indexPath.row];
    cell.textLabel.text = card.shortDescription;
    cell.detailTextLabel.text = card.organizationTitle;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RVCard *card = [self.cards objectAtIndex:indexPath.row];
    RVCardViewController *viewController = [RVCardViewController new];
    viewController.card = card;
    [self presentViewController:viewController animated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"show"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RVCard *card = self.cards[indexPath.row];
        RVCardViewController *viewController = (RVCardViewController *)segue.destinationViewController;
        viewController.card = card;
    }
}

@end
