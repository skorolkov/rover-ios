//
//  RVCardView.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-28.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardView.h"
#import "RVMoreButton.h"
#import "RVCardViewButtonBar.h"
#import "RVCardViewCorner.h"
#import "RVCardViewButtonIcon.h"
#import "RVCloseButton.h"

#define IS_WIDESCREEN ([[UIScreen mainScreen] bounds].size.height == 568.0)

const CGFloat kRVCardViewImageRatio = 1.6;

@interface RVCardView()

@property (nonatomic) BOOL expanded;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIButton *invisibleButton;

@property (strong, nonatomic) UILabel *shortDescriptionTextView;
@property (strong, nonatomic) UITextView *longDescriptionTextView;
@property (strong, nonatomic) RVMoreButton *moreButton;
@property (strong, nonatomic) RVCardViewCorner *corner;

// Title bar
@property (strong, nonatomic) UIView *titleBar;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *titleLineLeft;
@property (strong, nonatomic) UIView *titleLineRight;

// Image view
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

// Button bar
@property (strong, nonatomic) RVCardViewButtonBar *buttonBar;

// Close button
@property (strong, nonatomic) RVCloseButton *closeButton;

// Constraints
@property (strong, nonatomic) NSLayoutConstraint *contentViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *titleBarTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *moreButtonTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *imageViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *imageViewTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *longDescriptionTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *buttonBarTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *shortDescriptionHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *cornerTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *cornerRightConstraint;

@end

@implementation RVCardView

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

- (void)setLongDescription:(NSString *)longDescription
{
    NSArray *styles = @[ @"font: -apple-system-body;",
                         @"font-size: 14px;",
                         @"line-height: 21px;"];
    
    NSString *html = [NSString stringWithFormat:@"<div style=\"%@\">%@<div>", [styles componentsJoinedByString:@" "], longDescription];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    self.longDescriptionTextView.attributedText = attributedString;
    
    if (longDescription.length > 0) {
        self.moreButton.alpha = 1.0;
        self.invisibleButton.enabled = YES;
    } else {
        self.moreButton.alpha = 0.0;
        self.invisibleButton.enabled = NO;
    }
    
    _longDescription = longDescription;
}

- (void)setImageURL:(NSURL *)imageURL
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = image;
        });
    });
    _imageURL = imageURL;
}

- (void)setImage:(UIImage *)image
{
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
}

- (UIImage *)getImage
{
    return self.imageView.image;
}

- (void)setShadow:(CGFloat)shadow
{
    //self.shadowView.alpha = shadow;
    self.shadowView.layer.opacity = shadow;
    _shadow = shadow;
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

- (void)setSecondaryBackgroundColor:(UIColor *)secondaryBackgroundColor {
    self.corner.backgroundColor = secondaryBackgroundColor;
    self.buttonBar.activeColor = secondaryBackgroundColor;
    _secondaryBackgroundColor = secondaryBackgroundColor;
}

- (void)setSecondaryFontColor:(UIColor *)secondaryFontColor {
    self.corner.iconColor = secondaryFontColor;
    _secondaryFontColor = secondaryFontColor;
}

- (BOOL)isExpanded {
    return self.expanded;
}

- (void)setLiked:(BOOL)liked {
    if (liked) {
        self.discarded = NO;
    }
    
    if (!self.expanded) {
        if (liked) {
            self.cornerTopConstraint.constant = 0.0;
            self.cornerRightConstraint.constant = 0.0;
            [UIView animateWithDuration:0.2 animations:^{
                self.corner.alpha = 1.0;
                [self layoutIfNeeded];
            }];
        } else {
            self.cornerTopConstraint.constant = -30.0;
            self.cornerRightConstraint.constant = 30.0;
            [UIView animateWithDuration:0.2 animations:^{
                self.corner.alpha = 0.0;
                [self layoutIfNeeded];
            }];
        }
    }
    
    self.buttonBar.leftButtonActivated = liked;
    
    _liked = liked;
    liked = liked;
}

- (void)setDiscarded:(BOOL)discarded {
    if (discarded) {
        self.liked = NO;
    }
    
    self.buttonBar.rightButtonActivated = discarded;
    _discarded = discarded;
}

- (void)setUseCloseButton:(BOOL)useCloseButton {
    _useCloseButton = useCloseButton;
    self.closeButton.hidden = !self.useCloseButton;
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
        self.useCloseButton = NO;
        self.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:111.0/255.0 blue:203.0/255.0 alpha:1.0];
        self.fontColor = [UIColor whiteColor];
    }
    return self;
}

- (void)addSubviews
{
    self.scrollView = [UIScrollView new];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.scrollView];
    
    self.contentView = [UIView new];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
    
    self.shadowView = [[UIView alloc] initWithFrame:self.frame];
    self.shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    self.shadowView.backgroundColor = [UIColor blackColor];
    self.shadowView.alpha = 0.0;
    self.shadowView.userInteractionEnabled = NO;
    [self addSubview:self.shadowView];
    
    self.titleBar = [UIView new];
    self.titleBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.titleBar];
    
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
    
    self.moreButton = [RVMoreButton new];
    self.moreButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.moreButton.alpha = 0.0;
    [self.contentView addSubview:self.moreButton];
    
    self.buttonBar = [RVCardViewButtonBar new];
    self.buttonBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.buttonBar.delegate = self;
    [self.contentView addSubview:self.buttonBar];
    
    self.imageView = [UIImageView new];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.imageView];
    
    self.longDescriptionTextView = [UITextView new];
    self.longDescriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.longDescriptionTextView.font = [UIFont systemFontOfSize:14.0];
    self.longDescriptionTextView.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.5 blue:233.0/255.0 alpha:1.0];
    self.longDescriptionTextView.scrollEnabled = NO;
    self.longDescriptionTextView.editable = NO;
    self.longDescriptionTextView.alpha = 0.0;
    self.longDescriptionTextView.textContainerInset = UIEdgeInsetsMake(20.0, 20.0, 0.0, 20.0);
    [self.contentView addSubview:self.longDescriptionTextView];
    
    self.corner = [RVCardViewCorner new];
    self.corner.translatesAutoresizingMaskIntoConstraints = NO;
    self.corner.alpha = 0.0;
    self.corner.icon.iconType = RVCardViewButtonIconTypeHeart;
    [self.contentView addSubview:self.corner];
    
    self.invisibleButton = [UIButton new];
    self.invisibleButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.invisibleButton addTarget:self action:@selector(invisibleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.invisibleButton];
    
    self.closeButton = [[RVCloseButton alloc] initWithFrame:CGRectMake(272.0, 24.0, 44.0, 44.0)];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
}

- (void)configureLayout
{
    NSDictionary *views = @{ @"scrollView": self.scrollView,
                             @"contentView": self.contentView,
                             @"shadowView": self.shadowView,
                             @"titleBar": self.titleBar,
                             @"titleLabel": self.titleLabel,
                             @"titleLineLeft": self.titleLineLeft,
                             @"titleLineRight": self.titleLineRight,
                             @"shortDescriptionTextView": self.shortDescriptionTextView,
                             @"longDescriptionTextView": self.longDescriptionTextView,
                             @"moreButton": self.moreButton,
                             @"imageView": self.imageView,
                             @"buttonBar": self.buttonBar,
                             @"corner": self.corner,
                             @"invisibleButton": self.invisibleButton,
                             @"closeButton": self.closeButton };
    
    //----------------------------------------
    //  scrollView
    //----------------------------------------
    
    // scrollView fills the frame
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:views]];

    //----------------------------------------
    //  contentView
    //----------------------------------------
    
    // Content view fills the scroll view and inherintly sets the scroll view's content size
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentView]|" options:0 metrics:nil views:views]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
    
    // Set the contentView's width
    self.contentViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:[RVCardView contractedWidth]];
    [self.scrollView addConstraint:self.contentViewWidthConstraint];

    //----------------------------------------
    //  shadowView
    //----------------------------------------
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[shadowView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[shadowView]|" options:0 metrics:nil views:views]];

    //----------------------------------------
    //  titleBar
    //----------------------------------------
    
    // Pin the title bar to the left and right edges
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[titleBar]|" options:0 metrics:nil views:views]];
    
    // Set the height of the title bar
    [self.titleBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleBar(20)]" options:0 metrics:nil views:views]];
    
    // Pin the title bar to the top edge
    self.titleBarTopConstraint = [NSLayoutConstraint constraintWithItem:self.titleBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:26.0];
    [self.contentView addConstraint:self.titleBarTopConstraint];
    
    // Layout the title label and title line
    [self.titleBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[titleLineLeft]-12-[titleLabel]-12-[titleLineRight]|" options:0 metrics:nil views:views]];
    
    // Horizontally center titleLabel
    [self.titleBar addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.titleBar attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    // Set the heights of the title line
    [self.titleBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleLineLeft(1)]" options:0 metrics:nil views:views]];
    [self.titleBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleLineRight(1)]" options:0 metrics:nil views:views]];
    
    // Vertically center the title label and title line
    [self.titleBar addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.titleBar attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.titleBar addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLineLeft attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.titleBar attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.titleBar addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLineRight attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.titleBar attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

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
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shortDescriptionTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:7.0]];

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
    //  moreButton
    //----------------------------------------
    
    // Width and height of moreButton
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moreButton(50)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[moreButton(25)]" options:0 metrics:nil views:views]];
    
    // Horizontally center moreButton
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.moreButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    // Tie bottom edge of moreButton to top edge of imageView
    self.moreButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.moreButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:25.0];
    [self.contentView addConstraint:self.moreButtonTopConstraint];

    //----------------------------------------
    //  longDescription
    //----------------------------------------
    
    // Horizontal spacing of longDescription
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[longDescriptionTextView]|" options:0 metrics:nil views:views]];
    
    // Tie the bottom edge of longDescription to the contentView
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[longDescriptionTextView]|" options:0 metrics:nil views:views]];
    
    // Set the longDescription's minimum height so it always extends to the bottom edge of the screen
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat minHeight = screenBounds.size.height - 364.0;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.longDescriptionTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0 constant:minHeight]];
    
    // Top position of longDescription
    self.longDescriptionTopConstraint = [NSLayoutConstraint constraintWithItem:self.longDescriptionTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:60.0];
    [self.contentView addConstraint:self.longDescriptionTopConstraint];

    //----------------------------------------
    //  buttonBar
    //----------------------------------------
    
    // Pin the button bar below the image
    self.buttonBarTopConstraint = [NSLayoutConstraint constraintWithItem:self.buttonBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.contentView addConstraint:self.buttonBarTopConstraint];
    
    // Pin the button bar to the left and right edges
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[buttonBar]|" options:0 metrics:nil views:views]];
    
    // Set the height of the button bar
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[buttonBar(48)]" options:0 metrics:nil views:views]];
    
    //----------------------------------------
    //  corner
    //----------------------------------------
    
    // Set the width and height of the corner
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[corner(60)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[corner(60)]" options:0 metrics:nil views:views]];
    
    // Pin the corner to the top edge
    self.cornerTopConstraint = [NSLayoutConstraint constraintWithItem:self.corner attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-30.0];
    [self.contentView addConstraint:self.cornerTopConstraint];
    
    // Pin the corner to the right edge
    self.cornerRightConstraint = [NSLayoutConstraint constraintWithItem:self.corner attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:30.0];
    [self.contentView addConstraint:self.cornerRightConstraint];
    
    //----------------------------------------
    //  invisibleButton
    //----------------------------------------
    
    // Pin the invisible button to the top and sides of the content view
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[invisibleButton]|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[invisibleButton]" options:0 metrics:nil views:views]];
    
    // Pin the bottom edge of the invisible button to the bottom edge of the image view
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.invisibleButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    //----------------------------------------
    //  closeButton
    //----------------------------------------
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[closeButton(44)]" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:142.0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[closeButton(44)]" options:0 metrics:nil views:views]];
}

#pragma mark - Expand/contract

- (void)didShow
{
    self.moreButtonTopConstraint.constant = 0.0;
    [UIView animateWithDuration:0.1 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)expandToFrame:(CGRect)frame
{
    self.contentViewWidthConstraint.constant = frame.size.width;
    self.titleBarTopConstraint.constant = 60.0;
    self.moreButtonTopConstraint.constant = 25.0;
    self.imageViewHeightConstraint.constant = 200.0;
    self.imageViewTopConstraint.constant = 15.0;
    self.longDescriptionTopConstraint.constant = 0.0;
    self.buttonBarTopConstraint.constant = -44.0;
    
    if (!IS_WIDESCREEN) {
        self.shortDescriptionTextView.numberOfLines = 3;
        self.shortDescriptionHeightConstraint.constant = 63.0;
    }
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = frame;
        self.layer.cornerRadius = 0.0;
        self.moreButton.alpha = 0.0;
        self.buttonBar.alpha = 0.0;
        self.longDescriptionTextView.alpha = 1.0;
        
        if (_liked) {
            self.corner.alpha = 0.0;
        }
        
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.expanded = YES;
        if ([self.delegate respondsToSelector:@selector(cardViewDidExpand:)]) {
            [self.delegate cardViewDidExpand:self];
        }
    }];
}

- (void)contractToFrame:(CGRect)frame atCenter:(CGPoint)center
{
    [self.scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    
    self.contentViewWidthConstraint.constant = frame.size.width;
    self.titleBarTopConstraint.constant = 26.0;
    self.moreButtonTopConstraint.constant = 0.0;
    self.imageViewHeightConstraint.constant = 175.0;
    self.imageViewTopConstraint.constant = 31.0;
    self.longDescriptionTopConstraint.constant = 60.0;
    self.buttonBarTopConstraint.constant = 0.0;
    
    if (!IS_WIDESCREEN) {
        self.shortDescriptionTextView.numberOfLines = 2;
        self.shortDescriptionHeightConstraint.constant = 41.0;
    }
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.bounds = frame;
        self.center = center;
        self.layer.cornerRadius = 3.0;
        self.moreButton.alpha = 1.0;
        self.buttonBar.alpha = 1.0;
        self.longDescriptionTextView.alpha = 0.0;
        
        if (_liked) {
            self.corner.alpha = 1.0;
        }
        
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.expanded = NO;
        if (self.delegate) {
            [self.delegate cardViewDidContract:self];
        }
    }];
    
}

#pragma mark - RVCardViewBarButtonDelegate

- (void)buttonBarLeftButtonPressed:(RVCardViewButtonBar *)buttonBar {
    if (self.delegate) {
        [self.delegate cardViewLikeButtonPressed:self];
    }
}

- (void)buttonBarRightButtonPressed:(RVCardViewButtonBar *)buttonBar {
    if (self.delegate) {
        [self.delegate cardViewDiscardButtonPressed:self];
    }
}

#pragma mark - Actions

- (void)invisibleButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(cardViewMoreButtonPressed:)]) {
        [self.delegate cardViewMoreButtonPressed:self];
    }
}

- (void)closeButtonPressed {
    if ([self.delegate respondsToSelector:@selector(cardViewCloseButtonPressed:)]) {
        [self.delegate cardViewCloseButtonPressed:self];
    }
}

@end
