//
//  RXDetailViewController.m
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import "RXDetailViewController.h"
#import "RXBlockView.h"
#import "RVViewDefinition.h"
#import "RVBlock.h"
#import "RVHeaderBlock.h"
#import "RVButtonBlock.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface RXDetailViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *titleBar;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) NSLayoutConstraint *containerBarBottomConstraint;
@property (nonatomic, strong, readonly) NSLayoutConstraint *titleBarTopConstraint;
@property (nonatomic, strong, readonly) NSLayoutConstraint *scrollViewHeightConstraint;

@end

@implementation RXDetailViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleBar = [UIView new];
    _titleBar.translatesAutoresizingMaskIntoConstraints = NO;
    _titleBar.backgroundColor = [UIColor clearColor];
    _titleBar.userInteractionEnabled = YES;
    
    _footerView = [UIView new];
    _footerView.translatesAutoresizingMaskIntoConstraints = NO;
    _footerView.backgroundColor = [UIColor clearColor];
    _footerView.userInteractionEnabled = YES;
    
    _scrollView = [UIScrollView new];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.scrollEnabled = YES;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.alwaysBounceVertical = YES;
    
    _containerView = [UIView new];
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    _containerView.backgroundColor = [UIColor clearColor];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView,_titleBar,_containerView,_footerView);
    
    [_scrollView addSubview:_containerView];
    [self.view addSubview:_scrollView];
    [self.view addSubview:_titleBar];
    [self.view addSubview:_footerView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    //[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    _containerBarBottomConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraint:_containerBarBottomConstraint];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_titleBar]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_scrollView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_footerView]|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleBar][_scrollView][_footerView]|" options:0 metrics:nil views:views]];
    
//    _titleBarTopConstraint = [NSLayoutConstraint constraintWithItem:_titleBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
//    [self.view addConstraint:_titleBarTopConstraint];
//    
//    _scrollViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
//    [self.view addConstraint:_scrollViewHeightConstraint];
//    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];

    
    [self loadViewDefinition];
}

- (void)loadViewDefinition {
    
    // Background Color
    self.view.backgroundColor = _viewDefinition.backgroundColor;
    
    // Background Image
    if (_viewDefinition.backgroundImageURL) {
        [self setBackgroundImageWithURL:_viewDefinition.backgroundImageURL contentMode:_viewDefinition.backgroundContentMode];
    }
    
    [_containerView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
    [_viewDefinition.blocks enumerateObjectsUsingBlock:^(RVBlock *block, NSUInteger idx, BOOL *stop) {
        RXBlockView *blockView = [[RXBlockView alloc] initWithBlock:block];
        if ([block class] == [RVHeaderBlock class]) {
            blockView.userInteractionEnabled = YES;
            [self addHeaderBlockView:blockView];
            
            // TODO: can redo all of this and make it simpler
            
            // move this somewhere else
            _scrollViewHeightConstraint.constant = -[block heightForWidth:self.view.frame.size.width];
            
        } else if ([block class] == [RVButtonBlock class] && idx == _viewDefinition.blocks.count - 1) {
            [self addBottomStickyBlockView:blockView];
        } else {
            [self addBlockView:blockView];
        }
    }];
    // TODO: move this stuff out
    
    
    if (_containerView.subviews.count > 0) {
        // UIScrollView AutoLayout ContentSize Constraint
        UIView *lastBlock = _containerView.subviews[_containerView.subviews.count - 1];
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:lastBlock attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }


    
    
    // titlebar height bug
    if (_titleBar.subviews.count > 0) {
        UIView *lastTitleBlock = _titleBar.subviews[_titleBar.subviews.count - 1];
        if (lastTitleBlock) {
            [_titleBar addConstraint:[NSLayoutConstraint constraintWithItem:_titleBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:lastTitleBlock attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        }
    }
    
    // same bug for footerview
    if (_footerView.subviews.count > 0) {
        UIView *lastFooterBlock = _footerView.subviews[_footerView.subviews.count - 1];
        if (lastFooterBlock) {
            [_footerView addConstraint:[NSLayoutConstraint constraintWithItem:_footerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:lastFooterBlock attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        }
    }
}

- (void)setBackgroundImageWithURL:(NSURL *)url contentMode:(RVBackgroundContentMode)contentmode {
    __weak UIView *weakContainerView = self.view;
    if (contentmode == RVBackgroundContentModeTile) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            weakContainerView.backgroundColor = [UIColor colorWithPatternImage:image];
        }];
    } else {
        UIImageView *backgroundImageView = [UIImageView new];
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        backgroundImageView.contentMode = UIViewContentModeFromRVBackgroundContentMode(contentmode);
        [backgroundImageView sd_setImageWithURL:url];
        
        [weakContainerView addSubview:backgroundImageView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(backgroundImageView);
        
        [weakContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundImageView]|" options:0 metrics:nil views:views]];
        //[weakContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backgroundImageView]|" options:0 metrics:nil views:views]];
        [weakContainerView addConstraint:[NSLayoutConstraint constraintWithItem:backgroundImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [weakContainerView addConstraint:[NSLayoutConstraint constraintWithItem:backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:weakContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        [weakContainerView sendSubviewToBack:backgroundImageView];
    }
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
}

- (void)configureHeaderLayoutForBlockView:(RXBlockView *)blockView {
    id lastHeaderBlockView = _titleBar.subviews.count > 1 ? _titleBar.subviews[_titleBar.subviews.count - 2] : nil;
    [_titleBar addConstraints:[RXBlockView constraintsForBlockView:blockView withPreviousBlockView:lastHeaderBlockView inside:_titleBar]];
 
//    // Height constraint
    [_titleBar addConstraint:[NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:[blockView.block heightForWidth:self.view.frame.size.width]]];
}

- (void)configureFooterLayoutForBlockView:(RXBlockView *)blockView {
    id lastHeaderBlockView = _footerView.subviews.count > 1 ? _footerView.subviews[_footerView.subviews.count - 2] : nil;
    [_footerView addConstraints:[RXBlockView constraintsForBlockView:blockView withPreviousBlockView:lastHeaderBlockView inside:_footerView]];
    
    [_footerView addConstraint:[NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:[blockView.block heightForWidth:self.view.frame.size.width]]];
}

- (void)addBlockView:(RXBlockView *)blockView {
    [_containerView addSubview:blockView];
    [self configureLayoutForBlockView:blockView];
}

- (void)addHeaderBlockView:(RXBlockView *)blockView {
    [_titleBar addSubview:blockView];
    [self configureHeaderLayoutForBlockView:blockView];
}

- (void)addBottomStickyBlockView:(RXBlockView *)blockView {
    [_footerView addSubview:blockView];
    [self configureFooterLayoutForBlockView:blockView];
}

@end
