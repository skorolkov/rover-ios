//
//  RXVisitViewController.m
//  Pods
//
//  Created by Ata Namvari on 2015-02-25.
//
//

#import "RXVisitViewController.h"
#import "RXCardViewCell.h"
#import "RXDetailViewController.h"
#import "RVCard.h"
#import "RVDeck.h"
#import "RVViewDefinition.h"
#import "RVVisit.h"

#define kCardViewAreaThreshold .5

@interface RXVisitViewController () <RXCardViewCellDelegate, RXDetailViewControllerDelegate>

@end

@implementation RXVisitViewController

static NSString *cellReuseIdentifier = @"roverCardReuseIdentifier";

// BUG: footer is over everything

- (instancetype)init
{
    self = [super init];
    if (self) {
        _decks = [NSMutableArray array];
        
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
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableView.delaysContentTouches = NO;
        self.tableView.opaque = NO;
        [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
        [self.tableView setContentOffset:CGPointMake(0, -20)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[RXCardViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
    
    
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if ([self.delegate respondsToSelector:@selector(visitViewControllerWillGetDismissed:)]) {
        [self.delegate visitViewControllerWillGetDismissed:self];
    }
    [super dismissViewControllerAnimated:flag completion:^{
        if ([self.delegate respondsToSelector:@selector(visitViewControllerDidGetDismissed:)]) {
            [self.delegate visitViewControllerDidGetDismissed:self];
        }
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Helper Methods

- (RVCard *)cardAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.decks.count) {
        return nil;
    }
    RVDeck *deck = self.decks[indexPath.section];
    NSArray *nonDeletedCards = [self nonDeletedCardsFromCardsArray:deck.cards];
    if (indexPath.row < nonDeletedCards.count) {
        RVCard *card = [self nonDeletedCardsFromCardsArray:deck.cards][indexPath.row];
        return card;
    }
    return nil;
}

- (NSArray *)nonDeletedCardsFromCardsArray:(NSArray *)cards {
    return [cards filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isDeleted = NO"]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.decks.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section >= self.decks.count) {
        return 0;
    }
    return [self nonDeletedCardsFromCardsArray:((RVDeck *)self.decks[section]).cards].count;
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
            
            if ([self.delegate respondsToSelector:@selector(visitViewController:didDisplayCard:)]) {
                [self.delegate visitViewController:self didDisplayCard:card];
            }
        }
    }
}

#pragma mark - RXCardViewCellDelegate

- (void)cardViewCellDidSwipe:(RXCardViewCell *)cardViewCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cardViewCell];
    RVCard *card = [self cardAtIndexPath:indexPath];
    card.isDeleted = YES;
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if ([self.delegate respondsToSelector:@selector(visitViewController:didDiscardCard:)]) {
        [self.delegate visitViewController:self didDiscardCard:card];
    }
    
    if ([self hasNoCards]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)cardViewCell:(RXCardViewCell *)cell shouldOpenURL:(NSURL *)url {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    RVCard *card = [self cardAtIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(visitViewController:didClickCard:URL:)]) {
        [self.delegate visitViewController:self didClickCard:card URL:url];
    }
    
    if ([url.scheme isEqualToString:@"rover"]) {
        if ([url.host isEqualToString:@"view"] && url.path.length > 1) {
            NSString *viewID = [url.path substringFromIndex:1];
            [card.viewDefinitions enumerateObjectsUsingBlock:^(RVViewDefinition *viewDef, NSUInteger idx, BOOL *stop) {
                if ([viewDef.ID isEqualToString:viewID]) {
                    RXDetailViewController *detailViewController = [[RXDetailViewController alloc] initWithViewDefinition:viewDef];
                    detailViewController.delegate = self;
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

#pragma mark - RXDetailViewControllerDelegate

- (BOOL)detailViewController:(RXDetailViewController *)detailViewController shouldOpenURL:(NSURL *)url {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    RVCard *card = [self cardAtIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(visitViewController:didClickCard:URL:)]) {
        [self.delegate visitViewController:self didClickCard:card URL:url];
    }
    
    // NOTE: currently rover:// links are not supported in the detail view
    
    return YES;
}

- (void)addDecks:(NSArray *)decks {
    [self willAddDecks:decks];
    [_decks insertObjects:decks atIndexes:[NSIndexSet indexSetWithIndex:0]];
    [self didAddDecks:decks];

}

- (void)removeDecks:(NSArray *)decks {
    [self willRemoveDecks:decks];
    [self.tableView beginUpdates];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [decks enumerateObjectsUsingBlock:^(RVDeck *deck, NSUInteger idx, BOOL *stop) {
        [indexSet addIndex:[_decks indexOfObject:decks]];
    }];
    
    [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [_decks removeObjectsInArray:decks];
    [self.tableView endUpdates];
    [self didRemoveDecks:decks];
}

#pragma mark - Event Hooks

// Implement in subclass
- (void)willAddDecks:(NSArray *)decks {}
- (void)didAddDecks:(NSArray *)decks {
    
    __block CGFloat yOffset = self.tableView.contentOffset.y;
    
    [decks enumerateObjectsUsingBlock:^(RVDeck *deck, NSUInteger idx, BOOL *stop) {
        NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:idx];
        for (int i=0; i<rows; i++) {
            yOffset += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:idx]];
        }
    }];
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
}
- (void)willRemoveDecks:(NSArray *)decks {}
- (void)didRemoveDecks:(NSArray *)decks {
    [self.tableView reloadData];
}

- (BOOL)hasNoCards {
    for (RVDeck *deck in self.decks) {
        if ([self nonDeletedCardsFromCardsArray:deck.cards].count > 0) {
            return NO;
        }
    }
    return YES;
}

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
