//
//  RXCardViewController.m
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import "RXCardViewController.h"
#import "RXTransition.h"
#import "RXBlockView.h"

@interface RXCardViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) RXTransition *transitionManager;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *titleBar;

@property (nonatomic, strong) NSLayoutConstraint *titleBarTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *containerBarBottomConstraint;

@end

@implementation RXCardViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _transitionManager = [[RXTransition alloc] initWithParentViewController:self];
        self.transitioningDelegate = _transitionManager;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (instancetype)initWithCard:(RVCard *)card {
    self = [self init];
    if (self) {
        self.card = card;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    _titleBar = [UIView new];
    _titleBar.translatesAutoresizingMaskIntoConstraints = NO;
    _titleBar.backgroundColor = [UIColor yellowColor];
    
    _scrollView = [UIScrollView new];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.scrollEnabled = YES;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.delegate = _transitionManager;
    
    _containerView = [UIView new];
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    _containerView.backgroundColor = [UIColor whiteColor];
    
    [_titleBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMe)]];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView,_titleBar,_containerView);
    
    [_scrollView addSubview:_containerView];
    [self.view addSubview:_scrollView];
    [self.view addSubview:_titleBar];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    //[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    _containerBarBottomConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraint:_containerBarBottomConstraint];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_titleBar]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_scrollView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleBar(20)]" options:0 metrics:nil views:views]];
    
    _titleBarTopConstraint = [NSLayoutConstraint constraintWithItem:_titleBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];

    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:-20]];
    
    [self.view addConstraint:_titleBarTopConstraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMe)]];
}

- (void)closeMe {
    NSLog(@"DISMISS");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureLayoutForBlockView:(RXBlockView *)blockView
{
    id lastBlockView = _containerView.subviews.count > 1 ? _containerView.subviews[_containerView.subviews.count - 2] : nil;
    [_containerView addConstraints:[RXBlockView constraintsForBlockView:blockView withPreviousBlockView:lastBlockView inside:_containerView]];
}

- (void)addBlockView:(RXBlockView *)blockView {
    [_containerView addSubview:blockView];
    [self configureLayoutForBlockView:blockView];
}

- (void)setCard:(RVCard *)card {
    if (self.view ) {
        [_containerView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
            [subview removeFromSuperview];
        }];
        [self addBlockView:[RXBlockView new]];
    }
    // This is necessary for UIScrollView with AutoLayout
    //[_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView.subviews[_scrollView.subviews.count - 1] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    //[self addBlockView:[RXBlockView new]];
}

- (void)prepareLayoutForTransition {
    [self prepareLayoutForInteractiveTransition:1];
}

- (void)prepareLayoutForInteractiveTransition:(CGFloat)percentageComplete {
    _titleBarTopConstraint.constant = -20 * percentageComplete;
    if (percentageComplete > 0.2) {
        //_containerBarBottomConstraint.constant = [UIScreen mainScreen].applicationFrame.size.height;// * percentageComplete * 4;
    }
}

- (void)resetLayout {
    _titleBarTopConstraint.constant = 0;
    //_containerBarBottomConstraint.constant = 0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
