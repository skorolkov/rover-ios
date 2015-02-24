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
#import "RXCardViewController.h"
#import "RXTransition.h"
#import "RVTouchpoint.h"

@interface RXModalViewController () <RXCardViewCellDelegate> {
    BOOL _hasDisplayedInitialAnimation;
    NSInteger _maxIndexPathSection;
    NSInteger _maxIndexPathRow;
    NSInteger _minIndexPathSection;
    NSInteger _minIndexPathRow;
}

@property (readonly) RVVisit *visit;
@property (strong, nonatomic) UIButton *pillView;

@end

@implementation RXModalViewController

static NSString *cellReuseIdentifier = @"roverCardReuseIdentifier";

// BUG: animation only happens once

// BUG: footer is over everything

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.backdropBlurRadius = [Rover shared].config.modalBackdropBlurRadius;
        self.backdropTintColor = [Rover shared].config.modalBackdropTintColor;
        
        // Account for status bar
        [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
        
        // TODO: make this customizable through the SDK
        _pillView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _pillView.frame = CGRectMake(0, 0, 150, 60);
        [_pillView setTitle:@"New Offers" forState:UIControlStateNormal];
        [_pillView addTarget:self action:@selector(scrollToTop) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[RXCardViewCell class] forCellReuseIdentifier:cellReuseIdentifier];

    
    [self createBlur];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roverDidEnterTouchpoint) name:kRoverDidEnterTouchpointNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:@"647086E7-89A6-439C-9E3B-4A2268F13FC6"];
        [[Rover shared] simulateBeaconWithUUID:UUID major:54321 minor:236];
    });
    
}

- (void)viewDidAppear:(BOOL)animated {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 77)];
    footerView.backgroundColor = [UIColor clearColor];
    footerView.alpha = 0;
    
    UIButton *closeButton = [self closeButtonView];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton addTarget:self action:@selector(closeModal) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:closeButton];
    NSDictionary *views = NSDictionaryOfVariableBindings(closeButton);
    [footerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[closeButton]-15-|" options:0 metrics:nil views:views]];
    [footerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[closeButton(47)]-15-|" options:0 metrics:nil views:views]];
    
    [self.tableView setTableFooterView:footerView];
    
    [UIView animateWithDuration:.3 delay:.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        footerView.alpha = 1;
    } completion:nil];
}

- (UIButton *)closeButtonView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Close" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    button.layer.cornerRadius = 4;
    [button addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:0 attribute:0 multiplier:0 constant:47]];
    return button;
}

- (void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (RVVisit *)visit
{
    return [[Rover shared] currentVisit];
}

- (RVCard *)cardAtIndexPath:(NSIndexPath *)indexPath {
    return ((RVTouchpoint *)self.visit.visitedTouchpoints[indexPath.section]).cards[indexPath.row];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_pillView removeFromSuperview]; // To be safe
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
    NSLog(@"visited: %ld", self.visit.visitedTouchpoints.count);
    return self.visit.visitedTouchpoints.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((RVTouchpoint *)self.visit.visitedTouchpoints[section]).cards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RXCardViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[RXCardViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    cell.card = [self cardAtIndexPath:indexPath];
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self cardAtIndexPath:indexPath] heightForWidth:self.view.frame.size.width];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self hasDisplayedCellAtIndexPath:indexPath] && _hasDisplayedInitialAnimation) {
        return;
    }
    
    BOOL isNewCell = _hasDisplayedInitialAnimation && ![self hasDisplayedCellAtIndexPath:indexPath];
    
    if (indexPath.section == 0 && (indexPath.row == 0 || isNewCell)) {
        
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
                             _hasDisplayedInitialAnimation = YES;
                             _minIndexPathSection = 0;
                             _minIndexPathRow = indexPath.row;
                             if (_minIndexPathRow == 0 && _pillView.superview) {
                                 [self retractPill];
                             }
                         }];
        return;
    }
    
    if (!_hasDisplayedInitialAnimation) {

        NSInteger cellIndex = (indexPath.section * [self tableView:tableView numberOfRowsInSection:indexPath.section]) + indexPath.row;
        cell.transform = CGAffineTransformMakeTranslation(0, self.tableView.frame.size.height - [self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
        [UIView animateWithDuration:0.7
                              delay:(0 + (cellIndex * 0.2))
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cell.transform = CGAffineTransformIdentity;

                         } completion:nil];
    }
    
    
//    if (![self isEnoughOfCellVisible:cell inScrollView:self.tableView]) {
//        cell.alpha = 0.6;
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Select");
    RVCard *card = [self cardAtIndexPath:indexPath];
    RXCardViewController *cardViewController = [[RXCardViewController alloc] initWithCard:card];
    [self presentViewController:cardViewController animated:YES completion:nil];
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
                             _maxIndexPathRow = indexPath.row;
                             _maxIndexPathSection = indexPath.section;
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
    return ((indexPath.section < _maxIndexPathSection && indexPath.section > _minIndexPathSection) ||
            (indexPath.section == _maxIndexPathSection && indexPath.row <= _maxIndexPathRow) ||
            (indexPath.section == _minIndexPathSection && indexPath.row >= _minIndexPathRow));
}

- (void)roverDidEnterTouchpoint
{
    // get smarter
    _maxIndexPathSection++;
    _minIndexPathRow = [self tableView:self.tableView numberOfRowsInSection:0];
    _minIndexPathSection = 1;
    
    
    CGPoint originalOffset = self.tableView.contentOffset;
    //[self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
    NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:0];
    CGFloat yOffset = 0;
    for (int i=0; i<rows; i++) {
        yOffset += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView setContentOffset:CGPointMake(originalOffset.x, originalOffset.y + yOffset) animated:NO];
    [self dropPill];
}

- (void)dropPill
{
    _pillView.center = CGPointMake(self.tableView.center.x, -_pillView.frame.size.height/2);
    [self.tableView.superview addSubview:_pillView];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _pillView.center = CGPointMake(_pillView.center.x, _pillView.frame.size.height/2 + 20);
                     } completion:nil];
}

- (void)retractPill
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _pillView.center = CGPointMake(_pillView.center.x, -_pillView.frame.size.height/2);
                     } completion:^(BOOL finished) {
                         [_pillView removeFromSuperview];
                     }];
}

- (void)scrollToTop
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark - RXCardViewCellDelegate

- (void)cardViewCellDidSwipe:(RXCardViewCell *)cardViewCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cardViewCell];
   // numberOfCards--;
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
