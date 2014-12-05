//
//  RVCardView.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-28.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardView.h"
#import "RVMoreButton.h"
#import "RVCardViewCorner.h"
#import "RVCardViewButtonIcon.h"
#import "RVCloseButton.h"
#import "RVCard.h"

#import <RSBarcodes/RSUnifiedCodeGenerator.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

#define IS_WIDESCREEN ([[UIScreen mainScreen] bounds].size.height == 568.0)

const CGFloat kRVCardViewImageRatio = .625;


@interface RVCardView()



@property (strong, nonatomic) UIView *termsTitleLineLeft;
@property (strong, nonatomic) UIView *termsTitleLineRight;

@property (strong, nonatomic) UIScrollView *scrollView;

// Close button
@property (strong, nonatomic) RVCloseButton *closeButton;

@property (assign, nonatomic) CGFloat footerHeight;

// Constraints
@property (strong, nonatomic) NSLayoutConstraint *cornerTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *cornerRightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *moreButtonTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *shortDescriptionTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *contentViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *imageViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *shortDescriptionHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *scrollViewBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *descriptionViewMinHeightConstraint;

@end

@implementation RVCardView

#pragma mark - Public Properties

- (void)setShortDescriptionFont:(UIFont *)shortDescriptionFont
{
    self.shortDescriptionTextView.font = shortDescriptionFont;
    [self setShortDescription:self.shortDescription];
}

- (UIFont *)shortDescriptionFont
{
    return self.shortDescriptionTextView.font;
}

- (void)setLongDescriptionFont:(UIFont *)longDescriptionFont
{
    self.longDescriptionTextView.font = longDescriptionFont;
    [self setLongDescription:self.longDescription];
}

- (UIFont *)longDescriptionFont
{
    return self.longDescriptionTextView.font;
}

- (CGFloat)contractedHeight
{
    return super.contractedHeight + (self.footerHeight ? self.footerHeight - 10 : 0);
}

- (void)setFooterView:(UIView *)footerView
{
    _footerView = footerView;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat minHeight = screenBounds.size.height - self.shortDescriptionHeightConstraint.constant - (screenBounds.size.width * kRVCardViewImageRatio);
    
    if (!footerView) {
        self.footerHeight = 0;
        self.scrollViewBottomConstraint.constant = -10;
        self.descriptionViewMinHeightConstraint.constant = minHeight;
        return;
    }
    
    footerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:footerView];
    
    NSDictionary *views = @{@"footerView": footerView};

    self.footerHeight = footerView.frame.size.height;
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[footerView(%f)]|", self.footerHeight] options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[footerView]|" options:0 metrics:nil views:views]];
    self.scrollViewBottomConstraint.constant = - MAX(10, self.footerHeight);
    self.containerViewHeightConstraint.constant = self.contractedHeight;
    
    minHeight -= self.footerHeight;

    self.descriptionViewMinHeightConstraint.constant = minHeight;
    
    [self layoutIfNeeded];
}

- (void)setShortDescription:(NSString *)shortDescription
{
    self.shortDescriptionTextView.attributedText = [self attributedTextFromHTMLString:shortDescription withFont:self.shortDescriptionTextView.font styles:@[@"text-align: center;"]];
    _shortDescription = shortDescription;
}

- (void)setFontColor:(UIColor *)fontColor
{
    self.shortDescriptionTextView.textColor = fontColor;
    _fontColor = fontColor;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImageURL:(NSURL *)imageURL
{
    [self.imageView setImageWithURL:imageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

- (NSAttributedString *)attributedTextFromHTMLString:(NSString *)htmlString withFont:(UIFont *)font styles:(NSArray *)styles
{
    NSMutableArray *mutableStyles = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"font-family: '%@';", font.fontName],
                         [NSString stringWithFormat:@"font-size: %0.1fpx;", roundf(font.pointSize)],
                         @"line-height: 21px;", nil];
    [mutableStyles addObjectsFromArray:styles];
    
    NSString *html = [NSString stringWithFormat:@"<div style=\"%@\">%@<div>", [mutableStyles componentsJoinedByString:@" "], htmlString];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    return attributedString;
}

- (void)setLongDescription:(NSString *)longDescription
{
    self.longDescriptionTextView.attributedText = [self attributedTextFromHTMLString:longDescription withFont:self.longDescriptionTextView.font styles:nil];
    _longDescription = longDescription;
}

- (void)setLiked:(BOOL)liked {
    if (liked) {
        self.discarded = NO;
    }
    
    _liked = liked;
}

- (void)setDiscarded:(BOOL)discarded {
    if (discarded) {
        self.liked = NO;
    }
    
    _discarded = discarded;
}

- (void)setUseCloseButton:(BOOL)useCloseButton {
    _useCloseButton = useCloseButton;
    self.closeButton.hidden = !self.useCloseButton;
}

- (void)setTerms:(NSString *)terms
{
    _terms = terms;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:terms attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
    
    self.termsLabel.attributedText = attrText;
}

- (void)setCard:(RVCard *)card
{
    self.title = card.title;
    self.shortDescription = card.shortDescription;
    
    if (card.longDescription) {
        self.longDescription = card.longDescription;
    }
    
    self.imageURL = card.imageURL;
    self.backgroundColor = card.primaryBackgroundColor;
    self.closeButton.color = card.primaryFontColor;
    self.fontColor = card.primaryFontColor;
    self.secondaryBackgroundColor = card.secondaryBackgroundColor;
    self.secondaryFontColor = card.secondaryFontColor;
    self.discarded = card.discardedAt != nil;
    
    // TODO: make this behave more like the barcode stuff
    if (card.terms) {
        self.terms = card.terms;
    } else {
        // This works for now because we aren't reusing cardViews
        [self.termsTitleView removeFromSuperview];
    }

    if (card.barcode) {
        [self addBarcode:card.barcode type:card.barcodeType.integerValue instructions:card.barcodeInstructions];
    }
    
    _card = card;
    
    self.liked = card.likedAt != nil;
    
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.fontColor = [UIColor whiteColor];
        self.footerHeight = 0;
    }
    return self;
}

- (void)addSubviews
{
    [super addSubviews];
    
    self.scrollView = [UIScrollView new];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.scrollEnabled = NO;
    [self.containerView addSubview:self.scrollView];
    
    self.contentView = [UIView new];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
    
    self.shortDescriptionTextView = [UILabel new];
    self.shortDescriptionTextView.numberOfLines = 4;
    self.shortDescriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.shortDescriptionTextView.font = [UIFont systemFontOfSize:16.0];
    self.shortDescriptionTextView.textAlignment = NSTextAlignmentCenter;
    self.shortDescriptionTextView.alpha = 0.7;
    self.shortDescriptionTextView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.shortDescriptionTextView];
    
    self.imageView = [UIImageView new];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.imageView];
    
    UIColor *beigeColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.5 blue:233.0/255.0 alpha:1.0];
    UIColor *bodyTextColor = [UIColor colorWithRed:124/255.f green:124/255.f blue:124/255.f alpha:1];
    
    self.longDescriptionTextView = [UITextView new];
    self.longDescriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.longDescriptionTextView.font = [UIFont systemFontOfSize:14.0];
    self.longDescriptionTextView.scrollEnabled = NO;
    self.longDescriptionTextView.editable = NO;
    self.longDescriptionTextView.alpha = 0.0;
    self.longDescriptionTextView.textContainerInset = UIEdgeInsetsMake(20.0, 26.0, 0.0, 26.0);
    self.longDescriptionTextView.backgroundColor = [UIColor clearColor];
    self.longDescriptionTextView.textColor = bodyTextColor;
    
    self.closeButton = [[RVCloseButton alloc] initWithFrame:CGRectMake(272.0, 24.0, 44.0, 44.0)];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.alpha = 0.0;
    [self.contentView addSubview:self.closeButton];
    
    self.termsView = [UIView new];
    self.termsView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.termsLabel = [UILabel new];
    self.termsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.termsLabel.numberOfLines = 0;
    self.termsLabel.font = [UIFont systemFontOfSize:13];
    self.termsLabel.textAlignment = NSTextAlignmentJustified;
    self.termsLabel.textColor = bodyTextColor;
    [self.termsView addSubview:self.termsLabel];
    
    self.termsTitleView = [UIView new];
    self.termsTitleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.termsView addSubview:self.termsTitleView];
    
    UIColor *titleBarColor = [UIColor colorWithRed:172/255.f green:172/255.f blue:172/255.f alpha:1.0];
    
    self.termsTitleLineLeft = [UIView new];
    self.termsTitleLineLeft.translatesAutoresizingMaskIntoConstraints = NO;
    self.termsTitleLineLeft.alpha = 0.5;
    self.termsTitleLineLeft.backgroundColor = titleBarColor;
    [self.termsTitleView addSubview:self.termsTitleLineLeft];
    
    self.termsTitleLineRight = [UIView new];
    self.termsTitleLineRight.translatesAutoresizingMaskIntoConstraints = NO;
    self.termsTitleLineRight.alpha = 0.5;
    self.termsTitleLineRight.backgroundColor = titleBarColor;
    [self.termsTitleView addSubview:self.termsTitleLineRight];
    
    self.termsTitle = [UILabel new];
    self.termsTitle.translatesAutoresizingMaskIntoConstraints = NO;
    self.termsTitle.font = [UIFont boldSystemFontOfSize:13.0];
    self.termsTitle.textAlignment = NSTextAlignmentCenter;
    self.termsTitle.text = @"Terms & Conditions";
    self.termsTitle.textColor = [UIColor colorWithRed:73/255.f green:73/255.f blue:73/255.f alpha:1];
    [self.termsTitleView addSubview:self.termsTitle];
    
    self.descriptionView = [UIView new];
    self.descriptionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionView.backgroundColor = beigeColor;
    [self.descriptionView addSubview:self.longDescriptionTextView];
    [self.descriptionView addSubview:self.termsView];
    [self.contentView addSubview:self.descriptionView];
    
    self.barcodeView = [UIView new];
    self.barcodeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.barcodeView.backgroundColor = [UIColor whiteColor];
    [self.descriptionView addSubview:self.barcodeView];
}

- (void)configureLayout
{
    [super configureLayout];
    
    NSDictionary *views = @{ @"contentView": self.contentView,
                             @"scrollView": self.scrollView,
                             @"shortDescriptionTextView": self.shortDescriptionTextView,
                             @"imageView": self.imageView,
                             @"longDescriptionTextView": self.longDescriptionTextView,
                             @"termsView": self.termsView,
                             @"termsLabel": self.termsLabel,
                             @"termsTitleLineLeft": self.termsTitleLineLeft,
                             @"termsTitleLineRight": self.termsTitleLineRight,
                             @"termsTitle": self.termsTitle,
                             @"termsTitleView": self.termsTitleView,
                             @"descriptionView": self.descriptionView,
                             @"barcodeView": self.barcodeView,
                             @"closeButton": self.closeButton
                             };
    
    //----------------------------------------
    //  scrollView
    //----------------------------------------
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]" options:0 metrics:nil views:views]];
    
    self.scrollViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10];
    [self.containerView addConstraint:self.scrollViewBottomConstraint];
    
    
    //----------------------------------------
    //  contentView
    //----------------------------------------
    
    // Content view fills the scroll view and inherintly sets the scroll view's content size
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentView]|" options:0 metrics:nil views:views]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
    
    // Set the contentView's width
    self.contentViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:[self contractedWidth]];
    [self.scrollView addConstraint:self.contentViewWidthConstraint];
    
    
    //----------------------------------------
    //  shortDescription
    //----------------------------------------
    
    // Horizontal spacing of shortDescription
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shortDescriptionTextView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[shortDescriptionTextView(250)]" options:0 metrics:nil views:views]];
    
    // Height of shortDescription
    CGFloat height = 109;
    self.shortDescriptionHeightConstraint = [NSLayoutConstraint constraintWithItem:self.shortDescriptionTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:height];
    [self.contentView addConstraint:self.shortDescriptionHeightConstraint];
    
    // Pin the short description to the title bar
    self.shortDescriptionTopConstraint = [NSLayoutConstraint constraintWithItem:self.shortDescriptionTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeBottom multiplier:1.0 constant:18.0];
    [self.contentView addConstraint:self.shortDescriptionTopConstraint];
    
    //----------------------------------------
    //  imageView
    //----------------------------------------
    
    // Horizontal spacing of imageView
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView]|" options:0 metrics:nil views:views]];
    
    // Height of imageView
    self.imageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:175.0];
    [self.contentView addConstraint:self.imageViewHeightConstraint];
    
    // Top position of imageView
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.shortDescriptionTextView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20.0]];
    
    
    //----------------------------------------
    //  longDescription
    //----------------------------------------
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[descriptionView]|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[descriptionView]|" options:0 metrics:nil views:views]];
    
    // Horizontal spacing of longDescription
    [self.descriptionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[longDescriptionTextView]|" options:0 metrics:nil views:views]];
    
    // Tie the bottom edge of longDescription to the contentView
    [self.descriptionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[barcodeView][longDescriptionTextView][termsView]|" options:0 metrics:nil views:views]];
    
    // Set the longDescription's minimum height so it always extends to the bottom edge of the screen
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat minHeight = screenBounds.size.height - height - (screenBounds.size.width * kRVCardViewImageRatio);
    self.descriptionViewMinHeightConstraint = [NSLayoutConstraint constraintWithItem:self.descriptionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0 constant:minHeight];
    [self.contentView addConstraint:self.descriptionViewMinHeightConstraint];
    
    // Top position of longDescription
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];

    //----------------------------------------
    //  barcodeView
    //----------------------------------------
    
    [self.descriptionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[barcodeView]|" options:0 metrics:nil views:views]];
    
    //----------------------------------------
    //  termsView
    //----------------------------------------
    
    [self.termsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[termsTitleView]-12-[termsLabel]->=12-|" options:0 metrics:nil views:views]];
    [self.termsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[termsTitleView]|" options:0 metrics:nil views:views]];
    
    [self.descriptionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[termsView]|" options:0 metrics:nil views:views]];
    [self.termsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-26-[termsLabel]-26-|" options:0 metrics:nil views:views]];
    [self.termsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[termsTitleView(20)]" options:0 metrics:nil views:views]];
    
    // terms title
    [self.termsTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[termsTitleLineLeft]-12-[termsTitle]-12-[termsTitleLineRight]|" options:0 metrics:nil views:views]];
    [self.termsTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[termsTitleLineLeft(1)]" options:0 metrics:nil views:views]];
    [self.termsTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[termsTitleLineRight(1)]" options:0 metrics:nil views:views]];
    [self.termsTitleView addConstraint:[NSLayoutConstraint constraintWithItem:self.termsTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.termsTitleView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.termsTitleView addConstraint:[NSLayoutConstraint constraintWithItem:self.termsTitleLineLeft attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.termsTitleView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.termsTitleView addConstraint:[NSLayoutConstraint constraintWithItem:self.termsTitleLineRight attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.termsTitleView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.termsTitleView addConstraint:[NSLayoutConstraint constraintWithItem:self.termsTitle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.termsTitleView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    //----------------------------------------
    //  closeButton
    //----------------------------------------
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[closeButton(44)]-0-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[closeButton(44)]" options:0 metrics:nil views:views]];
}

#pragma mark - Button Actions

- (void)closeButtonPressed {
    if ([self.delegate respondsToSelector:@selector(cardViewCloseButtonPressed:)]) {
        [self.delegate cardViewCloseButtonPressed:self];
    } else if ([self.delegate respondsToSelector:@selector(cardViewMoreButtonPressed:)]) {
        [self.delegate cardViewMoreButtonPressed:self];
    }
}

#pragma mark - Expand/Contract

- (void)didShow
{
    self.moreButtonTopConstraint.constant = 0.0;
    [UIView animateWithDuration:0.1 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)expandToFrame:(CGRect)frame animated:(BOOL)animated
{
    self.moreButtonTopConstraint.constant = 25.0;
    self.contentViewWidthConstraint.constant = frame.size.width;
    self.imageViewHeightConstraint.constant = frame.size.width * kRVCardViewImageRatio;
    self.shortDescriptionTopConstraint.constant = 25;
    self.scrollViewBottomConstraint.constant = -self.footerHeight;
    
    [super expandToFrame:frame animated:animated];
}

- (void)contractToFrame:(CGRect)frame atCenter:(CGPoint)center animated:(BOOL)animated
{
    self.moreButtonTopConstraint.constant = 0.0;
    self.contentViewWidthConstraint.constant = frame.size.width;
    self.imageViewHeightConstraint.constant = 175.0;
    self.shortDescriptionTopConstraint.constant = 18;
    self.scrollViewBottomConstraint.constant = -MAX(10, self.footerHeight);
    
    if (animated) {
        [UIView animateWithDuration:0.15 animations:^{
            self.closeButton.alpha = 0.0;
        }];
    }
    
    [self.scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:animated];
    
    [super contractToFrame:frame atCenter:center animated:animated];
    
}

// TODO: use blocks for these

- (void)expandAnimations
{
    self.longDescriptionTextView.alpha = 1.0;
}

- (void)expandCompletion
{
    self.scrollView.scrollEnabled = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.closeButton.alpha = 1.0;
    }];
}

- (void)contractAnimations
{
    self.longDescriptionTextView.alpha = 0.0;
}

- (void)contractCompletion
{
    self.scrollView.scrollEnabled = NO;
}

#pragma mark - Barcode

- (void)addBarcode:(NSString *)barcode type:(NSUInteger)type instructions:(NSString *)instructions
{
    UIImage *barcodeImage = [RVCardView barcodeImageForCode:barcode type:type == 1 ? AVMetadataObjectTypeCode128Code : @"PLU"];
    UIImageView *barcodeImageView = [[UIImageView alloc] initWithImage:barcodeImage];
    barcodeImageView.translatesAutoresizingMaskIntoConstraints = NO;
    barcodeImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel *barcodeInstructionLabel = [UILabel new];
    barcodeInstructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    barcodeInstructionLabel.text = instructions;
    barcodeInstructionLabel.font = self.longDescriptionTextView.font;
    barcodeInstructionLabel.textColor = [UIColor blackColor];
    barcodeInstructionLabel.numberOfLines = 1;
    barcodeInstructionLabel.textAlignment = NSTextAlignmentCenter;
    

    NSDictionary *views = @{@"barcodeImageView": barcodeImageView,
                            @"barcodeInstructionLabel": barcodeInstructionLabel};
    
    [self.barcodeView addSubview:barcodeInstructionLabel];
    [self.barcodeView addSubview:barcodeImageView];
    
    [self.barcodeView addConstraint:[NSLayoutConstraint constraintWithItem:barcodeInstructionLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.barcodeView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.barcodeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[barcodeInstructionLabel]-(-20)-[barcodeImageView(140)]|" options:0 metrics:nil views:views]];
    [self.barcodeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[barcodeImageView]|" options:0 metrics:nil views:views]];
    //[self.barcodeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[barcodeInstructionLabel]|" options:0 metrics:nil views:views]];

}

@end
