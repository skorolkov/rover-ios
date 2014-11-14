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
#import "RVCardBarcodeView.h"
#import "RVCard.h"

#import <RSBarcodes/RSUnifiedCodeGenerator.h>

typedef enum : NSUInteger {
    RVButtonActionNone      =   0,
    RVButtonActionFavortie  =   1,
    RVButtonActionBarcode   =   2
} RVButtonAction;

@interface RVCardView()

@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) RVMoreButton *moreButton;
@property (strong, nonatomic) UITextView *longDescriptionTextView;
@property (strong, nonatomic) UIView *termsView;
@property (strong, nonatomic) UILabel *termsLabel;
@property (strong, nonatomic) UIView *termsTitleLineLeft;
@property (strong, nonatomic) UIView *termsTitleLineRight;
@property (strong, nonatomic) UILabel *termsTitle;
@property (strong, nonatomic) UIView *termsTitleView;
@property (strong, nonatomic) UIView *descriptionView;

// Close button
@property (strong, nonatomic) RVCloseButton *closeButton;

// BarcodeView
@property (strong, nonatomic) RVCardBarcodeView *barcodeView;

// Constraints
@property (strong, nonatomic) NSLayoutConstraint *cornerTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *cornerRightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *moreButtonTopConstraint;

@end

@implementation RVCardView

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

- (void)setShadow:(CGFloat)shadow
{
    self.shadowView.layer.opacity = shadow;
    _shadow = shadow;
}

- (void)setLongDescription:(NSString *)longDescription
{
    NSArray *styles = @[ @"font: -apple-system-body;",
                         @"font-size: 14px;",
                         @"line-height: 21px;"];
    
    NSString *html = [NSString stringWithFormat:@"<div style=\"%@\">%@<div>", [styles componentsJoinedByString:@" "], longDescription];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    self.longDescriptionTextView.attributedText = attributedString;
    
    _longDescription = longDescription;
}

- (void)setLiked:(BOOL)liked {
    if (liked) {
        self.discarded = NO;
    }

    if (self.card.buttons && self.card.buttons.count > 0 ) {
        NSNumber *buttonType = [self.card.buttons[0] objectForKey:@"button_type"];
        if (buttonType.integerValue == 1) {
            [self.buttonBar setPressed:liked forButton:self.buttonBar.leftButton];
        }
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
    self.fontColor = card.primaryFontColor;
    self.closeButton.color = card.primaryFontColor;
    self.secondaryBackgroundColor = card.secondaryBackgroundColor;
    self.secondaryFontColor = card.secondaryFontColor;
    self.discarded = card.discardedAt != nil;
    
    if (card.terms) {
        self.terms = card.terms;
    } else {
        // This works for now because we aren't reusing cardViews
        [self.termsTitleView removeFromSuperview];
    }
    
    if (card.barcode) {
        self.barcodeView = [[RVCardBarcodeView alloc] initWithFrame:self.frame];
        self.barcodeView.cardView = self;
        self.barcodeView.title = self.title;
        self.barcodeView.shortDescription = card.barcodeInstructions;
        [self.barcodeView setBarcode:card.barcode withType:card.barcodeType.integerValue == 1 ? AVMetadataObjectTypeCode128Code : @"PLU"];
    } else {
        self.barcodeView = nil;
    }
    
    
    // Buttons
    
    NSString *leftButtonTitle, *rightButtonTitle;
    NSString *leftButtonActiveTitle, *rightButtonActiveTitle;
    
    if (card.buttons && card.buttons.count > 0) {
        leftButtonTitle = [card.buttons[0] objectForKey:@"title"];
        leftButtonActiveTitle = [card.buttons[0] objectForKey:@"active_title"];
        
        if (card.buttons.count > 1) {
            rightButtonTitle = [card.buttons[1] objectForKey:@"title"];
            rightButtonActiveTitle = [card.buttons[1] objectForKey:@"active_title"];
        }
    }
    
    if ([leftButtonTitle isKindOfClass:[NSNull class]]) {
        leftButtonTitle = nil;
    }
    
    if ([rightButtonTitle isKindOfClass:[NSNull class]]) {
        rightButtonTitle = nil;
    }

    if ([rightButtonActiveTitle isKindOfClass:[NSNull class]]) {
        rightButtonActiveTitle = nil;
    }
    
    if ([leftButtonActiveTitle isKindOfClass:[NSNull class]]) {
        leftButtonActiveTitle = leftButtonTitle;
    }
    
    [self.buttonBar setLeftButtonTitle:leftButtonTitle andRightButtonTitle:rightButtonTitle];
    [self.buttonBar setFontColor:card.primaryFontColor];
    
    [self.buttonBar setPressedCaption:leftButtonActiveTitle forButton:self.buttonBar.leftButton];
    [self.buttonBar setPressedCaption:rightButtonActiveTitle forButton:self.buttonBar.rightButton];
    
    
    _card = card;
    
    self.liked = card.likedAt != nil;
    
}

#pragma mark - Initialization

- (void)addSubviews
{
    [super addSubviews];
    
    self.shadowView = [[UIView alloc] initWithFrame:self.frame];
    self.shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    self.shadowView.backgroundColor = [UIColor blackColor];
    self.shadowView.alpha = 0.0;
    self.shadowView.userInteractionEnabled = NO;
    [self addSubview:self.shadowView];
    
    self.moreButton = [RVMoreButton new];
    self.moreButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.moreButton.alpha = 1.0;
    [self.contentView addSubview:self.moreButton];
    [self.contentView sendSubviewToBack:self.moreButton];
    
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
    [self.containerView addSubview:self.closeButton];
    
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
}

- (void)configureLayout
{
    [super configureLayout];
    
    NSDictionary *views = @{ @"moreButton": self.moreButton,
                             @"shadowView": self.shadowView,
                             @"longDescriptionTextView": self.longDescriptionTextView,
                             @"termsView": self.termsView,
                             @"termsLabel": self.termsLabel,
                             @"termsTitleLineLeft": self.termsTitleLineLeft,
                             @"termsTitleLineRight": self.termsTitleLineRight,
                             @"termsTitle": self.termsTitle,
                             @"termsTitleView": self.termsTitleView,
                             @"descriptionView": self.descriptionView};
    
    //----------------------------------------
    //  shadowView
    //----------------------------------------
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[shadowView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[shadowView]|" options:0 metrics:nil views:views]];
    
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
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[descriptionView]|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[descriptionView]|" options:0 metrics:nil views:views]];
    
    // Horizontal spacing of longDescription
    [self.descriptionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[longDescriptionTextView]|" options:0 metrics:nil views:views]];
    
    // Tie the bottom edge of longDescription to the contentView
    [self.descriptionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[longDescriptionTextView][termsView]|" options:0 metrics:nil views:views]];
    
    // Set the longDescription's minimum height so it always extends to the bottom edge of the screen
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat minHeight = screenBounds.size.height - 344.0;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0 constant:minHeight]];
    
    // Top position of longDescription
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];

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
}

- (void)configureContainerLayout
{
    [super configureContainerLayout];
    
    NSDictionary *views = @{@"closeButton": self.closeButton};
    
    //----------------------------------------
    //  closeButton
    //----------------------------------------
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[closeButton(44)]-8-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[closeButton(44)]" options:0 metrics:nil views:views]];
}


#pragma mark - RVCardViewBarButtonDelegate

- (void)buttonBarLeftButtonPressed:(RVCardViewButtonBar *)buttonBar {
    if (self.card.buttons.count < 1) {
        return;
    }
    
    NSNumber *buttonType = [self.card.buttons[0] objectForKey:@"button_type"];
    [self performAction:buttonType.integerValue];
}

- (void)buttonBarRightButtonPressed:(RVCardViewButtonBar *)buttonBar {
    if (self.card.buttons.count < 2) {
        return;
    }
    
    NSNumber *buttonType = [self.card.buttons[1] objectForKey:@"button_type"];
    [self performAction:buttonType.integerValue];
}

#pragma mark - Button Actions

- (void)performAction:(RVButtonAction)action
{
    switch (action) {
        case RVButtonActionFavortie:
            [self likeButtonPressed];
            break;
        case RVButtonActionBarcode:
            [self barcodeButtonPressed];
            break;
        default:
            break;
    }
}

- (void)likeButtonPressed
{
    if (self.delegate) {
        [self.delegate cardViewLikeButtonPressed:self];
    }
}

- (void)barcodeButtonPressed
{
    if (self.isExpanded) {
        [self slideInBarcodeView];
    } else {
        [self flipCardToBarcodeView];
    }
    
    if ([self.delegate respondsToSelector:@selector(cardViewBarcodeButtonPressed:)]) {
        [self.delegate cardViewBarcodeButtonPressed:self];
    }
}

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
    
    [super expandToFrame:frame animated:animated];
    
    if (self.barcodeView) {
        [self.barcodeView expandToFrame:frame animated:NO];
    }
}

- (void)contractToFrame:(CGRect)frame atCenter:(CGPoint)center animated:(BOOL)animated
{
    self.moreButtonTopConstraint.constant = 0.0;
    
    if (animated) {
        [UIView animateWithDuration:0.15 animations:^{
            self.closeButton.alpha = 0.0;
        }];
    }
    
    [super contractToFrame:frame atCenter:center animated:animated];
    
    if (self.barcodeView) {
        [self.barcodeView contractToFrame:frame atCenter:center animated:NO];
    }
    
}

- (void)expandAnimations
{
    self.moreButton.alpha = 0.0;
    self.longDescriptionTextView.alpha = 1.0;
}

- (void)contractAnimations
{
    self.moreButton.alpha = 1.0;
    self.longDescriptionTextView.alpha = 0.0;
}

- (void)expandCompletion
{
    [UIView animateWithDuration:0.2 animations:^{
        self.closeButton.alpha = 1.0;
    }];
}

#pragma mark - Barcode Transitions

- (void)flipCardToBarcodeView
{
    self.barcodeView.frame = self.bounds;
    [UIView transitionWithView:self duration:0.4 options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [self.containerView removeFromSuperview];
                        [self addSubview:self.barcodeView];
                    }
                    completion:NULL];
}

- (void)slideInBarcodeView
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.layer addAnimation:transition forKey:nil];
    
    self.barcodeView.frame = self.bounds;
    [self.containerView removeFromSuperview];
    [self.barcodeView configureContainerLayout];
    [self addSubview:self.barcodeView];
}

@end
