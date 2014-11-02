//
//  RVCardBaseView.m
//  Rover
//
//  Created by Ata Namvari on 2014-10-13.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardBaseView.h"
#import "RVCardViewButtonBar.h"

#define IS_WIDESCREEN ([[UIScreen mainScreen] bounds].size.height == 568.0)

const CGFloat kRVCardViewImageRatio = .625;

@interface RVCardBaseView () {
    CGRect _expandedFrame;
}

@property (nonatomic, getter=isExpanded) BOOL expanded;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UILabel *shortDescriptionTextView;

// Title bar
@property (strong, nonatomic) UIView *titleBar;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *titleLineLeft;
@property (strong, nonatomic) UIView *titleLineRight;

// Constraints
@property (strong, nonatomic) NSLayoutConstraint *containerViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *containerViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *contentViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *titleBarHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *imageViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *imageViewTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *shortDescriptionHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *titleLineLeftTrailConstraint;
@property (strong, nonatomic) NSLayoutConstraint *titleLineRightLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *titleLineLeftExpandedConstraint;
@property (strong, nonatomic) NSLayoutConstraint *titleLineRightExpandedConstraint;
@property (strong, nonatomic) NSLayoutConstraint *titleLabelCenterYConstraint;
@property (strong, nonatomic) NSLayoutConstraint *titleLineLeftBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *titleLineRightBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *titleBarTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *buttonBarHeightConstraint;

@end

@implementation RVCardBaseView


#pragma mark - Class Methods

+ (CGFloat)contractedWidth {
    return 280.0;
}

+ (CGFloat)contractedHeight {
    return IS_WIDESCREEN ? 369.0 : 347.0;
}

#pragma mark - Public Properties

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = [title uppercaseString];
    _title = title;
}

- (void)setShortDescription:(NSString *)shortDescription
{
    self.shortDescriptionTextView.text = shortDescription;
    _shortDescription = shortDescription;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}

- (void)setFontColor:(UIColor *)fontColor
{
    self.titleLineLeft.backgroundColor = fontColor;
    self.titleLineRight.backgroundColor = fontColor;
    self.titleLabel.textColor = fontColor;
    self.shortDescriptionTextView.textColor = fontColor;
    self.buttonBar.fontColor = fontColor;
    _fontColor = fontColor;
}

- (void)setImage:(UIImage *)image
{
    /*
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat imageRatio = imageWidth / imageHeight;
    
    if (imageRatio == 1.6) {
        self.imageView.image = image;
        return;
    }
    
    CGFloat cropHeight;
    CGFloat cropWidth;
    CGFloat cropX;
    CGFloat cropY;
    
    if (imageRatio < kRVCardViewImageRatio) {
        cropWidth = imageWidth;
        cropHeight = imageWidth / kRVCardViewImageRatio;
        cropX = 0.0;
        cropY = (imageHeight - cropHeight) / 2;
    } else {
        cropWidth = imageHeight * kRVCardViewImageRatio;
        cropHeight = imageHeight;
        cropX = (imageWidth - cropWidth) / 2;
        cropY = 0.0;
    }
    
    CGRect crop = CGRectMake(cropX, cropY, cropWidth, cropHeight);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], crop);
    self.imageView.image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
     */
    self.imageView.image = image;
}

- (UIImage *)image
{
    return self.imageView.image;
}

#pragma mark - Private Properties

- (void)setExpanded:(BOOL)expanded {
    self.scrollView.scrollEnabled = expanded;
    _expanded = expanded;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 3.0;
        self.layer.masksToBounds = YES;
        
        [self addSubviews];
        [self configureLayout];
        
        self.expanded = NO;
        //self.useCloseButton = NO;
        self.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:111.0/255.0 blue:203.0/255.0 alpha:1.0];
        self.fontColor = [UIColor whiteColor];
    }
    return self;
}

- (void)addSubviews
{
    self.containerView = [UIView new];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.containerView];
    
    self.scrollView = [UIScrollView new];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.scrollView];
    
    self.contentView = [UIView new];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
    
    self.titleBar = [UIView new];
    self.titleBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.titleBar];
    
    self.titleLineLeft = [UIView new];
    self.titleLineLeft.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLineLeft.alpha = 0.5;
    [self.titleBar addSubview:self.titleLineLeft];
    
    self.titleLineRight = [UIView new];
    self.titleLineRight.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLineRight.alpha = 0.5;
    [self.titleBar addSubview:self.titleLineRight];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleBar addSubview:self.titleLabel];
    
    self.shortDescriptionTextView = [UILabel new];
    self.shortDescriptionTextView.numberOfLines = IS_WIDESCREEN ? 3 : 2;
    self.shortDescriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.shortDescriptionTextView.font = [UIFont systemFontOfSize:16.0];
    self.shortDescriptionTextView.textAlignment = NSTextAlignmentCenter;
    self.shortDescriptionTextView.alpha = 0.7;
    self.shortDescriptionTextView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.shortDescriptionTextView];
    
    self.buttonBar = [RVCardViewButtonBar new];
    self.buttonBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.buttonBar.delegate = self;
    [self.containerView addSubview:self.buttonBar];
    
    self.imageView = [UIImageView new];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.imageView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTapped)];
    [self.containerView addGestureRecognizer:tapGestureRecognizer];
    
}

- (void)configureContainerLayout
{
    [self removeConstraints:self.containerView.constraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [self removeConstraint:self.containerViewWidthConstraint];
    self.containerViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:self.isExpanded ? _expandedFrame.size.width : RVCardBaseView.contractedWidth];
    [self addConstraint:self.containerViewWidthConstraint];
    
    [self removeConstraint:self.containerViewHeightConstraint];
    self.containerViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:self.isExpanded ? _expandedFrame.size.height : RVCardBaseView.contractedHeight];
    [self addConstraint:self.containerViewHeightConstraint];
}

- (void)configureLayout
{
    NSDictionary *views = @{ @"contentView": self.contentView,
                             @"scrollView": self.scrollView,
                             @"titleBar": self.titleBar,
                             @"titleLabel": self.titleLabel,
                             @"titleLineLeft": self.titleLineLeft,
                             @"titleLineRight": self.titleLineRight,
                             @"shortDescriptionTextView": self.shortDescriptionTextView,
                             @"imageView": self.imageView,
                             @"buttonBar": self.buttonBar
                             };
    
    //----------------------------------------
    //  containerView
    //----------------------------------------

    [self configureContainerLayout];
    
    //----------------------------------------
    //  scrollView
    //----------------------------------------
    
    // scrollView fills the frame
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleBar][scrollView][buttonBar]|" options:0 metrics:nil views:views]];

    //----------------------------------------
    //  contentView
    //----------------------------------------
    
    // Content view fills the scroll view and inherintly sets the scroll view's content size
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentView]|" options:0 metrics:nil views:views]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
    
    // Set the contentView's width
    self.contentViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:[RVCardBaseView contractedWidth]];
    [self.scrollView addConstraint:self.contentViewWidthConstraint];
    
    //----------------------------------------
    //  titleBar
    //----------------------------------------
    
    // Pin the title bar to the left and right edges
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[titleBar]|" options:0 metrics:nil views:views]];
    
    // Set the height of the title bar
    self.titleBarHeightConstraint = [NSLayoutConstraint constraintWithItem:self.titleBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:20];
    [self.titleBar addConstraint:self.titleBarHeightConstraint];
    
    // Pin the title bar to the top edge
    self.titleBarTopConstraint = [NSLayoutConstraint constraintWithItem:self.titleBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeTop multiplier:1.0 constant:26.0];
    [self.containerView addConstraint:self.titleBarTopConstraint];
    
    // Layout the title label and title line
    [self.titleBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[titleLineLeft]" options:0 metrics:0 views:views]];
    [self.titleBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[titleLineRight]|" options:0 metrics:0 views:views]];
    
    self.titleLineLeftTrailConstraint = [NSLayoutConstraint constraintWithItem:self.titleLineLeft attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-12];
    [self.titleBar addConstraint:self.titleLineLeftTrailConstraint];
    
    self.titleLineRightLeftConstraint = [NSLayoutConstraint constraintWithItem:self.titleLineRight attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:12];
    [self.titleBar addConstraint:self.titleLineRightLeftConstraint];
    
    self.titleLineLeftExpandedConstraint = [NSLayoutConstraint constraintWithItem:self.titleLineLeft attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.titleBar attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    self.titleLineRightExpandedConstraint = [NSLayoutConstraint constraintWithItem:self.titleLineRight attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.titleBar attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    // Horizontally center titleLabel
    [self.titleBar addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.titleBar attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    // Set the heights of the title line
    [self.titleBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleLineLeft(1)]" options:0 metrics:nil views:views]];
    [self.titleBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleLineRight(1)]" options:0 metrics:nil views:views]];
    
    // Vertically align the title label
    self.titleLabelCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.titleBar attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self.titleBar addConstraint:self.titleLabelCenterYConstraint];
    
    // Verticall align the title lines
    self.titleLineLeftBottomConstraint = [NSLayoutConstraint constraintWithItem:self.titleLineLeft attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.titleBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0];
    [self.titleBar addConstraint:self.titleLineLeftBottomConstraint];
    self.titleLineRightBottomConstraint = [NSLayoutConstraint constraintWithItem:self.titleLineRight attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.titleBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0];
    [self.titleBar addConstraint:self.titleLineRightBottomConstraint];
    
    //----------------------------------------
    //  shortDescription
    //----------------------------------------
    
    // Horizontal spacing of shortDescription
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[shortDescriptionTextView]-|" options:0 metrics:nil views:views]];
    
    // Height of shortDescription
    CGFloat height = IS_WIDESCREEN ? 63.0 : 41.0;
    self.shortDescriptionHeightConstraint = [NSLayoutConstraint constraintWithItem:self.shortDescriptionTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:height];
    [self.contentView addConstraint:self.shortDescriptionHeightConstraint];
    
    // Pin the short description to the title bar
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shortDescriptionTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeBottom multiplier:1.0 constant:7.0]];
    
    //----------------------------------------
    //  imageView
    //----------------------------------------
    
    // Horizontal spacing of imageView
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView]|" options:0 metrics:nil views:views]];
    
    // Height of imageView
    self.imageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:175.0];
    [self.contentView addConstraint:self.imageViewHeightConstraint];
    
    // Top position of imageView
    self.imageViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.shortDescriptionTextView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:30.0];
    [self.contentView addConstraint:self.imageViewTopConstraint];
    
    //----------------------------------------
    //  buttonBar
    //----------------------------------------
    
    // Pin the button bar to the left and right edges
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[buttonBar]|" options:0 metrics:nil views:views]];
    
    // Set the height of the button bar
    self.buttonBarHeightConstraint = [NSLayoutConstraint constraintWithItem:self.buttonBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:48];
    [self.containerView addConstraint:self.buttonBarHeightConstraint];

}

#pragma mark - Expand/Contract

- (void)didShow
{

}

- (void)expandToFrame:(CGRect)frame animated:(BOOL)animated
{
    self.containerViewHeightConstraint.constant = frame.size.height;
    self.containerViewWidthConstraint.constant = frame.size.width;
    self.contentViewWidthConstraint.constant = frame.size.width;
    self.titleBarTopConstraint.constant = 20.0;
    self.imageViewHeightConstraint.constant = frame.size.width * kRVCardViewImageRatio;
    self.imageViewTopConstraint.constant = 15.0;
    self.titleLineLeftBottomConstraint.constant = 0;
    self.titleLineRightBottomConstraint.constant = 0;
    self.titleBarHeightConstraint.constant = 44;
    [self.titleBar removeConstraints:@[self.titleLineLeftTrailConstraint, self.titleLineRightLeftConstraint]];
    [self.titleBar addConstraints:@[self.titleLineLeftExpandedConstraint, self.titleLineRightExpandedConstraint]];
    
    if (!self.buttonBar.leftButton && !self.buttonBar.rightButton) {
        self.buttonBarHeightConstraint.constant = 0;
    }
    
    if (!IS_WIDESCREEN) {
        self.shortDescriptionTextView.numberOfLines = 3;
        self.shortDescriptionHeightConstraint.constant = 63.0;
    }
    
    
    void (^animations)(void) = ^{
        self.frame = frame;
        self.layer.cornerRadius = 0.0;
        
        [self expandAnimations];
        [self layoutIfNeeded];
    };
    
    void (^completion)(BOOL finished) = ^(BOOL finished){
        self.expanded = YES;
        _expandedFrame = frame;
        [self expandCompletion];
        
        if ([self.delegate respondsToSelector:@selector(cardViewDidExpand:)]) {
            [self.delegate cardViewDidExpand:self];
        }
    };
    
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:animations completion:completion];
    } else {
        animations();
        completion(YES);
    }
}
- (void)contractToFrame:(CGRect)frame atCenter:(CGPoint)center animated:(BOOL)animated
{
    [self.scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:animated];
    
    self.containerViewHeightConstraint.constant = frame.size.height;
    self.containerViewWidthConstraint.constant = frame.size.width;
    self.contentViewWidthConstraint.constant = frame.size.width;
    self.titleBarTopConstraint.constant = 26.0;
    self.imageViewHeightConstraint.constant = 175.0;
    self.imageViewTopConstraint.constant = 31.0;
    self.titleLineRightBottomConstraint.constant = -10;
    self.titleLineLeftBottomConstraint.constant = -10;
    self.titleBarHeightConstraint.constant = 20;
    [self.titleBar removeConstraints:@[self.titleLineLeftExpandedConstraint, self.titleLineRightExpandedConstraint]];
    [self.titleBar addConstraints:@[self.titleLineLeftTrailConstraint, self.titleLineRightLeftConstraint]];
    
    self.buttonBarHeightConstraint.constant = 48;
    
    if (!IS_WIDESCREEN) {
        self.shortDescriptionTextView.numberOfLines = 2;
        self.shortDescriptionHeightConstraint.constant = 41.0;
    }
    
    void (^animations)(void) = ^{
        self.bounds = frame;
        self.center = center;
        self.layer.cornerRadius = 3.0;
        
        [self contractAnimations];
        [self layoutIfNeeded];
    };
    
    void (^completion)(BOOL finished) = ^(BOOL finished){
        self.expanded = NO;
        [self contractCompletion];
        if (self.delegate) {
            [self.delegate cardViewDidContract:self];
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:animations completion:completion];
    } else {
        animations();
        completion(YES);
    }
}

- (void)expandAnimations
{
    // Implement in subclass
}

- (void)contractAnimations
{
    // Implement in subclass
}

- (void)expandCompletion
{
    // Implement in subclass
}

- (void)contractCompletion
{
    // Implement in subclass
}

#pragma mark - Actions

- (void)cardTapped
{
    if ([self.delegate respondsToSelector:@selector(cardViewMoreButtonPressed:)]) {
        [self.delegate cardViewMoreButtonPressed:self];
    }
}

#pragma mark - RVCardViewBarButtonDelegate

- (void)buttonBarLeftButtonPressed:(RVCardViewButtonBar *)buttonBar {
    // Implement in subclass
}

- (void)buttonBarRightButtonPressed:(RVCardViewButtonBar *)buttonBar {
    // Implement in subclass
}

@end
