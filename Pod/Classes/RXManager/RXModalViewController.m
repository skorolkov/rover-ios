//
//  RXModalViewController.m
//  Pods
//
//  Created by Ata Namvari on 2015-01-12.
//
//

#import "RXModalViewController.h"
#import "RVImageEffects.h"
#import "Rover.h"
#import "RXCardViewCell.h"

@interface RXModalViewController ()

@property (weak, nonatomic) RVVisit *visit;

@end

@implementation RXModalViewController

static NSString *cellReuseIdentifier = @"roverCardReuseIdentifier";
static NSInteger maxIndexPathSection = 0;
static NSInteger maxIndexPathRow = 0;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.backdropBlurRadius = [Rover shared].config.modalBackdropBlurRadius;
        self.backdropTintColor = [Rover shared].config.modalBackdropTintColor;
        // Account for status bar
        [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[RXCardViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
    
    [self createBlur];
    
    self.visit = [[Rover shared] currentVisit];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roverDidEnterTouchpoint) name:kRoverDidEnterTouchpointNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:@"647086E7-89A6-439C-9E3B-4A2268F13FC6"];
        [[Rover shared] simulateBeaconWithUUID:UUID major:52643 minor:2];
    });
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createBlur {
    UIViewController* rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIView *view = rootViewController.view;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = [RVImageEffects applyBlurWithRadius:self.backdropBlurRadius tintColor:self.backdropTintColor saturationDeltaFactor:1 maskImage:nil toImage:image];
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:image]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of visited touchpoints.
    return self.visit.visitedTouchpoints.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of cards in the touchpoint.
    // return self.visit.visitedTouchpoints[section].cards.count;
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[RXCardViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 220;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    static BOOL hasDisplayedInitialAnimation = NO;
    
    if ([self hasDisplayedCellAtIndexPath:indexPath] && hasDisplayedInitialAnimation) {
        return;
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        cell.alpha = 0;
        cell.transform = CGAffineTransformMakeScale(0.3, 0.3);
        
        [UIView animateWithDuration:0.7
                              delay:0
             usingSpringWithDamping:0.7
              initialSpringVelocity:.1
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cell.transform = CGAffineTransformIdentity;
                             cell.alpha = 1;
                         } completion:^(BOOL finished) {
                             hasDisplayedInitialAnimation = YES;
                         }];
        return;
    }
    
    if (!hasDisplayedInitialAnimation) {

        NSInteger cellIndex = (indexPath.section * [self tableView:tableView numberOfRowsInSection:indexPath.section]) + indexPath.row;
        cell.transform = CGAffineTransformMakeTranslation(0, self.tableView.frame.size.height - [self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
        [UIView animateWithDuration:0.7
                              delay:0.8 + cellIndex * (0.2)
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cell.transform = CGAffineTransformIdentity;

                         } completion:nil];
    }
    
    
    if (![self isEnoughOfCellVisible:cell inScrollView:self.tableView]) {
        cell.alpha = 0.6;
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray* cells = self.tableView.visibleCells;
    
    NSUInteger cellCount = [cells count];
    if (cellCount == 0)
        return;
    
    // Check against the maximum index path
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[cells lastObject]];
    if ([self hasDisplayedCellAtIndexPath:indexPath])
        return;
    
//    // Check the visibility of the first cell
//    [self checkVisibilityOfCell:[cells firstObject] inScrollView:scrollView];
//    if (cellCount == 1)
//        return;
//    
//    // Check the visibility of the last cell
//    [self checkVisibilityOfCell:[cells lastObject] inScrollView:scrollView];
//    if (cellCount == 2)
//        return;
    
    // All of the rest of the cells are visible: Loop through the 2nd through n-1 cells
    for (NSUInteger i = 0; i < cellCount; i++)
        [self checkVisibilityOfCell:cells[i] inScrollView:scrollView];
}

- (void)checkVisibilityOfCell:(UITableViewCell *)cell inScrollView:(UIScrollView *)scrollView
{
    if ([self isEnoughOfCellVisible:cell inScrollView:scrollView]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cell.alpha = 1;
                         } completion:^(BOOL finished) {
                             maxIndexPathRow = indexPath.row;
                             maxIndexPathSection = indexPath.section;
                         }];
    }
}

- (BOOL)isEnoughOfCellVisible:(UITableViewCell *)cell inScrollView:(UIScrollView *)scrollView
{
    CGRect cellRect = [scrollView convertRect:cell.frame toView:scrollView.superview];
    return CGRectContainsRect(scrollView.frame, cellRect);
}

- (BOOL)hasDisplayedCellAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section < maxIndexPathSection || (indexPath.section == maxIndexPathSection && indexPath.row <= maxIndexPathRow));
}

- (void)roverDidEnterTouchpoint
{
    self.visit = [[Rover shared] currentVisit];
    NSLog(@"touchpoints: %@", self.visit.visitedTouchpoints);
    // get smarter
    maxIndexPathSection++;
    
    
    CGPoint originalOffset = self.tableView.contentOffset;
    //[self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
    NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:0];
    CGFloat yOffset = 0;
    for (int i=0; i<rows; i++) {
        yOffset += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView setContentOffset:CGPointMake(originalOffset.x, originalOffset.y + yOffset) animated:NO];
}

@end
