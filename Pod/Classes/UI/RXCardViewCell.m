//
//  RXCardViewCell.m
//  Pods
//
//  Created by Ata Namvari on 2015-01-12.
//
//

#import "RXCardViewCell.h"
#import "RXBlockView.h"
#import "RVViewDefinition.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RVBlock.h"

// Shadow constants
#define kCardShadowColor [[UIColor blackColor] CGColor]
#define kCardShadowOffset CGSizeMake(0, 0)
#define kCardShadowOpacity 0.2
#define kCardShadowRadius 0

@interface RXCardViewCell () <UIGestureRecognizerDelegate, RXBlockViewDelegate>

@property (nonatomic, strong) NSLayoutConstraint *containerViewLeadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *containerViewTrailingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *containerViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *containerViewBottomConstraint;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, strong) NSLayoutConstraint *lastBlockLayoutConstraint;

@end

@implementation RXCardViewCell

- (void)awakeFromNib {
    [self initialize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
    _panGestureRecognizer.delegate = self;
    [self addSubviews];
    [self configureLayout];
}

- (void)addSubviews
{
    _containerView = [UIView new];
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor clearColor];
    _containerView.layer.shadowColor = kCardShadowColor;
    _containerView.layer.shadowOffset = kCardShadowOffset;
    _containerView.layer.shadowOpacity = kCardShadowOpacity;
    _containerView.layer.shadowRadius = kCardShadowRadius;
    [_containerView addGestureRecognizer:_panGestureRecognizer];
    [self.contentView addSubview:_containerView];
}

- (void)configureLayout
{
    //----------------------------------------
    //  containerView
    //----------------------------------------
    
    _containerViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:15];
    _containerViewTrailingConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-15];
    
    [self addConstraints:@[_containerViewLeadingConstraint, _containerViewTrailingConstraint]];
    
    _containerViewTopConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:15];
    _containerViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-15];
    
    [self addConstraints:@[_containerViewTopConstraint, _containerViewBottomConstraint]];
}

- (void)setMargins:(UIEdgeInsets)margins {
    _margins = margins;
    _containerViewTopConstraint.constant = margins.top;
    _containerViewTrailingConstraint.constant = -margins.right;
    _containerViewBottomConstraint.constant = -margins.bottom;
    _containerViewLeadingConstraint.constant = margins.left;
}

- (void)configureLayoutForBlockView:(UIView *)blockView
{
    id lastBlockView = _containerView.subviews.count > 1 ? _containerView.subviews[_containerView.subviews.count - 2] : nil;
    [_containerView addConstraints:[RXBlockView constraintsForBlockView:blockView withPreviousBlockView:lastBlockView inside:_containerView]];
}

- (void)configureLayoutForLastBlockView:(UIView *)blockView
{
    // TODO: this is not always accurate
    
    _lastBlockLayoutConstraint = [NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    [_containerView addConstraint:_lastBlockLayoutConstraint];
}

- (void)addBlockView:(UIView *)blockView {
    [_containerView addSubview:blockView];
    [self configureLayoutForBlockView:blockView ];
    
    if (_lastBlockLayoutConstraint) {
        [_containerView removeConstraint:_lastBlockLayoutConstraint];
        [self configureLayoutForLastBlockView:blockView];
    }
}

- (void)setViewDefinition:(RVViewDefinition *)viewDefinition {
    // Margins
    [self setMargins:viewDefinition.margins];
    
    // Background Color
    [_containerView setBackgroundColor:viewDefinition.backgroundColor];
    
    // Corner Radius
    _containerView.layer.cornerRadius = viewDefinition.cornerRadius;
    

    
    // Blocks
    [viewDefinition.blocks enumerateObjectsUsingBlock:^(RVBlock *block, NSUInteger idx, BOOL *stop) {
        RXBlockView *blockView = [[RXBlockView alloc] initWithBlock:block];
        blockView.delegate = self;
        [self addBlockView:blockView];
    }];
    
//    if (_containerView.subviews.count > 0) {
//        [self configureLayoutForLastBlockView:_containerView.subviews[_containerView.subviews.count - 1]];
//    }
    
    // Background Image
    if (viewDefinition.backgroundImageURL) {
        [self setBackgroundImageWithURL:viewDefinition.backgroundImageURL contentMode:viewDefinition.backgroundContentMode];
    }
    
    _viewDefinition = viewDefinition;
}

- (void)setBackgroundImageWithURL:(NSURL *)url contentMode:(RVBackgroundContentMode)contentmode {
    __weak UIView *weakContainerView = _containerView;
    if (contentmode == RVBackgroundContentModeTile) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            weakContainerView.backgroundColor = [UIColor colorWithPatternImage:image];
        }];
    } else {
        UIImageView *backgroundImageView = [UIImageView new];
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        backgroundImageView.contentMode = UIViewContentModeFromRVBackgroundContentMode(contentmode);
        [backgroundImageView sd_setImageWithURL:url];
        
        [self.containerView addSubview:backgroundImageView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(backgroundImageView);
        
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundImageView]|" options:0 metrics:nil views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImageView]|" options:0 metrics:nil views:views]];
        
        [self.containerView sendSubviewToBack:backgroundImageView];
        
        [backgroundImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        [backgroundImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetConstraintsToZero:NO notifyDelegate:NO];
    
    [_containerView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
    
}

#pragma mark - UIPanGestureRecognizer

- (void)panCell:(UIPanGestureRecognizer *)recognizer {
    static CGPoint panStartPoint;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            panStartPoint = [recognizer translationInView:self.containerView];
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.containerView];
            CGFloat deltaX = currentPoint.x - panStartPoint.x;
            [self moveContainer:deltaX];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            if (fabs(_containerViewLeadingConstraint.constant - _margins.left) > (_containerView.frame.size.width *.5)) {
                [self setConstraintsToSwipeCardAway:YES notifyDelegate:YES];
            } else {
                [self resetConstraintsToZero:YES notifyDelegate:NO];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gesture {
    if (gesture != _panGestureRecognizer) {
        return NO;
    }
    CGPoint translation = [gesture translationInView: self.superview];
    return (fabs(translation.x) > fabs(translation.y));
}

#pragma mark - Layout Constraints

- (void)setConstraintsToSwipeCardAway:(BOOL)animated notifyDelegate:(BOOL)notify {
    if (notify && [self.delegate respondsToSelector:@selector(cardViewCellDidSwipe:)]) {
        [self.delegate cardViewCellDidSwipe:self];
    }
    
    float direction = _containerViewLeadingConstraint.constant - _margins.left > 0 ? 1 : -1;
    
    _containerViewLeadingConstraint.constant = _margins.left + (direction * self.contentView.frame.size.width);
    _containerViewTrailingConstraint.constant = _margins.right + (direction * self.contentView.frame.size.width);
    
    [self updateConstraintsIfNeeded:animated animationBlock:^{
        _containerView.alpha = 0.2;
    } completion:nil];
}

- (void)resetConstraintsToZero:(BOOL)animated notifyDelegate:(BOOL)notify {
    [self removeConstraints:@[_containerViewTrailingConstraint, _containerViewLeadingConstraint]];
    
    _containerViewLeadingConstraint.constant = _margins.left;
    _containerViewTrailingConstraint.constant = -_margins.right;
    
    [self addConstraints:@[_containerViewLeadingConstraint, _containerViewTrailingConstraint]];

    [self updateConstraintsIfNeeded:animated animationBlock:^{
        _containerView.alpha = 1;
    } completion:nil];
}

- (void)updateConstraintsIfNeeded:(BOOL)animated animationBlock:(void (^)())animationBlock completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.3;
    }
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:.6 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        animationBlock ? animationBlock() : nil;
        [self layoutIfNeeded];
    } completion:completion];
}

- (void)moveContainer:(CGFloat)deltaX {
    _containerViewLeadingConstraint.constant = deltaX + _margins.left;
    _containerViewTrailingConstraint.constant = deltaX - _margins.right;
    _containerView.alpha = (_containerView.frame.size.width - fabs(deltaX)) / _containerView.frame.size.width;
    [self updateConstraintsIfNeeded:NO animationBlock:nil completion:nil];
}

#pragma mark - RXBlockViewDelegate

- (BOOL)blockview:(RXBlockView *)blockview shouldOpenURL:(NSURL *)url {
    if ([self.delegate respondsToSelector:@selector(cardViewCell:shouldOpenURL:)]) {
        return [self.delegate cardViewCell:self shouldOpenURL:url];
    }
    return YES;
}

@end
