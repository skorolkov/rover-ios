//
//  RXDetailViewController.m
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import "RXDetailViewController.h"
#import "RXTransition.h"
#import "RXBlockView.h"
#import "RVViewDefinition.h"
#import "RVBlock.h"
#import "RVHeaderBlock.h"

@interface RXDetailViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) RXTransition *transitionManager;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *titleBar;

@property (nonatomic, strong) NSLayoutConstraint *titleBarTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *containerBarBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *scrollViewHeightConstraint;

@end

@implementation RXDetailViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _transitionManager = [[RXTransition alloc] initWithParentViewController:self];
        self.transitioningDelegate = _transitionManager;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (instancetype)initWithViewDefinition:(RVViewDefinition *)viewDefinition {
    self = [self init];
    if (self) {
        self.viewDefinition = viewDefinition;
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
    _containerBarBottomConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraint:_containerBarBottomConstraint];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_titleBar]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_scrollView]|" options:0 metrics:nil views:views]];
    
    _titleBarTopConstraint = [NSLayoutConstraint constraintWithItem:_titleBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.view addConstraint:_titleBarTopConstraint];
    
    _scrollViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [self.view addConstraint:_scrollViewHeightConstraint];

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
    
    // Height constraint
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:[blockView.block heightForWidth:self.view.frame.size.width]]];
    NSLog(@"height for %@ = %f",blockView.block, [blockView.block heightForWidth:self.view.frame.size.width] );
}

- (void)configureHeaderLayoutForBlockView:(RXBlockView *)blockView {
    id lastHeaderBlockView = _titleBar.subviews.count > 1 ? _titleBar.subviews[_titleBar.subviews.count - 2] : nil;
    [_titleBar addConstraints:[RXBlockView constraintsForBlockView:blockView withPreviousBlockView:lastHeaderBlockView inside:_titleBar]];
    
}

- (void)addBlockView:(RXBlockView *)blockView {
    [_containerView addSubview:blockView];
    [self configureLayoutForBlockView:blockView];
}

- (void)addHeaderBlockView:(RXBlockView *)blockView {
    [_titleBar addSubview:blockView];
    [self configureHeaderLayoutForBlockView:blockView];
}

- (void)setViewDefinition:(RVViewDefinition *)viewDefinition {
    if (self.view) {
        [_containerView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
            [subview removeFromSuperview];
        }];
        [viewDefinition.blocks enumerateObjectsUsingBlock:^(RVBlock *block, NSUInteger idx, BOOL *stop) {
            if ([block class] == [RVHeaderBlock class]) {
                [self addHeaderBlockView:[[RXBlockView alloc] initWithBlock:block]];
                
                // move this somewhere else
                _scrollViewHeightConstraint.constant = -[block heightForWidth:self.view.frame.size.width];
                
            } else {
                [self addBlockView:[[RXBlockView alloc] initWithBlock:block]];
            }
        }];
        // TODO: move this stuff out
        
        
        UIView *lastBlock = _containerView.subviews[_containerView.subviews.count - 1];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:lastBlock attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        UIView *extendedBackground = [UIView new];
        extendedBackground.translatesAutoresizingMaskIntoConstraints = NO;
        extendedBackground.backgroundColor = lastBlock.backgroundColor;
        
        [_containerView addSubview:extendedBackground];
        [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[extendedBackground]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(extendedBackground)]];
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:extendedBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastBlock attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:extendedBackground attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
}

- (void)prepareLayoutForTransition {
    [self prepareLayoutForInteractiveTransition:1];
}

- (void)prepareLayoutForInteractiveTransition:(CGFloat)percentageComplete {
    _titleBarTopConstraint.constant = _scrollViewHeightConstraint.constant * percentageComplete;
    if (percentageComplete > 0.2) {
        //_containerBarBottomConstraint.constant = [UIScreen mainScreen].applicationFrame.size.height;// * percentageComplete * 4;
    }
}

- (void)resetLayout {
    _titleBarTopConstraint.constant = 0;
    //_containerBarBottomConstraint.constant = 0;
}


@end
