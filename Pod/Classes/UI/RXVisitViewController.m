//
//  RXVisitViewController.m
//  Pods
//
//  Created by Ata Namvari on 2015-02-25.
//
//

#import "RXVisitViewController.h"
//#import "RVVisitController.h"
#import "RXCardViewCell.h"
#import "RXDetailViewController.h"
#import "RVCard.h"
#import "RVTouchpoint.h"
#import "RVViewDefinition.h"
#import "RVVisit.h"

#define kCardViewAreaThreshold .5

NSString *const kRoverWillDismissModalNotification = @"RoverWillDismissModalNotification";
NSString *const kRoverDidDismissModalNotification = @"RoverDidDismissModalNotification";

NSString *const kRoverDidDisplayCardNotification = @"RoverDidDisplayCardNotification";
NSString *const kRoverDidSwipeCardNotification = @"RoverDidSwipeCardNotification";
NSString *const kRoverDidClickCardNotification = @"RoverDidClickCardNotification";

@interface RXVisitViewController () <RXCardViewCellDelegate>


@end

@implementation RXVisitViewController

static NSString *cellReuseIdentifier = @"roverCardReuseIdentifier";

// BUG: footer is over everything

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Add tableView
        _tableView = [[UITableView alloc] init];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor  = [UIColor clearColor];
        [self.view addSubview:_tableView];
        NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_tableView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:views]];
        
        // Account for status bar
        [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
        self.tableView.delaysContentTouches = NO;
        self.tableView.opaque = NO;
        
        NSLog(@"init");
    }
    return self;
}

//- (void)dealloc {
//    _visitController = nil; // to call its dealloc method
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[RXCardViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverWillDismissModalNotification object:nil];
    [super dismissViewControllerAnimated:flag completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidDismissModalNotification object:nil];
        if (completion) {
            completion();
        }
    }];
}

//#pragma mark - Private Properties
//
//- (RVVisitController *)visitController {
//    if (_visitController) {
//        return _visitController;
//    }
//    
//    _visitController = [[RVVisitController alloc] init];
//    _visitController.delegate = self;
//    
//    return _visitController;
//}

#pragma mark - Helper Methods

- (RVCard *)cardAtIndexPath:(NSIndexPath *)indexPath {
    RVTouchpoint *touchpoint = self.touchpoints[indexPath.section];
    RVCard *card = [self nonDeletedCardsFromCardsArray:touchpoint.cards][indexPath.row];
    return card;
}

- (NSArray *)nonDeletedCardsFromCardsArray:(NSArray *)cards {
    return [cards filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isDeleted = NO"]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.touchpoints.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self nonDeletedCardsFromCardsArray:((RVTouchpoint *)self.touchpoints[section]).cards].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self cardAtIndexPath:indexPath] listViewHeightForWidth:self.view.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RXCardViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[RXCardViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(RXCardViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell setViewDefinition:[self cardAtIndexPath:indexPath].listView];
    cell.delegate = self;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView markCellAsViewedIfNeeded:cell atIndexPath:indexPath];
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(UITableViewCell *cell, NSUInteger idx, BOOL *stop) {
        [self tableView:(UITableView *)scrollView markCellAsViewedIfNeeded:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }];
}

- (void)tableView:(UITableView *)tableView markCellAsViewedIfNeeded:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RVCard *card = [self cardAtIndexPath:indexPath];
    if (!card.isViewed) {
        CGRect cellRect = [tableView convertRect:cell.frame toView:tableView.superview];
        CGRect intersection = CGRectIntersection(tableView.frame, cellRect);
        CGFloat percentageInView = intersection.size.height / cellRect.size.height;
        if (percentageInView > kCardViewAreaThreshold) {
            card.isViewed = YES;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidDisplayCardNotification object:nil userInfo:@{ @"card": card}];
        }
    }
}

#pragma mark - RXCardViewCellDelegate

- (void)cardViewCellDidSwipe:(RXCardViewCell *)cardViewCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cardViewCell];
    RVCard *card = [self cardAtIndexPath:indexPath];
    card.isDeleted = YES;
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if ([self hasNoCards]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidSwipeCardNotification object:nil userInfo:@{ @"card": card}];
}

- (BOOL)cardViewCell:(RXCardViewCell *)cell shouldOpenURL:(NSURL *)url {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    RVCard *card = [self cardAtIndexPath:indexPath];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRoverDidClickCardNotification object:nil userInfo:@{ @"card": card, @"url": url}];
    
    if ([url.scheme isEqualToString:@"rover"]) {
        if ([url.host isEqualToString:@"view"] && url.path.length > 1) {
            NSString *viewID = [url.path substringFromIndex:1];
            [card.viewDefinitions enumerateObjectsUsingBlock:^(RVViewDefinition *viewDef, NSUInteger idx, BOOL *stop) {
                if ([viewDef.ID isEqualToString:viewID]) {
                    RXDetailViewController *detailViewController = [[RXDetailViewController alloc] initWithViewDefinition:viewDef];
                    [self presentViewController:detailViewController animated:YES completion:nil];
                    *stop = YES;
                }
            }];
        }
        return NO;
    } else {
        return YES;
    }
}


- (void)addTouchpoint:(RVTouchpoint *)touchpoint {

    [self willAddTouchpoint:touchpoint];
    

    
    [self didAddTouchpoint:touchpoint];

}

#pragma mark - Event Hooks

// Implement in subclass
- (void)willAddTouchpoint:(RVTouchpoint *)touchpoint {}
- (void)didAddTouchpoint:(RVTouchpoint *)touchpoint {
    //[self.visitedTouchpoints insertObject:touchpoint atIndex:0];
    
    NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:0];
    CGFloat yOffset = self.tableView.contentOffset.y;
    for (int i=0; i<rows; i++) {
        yOffset += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
}

- (BOOL)hasNoCards {
    for (RVTouchpoint *touchpoint in self.touchpoints) {
        if ([self nonDeletedCardsFromCardsArray:touchpoint.cards].count > 0) {
            return NO;
        }
    }
    return YES;
}

@end
