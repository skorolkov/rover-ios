//
//  RXModalViewController.m
//  Pods
//
//  Created by Ata Namvari on 2015-01-12.
//
//

#import "RXModalViewController.h"
#import "RXImageEffects.h"
#import "RXCardViewCell.h"
#import "RVDeck.h"

#import "RXUpArrow.h"

#import "RVCard.h"

@interface RXModalViewController () {
    BOOL _hasDisplayedInitialAnimation;
    NSInteger _maxIndexPathSection;
    NSInteger _maxIndexPathRow;
    NSInteger _minIndexPathSection;
    NSInteger _minIndexPathRow;
}

@property (strong, nonatomic) UIButton *pillView;

@end

@implementation RXModalViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
//    self.backgroundImageView = [[UIImageView alloc] init];
//    _backgroundImageView.translatesAutoresizingMaskIntoConstraints  = NO;
//    _backgroundImageView.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:_backgroundImageView];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_backgroundImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundImageView)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundImageView)]];
//    
    //[self.view sendSubviewToBack:_backgroundImageView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createBlur];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.tableView.tableFooterView) {
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

- (void)dealloc {
    [_pillView removeFromSuperview]; // To be safe
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
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

                         }];
        return;
    }
    
    if (!_hasDisplayedInitialAnimation) {
        NSInteger numberOfRowsInFirstSection = [self tableView:tableView numberOfRowsInSection:0];
        CGFloat heightOffset = 0;
        if (numberOfRowsInFirstSection > 0) {
            heightOffset = [self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
        
        NSInteger cellIndex = (indexPath.section * [self tableView:tableView numberOfRowsInSection:indexPath.section]) + indexPath.row;
        cell.transform = CGAffineTransformMakeTranslation(0, self.tableView.frame.size.height - heightOffset);
        [UIView animateWithDuration:0.7
                              delay:(0 + (cellIndex * 0.2))
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cell.transform = CGAffineTransformIdentity;

                         } completion:nil];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    NSArray* cells = self.tableView.visibleCells;
    
    NSUInteger cellCount = [cells count];
    if (cellCount == 0)
        return;
    
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    RXCardViewCell *cell = [self.tableView cellForRowAtIndexPath:firstIndexPath];
    RVCard *card = [self cardAtIndexPath:firstIndexPath];
    
    if (_pillView.superview && card.isViewed) {
        [self retractPill];
    }
    
//    if (_minIndexPathRow == 0 && _minIndexPathSection ==0 && _pillView.superview) {
//        RVCard *card = [self cardAtIndexPath:[self.tableView indexPathForCell:cells[0]]];
//
//    }
    
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

#pragma mark - Utility Methods

- (void)createBlur {
//    UIViewController* rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//    UIView *view = nil;//rootViewController.view;
//    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
//    
//    UIView *snapshotView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
//    [view drawViewHierarchyInRect:[UIScreen mainScreen].bounds afterScreenUpdates:YES];
//    //[snapshotView drawViewHierarchyInRect:[UIScreen mainScreen].bounds afterScreenUpdates:YES];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

    UIImage *image = [self screenshot];
    
    image = [RXImageEffects applyBlurWithRadius:self.backdropBlurRadius tintColor:self.backdropTintColor saturationDeltaFactor:1 maskImage:nil toImage:image];

    _backgroundImageView = [[UIImageView alloc] initWithImage:image];
    _backgroundImageView.alpha = 0;
    
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
        _backgroundImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        CGRect frame = _backgroundImageView.frame;
        frame.origin = CGPointMake(0, 0);
        _backgroundImageView.frame = frame;
    } else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        _backgroundImageView.transform = CGAffineTransformMakeRotation(- M_PI_2);
        CGRect frame = _backgroundImageView.frame;
        frame.origin = CGPointMake(0, 0);
        _backgroundImageView.frame = frame;
    }
    
    [self.view addSubview:_backgroundImageView];
    [self.view sendSubviewToBack:_backgroundImageView];

    [UIView animateWithDuration:.3 animations:^{
        _backgroundImageView.alpha = 1;
    }];
}

- (UIImage *)screenshot {
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (window.hidden) {
            continue;
        }
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)checkVisibilityOfCell:(UITableViewCell *)cell inScrollView:(UIScrollView *)scrollView
{
    if ([self isEnoughOfCellVisible:cell inScrollView:scrollView]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        _maxIndexPathRow = indexPath.row;
        _maxIndexPathSection = indexPath.section;
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

- (void)scrollToTop
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self retractPill];
}

- (void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Pill View

- (UIButton *)pillView {
    if (_pillView) {
        return _pillView;
    }
    
    // TODO: make this customizable through the SDK
    _pillView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _pillView.frame = CGRectMake(0, 0, 125, 35);
    _pillView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    _pillView.titleLabel.font = [UIFont systemFontOfSize:14];
    _pillView.layer.cornerRadius = 17.5;
    [_pillView setTitle:@"New Cards" forState:UIControlStateNormal];
    [_pillView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_pillView setTitleEdgeInsets:UIEdgeInsetsMake(0, 35, 0, 15)];
    [_pillView addTarget:self action:@selector(scrollToTop) forControlEvents:UIControlEventTouchUpInside];
    
    RXUpArrow *upArrow = [RXUpArrow new];
    upArrow.frame = CGRectMake(17, 12, 40, 40);
    [_pillView addSubview:upArrow];
    
    return _pillView;
}

- (void)dropPill
{
    self.pillView.center = CGPointMake(self.tableView.center.x, -self.pillView.frame.size.height/2);
    [self.tableView.superview addSubview:self.pillView];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.pillView.center = CGPointMake(self.pillView.center.x, self.pillView.frame.size.height/2 + 20);
                     } completion:nil];
}

- (void)retractPill
{
    if (_pillView.center.y ==  -_pillView.frame.size.height/2) {
        return;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _pillView.center = CGPointMake(_pillView.center.x, -_pillView.frame.size.height/2);
                     } completion:^(BOOL finished) {
                         [_pillView removeFromSuperview];
                     }];
}



#pragma mark - RXVisitViewController Event Hooks

- (void)didAddDecks:(NSArray *)decks {
    [super didAddDecks:decks];
    
    // get smarter
    _maxIndexPathSection++;
    _minIndexPathRow = [self tableView:self.tableView numberOfRowsInSection:decks.count - 1];
    _minIndexPathSection = decks.count - 1;
    
    NSInteger numberOfDecksWithCards = [decks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVDeck *deck, NSDictionary *bindings) {
        return [self nonDeletedCardsFromCardsArray:deck.cards].count > 0;
    }]].count;
    
    if (self.isViewLoaded && self.view.window && numberOfDecksWithCards > 0) {
        [self dropPill];
    }
}


@end
