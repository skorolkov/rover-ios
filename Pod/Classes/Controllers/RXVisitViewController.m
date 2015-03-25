//
//  RXVisitViewController.m
//  Pods
//
//  Created by Ata Namvari on 2015-02-25.
//
//

#import "RXVisitViewController.h"
#import "RVVisitController.h"
#import "RXCardViewCell.h"
#import "RXDetailViewController.h"
#import "RVCard.h"
#import "RVViewDefinition.h"
#import "RVVisit.h"

@interface RXVisitViewController () <RVVisitControllerDelegate, RXCardViewCellDelegate>

@property (nonatomic, strong) RVVisitController *visitController;

@end

@implementation RXVisitViewController

static NSString *cellReuseIdentifier = @"roverCardReuseIdentifier";

// BUG: footer is over everything

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Account for status bar
        [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
        self.tableView.delaysContentTouches = NO;
    }
    return self;
}

- (void)dealloc {
    _visitController = nil; // to call its dealloc method
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[RXCardViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
}

#pragma mark - Private Properties

- (RVVisitController *)visitController {
    if (_visitController) {
        return _visitController;
    }
    
    _visitController = [[RVVisitController alloc] init];
    _visitController.delegate = self;
    
    return _visitController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.visitController.touchpoints.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <RVVisitTouchpointInfo> touchpointInfo = [self.visitController touchpoints][section];
    return [touchpointInfo numberOfCards];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.visitController cardAtIndexPath:indexPath] listViewHeightForWidth:self.view.frame.size.width];
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
    [cell setViewDefinition:[self.visitController cardAtIndexPath:indexPath].listView];
    cell.delegate = self;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RVCard *card = [self.visitController cardAtIndexPath:indexPath];
    if (!card.isViewed) {
        [self.visitController.visit trackEvent:@"card.view" params:@{@"card": card.ID}];
        card.isViewed = YES;
    }
    // should this be another delegate method to hide tableview?
//    if ([self.delegate respondsToSelector:@selector(willDisplayCell:forCardAtIndexPath:)]) {
//        [self.delegate willDisplayCell:(RXCardViewCell *)cell forCardAtIndexPath:indexPath];
//    }
}

#pragma mark - RXCardViewCellDelegate

- (void)cardViewCellDidSwipe:(RXCardViewCell *)cardViewCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cardViewCell];
    RVCard *card = [self.visitController cardAtIndexPath:indexPath];
    card.isDeleted = YES;
    [self.visitController.visit trackEvent:@"card.discard" params:@{@"card": card.ID}];
}

- (BOOL)cardViewCell:(RXCardViewCell *)cell shouldOpenURL:(NSURL *)url {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    RVCard *card = [self.visitController cardAtIndexPath:indexPath];
    [self.visitController.visit trackEvent:@"card.click" params:@{@"card": card.ID, @"url": url.absoluteString}];
    
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

#pragma mark - RVVisitControllerDelegate

- (void)controller:(RVVisitController *)controller didChangeTouchpoint:(id<RVVisitTouchpointInfo>)touchpointInfo atIndex:(NSUInteger)touchpointIndex forChangeType:(RVVisitChangeType)type {
    switch (type) {
        case RVVisitChangeInsert:
            
            [self willAddTouchpoint:self.visitController.touchpoints[touchpointIndex]];
            
            NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:0];
            CGFloat yOffset = self.tableView.contentOffset.y;
            for (int i=0; i<rows; i++) {
                yOffset += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            [self.tableView reloadData];
            [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
            
            [self didAddTouchpoint:self.visitController.touchpoints[touchpointIndex]];

            break;
            
        default:
            break;
    }
}

- (void)controller:(RVVisitController *)controller didChangeCard:(RVCard *)card atIndexPath:(NSIndexPath *)indexPath forChangeType:(RVVisitChangeType)type {
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if ([self hasNoCards]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Event Hooks

// Implement in subclass
- (void)willAddTouchpoint:(RVTouchpoint *)touchpoint {}
- (void)didAddTouchpoint:(RVTouchpoint *)touchpoint {}

- (BOOL)hasNoCards {
    for (id <RVVisitTouchpointInfo> touchpointInfo in self.visitController.touchpoints) {
        if ([touchpointInfo numberOfCards] > 0) {
            return NO;
        }
    }
    return YES;
}

@end
