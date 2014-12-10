//
//  RVCardBaseView.m
//  Rover
//
//  Created by Ata Namvari on 2014-10-13.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardBaseView.h"

#import <RSBarcodes/RSBarcodes.h>

#define IS_WIDESCREEN ([[UIScreen mainScreen] bounds].size.height == 568.0)



@interface RVCardBaseView () <UIGestureRecognizerDelegate> {
    CGRect _expandedFrame;
}

@property (nonatomic, getter=isExpanded) BOOL expanded;

@property (strong, nonatomic) UIView *shadowView;

@end

@implementation RVCardBaseView


#pragma mark - Size Methods

- (CGFloat)contractedWidth {
    return 280.0;
}

- (CGFloat)contractedHeight {
    return 292.0;
}

#pragma mark - Public Properties

- (void)setShadow:(CGFloat)shadow
{
    self.shadowView.layer.opacity = shadow;
    _shadow = shadow;
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    [self addSubview:backgroundView];
    [self sendSubviewToBack:backgroundView];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundView = backgroundView;
    [self configureBackgroundViewLayout];
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
        self.expandable = YES;
        //self.useCloseButton = NO;
        self.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:111.0/255.0 blue:203.0/255.0 alpha:1.0];
        
        [self layoutIfNeeded];
    }
    return self;
}

- (void)addSubviews
{
    self.containerView = [UIView new];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.containerView];

    self.shadowView = [[UIView alloc] initWithFrame:self.frame];
    self.shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    self.shadowView.backgroundColor = [UIColor blackColor];
    self.shadowView.alpha = 0.0;
    self.shadowView.userInteractionEnabled = NO;
    [self addSubview:self.shadowView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTapped)];
    tapGestureRecognizer.delegate = self;
    [self.containerView addGestureRecognizer:tapGestureRecognizer];
    
}

- (void)configureLayout
{
    NSDictionary *views = @{@"shadowView": self.shadowView,
                            @"containerView": self.containerView};
    
    //----------------------------------------
    //  containerView
    //----------------------------------------
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    self.containerViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:self.isExpanded ? _expandedFrame.size.width : self.contractedWidth];
    [self addConstraint:self.containerViewWidthConstraint];
    
    self.containerViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:self.isExpanded ? _expandedFrame.size.height : self.contractedHeight];
    [self addConstraint:self.containerViewHeightConstraint];
    
    //----------------------------------------
    //  shadowView
    //----------------------------------------
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[shadowView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[shadowView]|" options:0 metrics:nil views:views]];

}

- (void)configureBackgroundViewLayout
{
    NSDictionary *views = @{@"backgroundView": self.backgroundView};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|" options:0 metrics:nil views:views]];
}

#pragma mark - Expand/Contract

- (void)didShow
{

}

- (void)expandToFrame:(CGRect)frame animated:(BOOL)animated
{
    self.containerViewHeightConstraint.constant = frame.size.height;
    self.containerViewWidthConstraint.constant = frame.size.width;
    
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
    self.containerViewHeightConstraint.constant = frame.size.height;
    self.containerViewWidthConstraint.constant = frame.size.width;

    
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view.superview isKindOfClass:[UIToolbar class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - Barcode Helpers

+ (UIImage *)barcodeImageForCode:(NSString *)code type:(NSString *)type
{
    if ([type isEqualToString:@"PLU"]) {
        return [RVCardBaseView imageWithPLUCode:code];
    } else {
        return [RVCardBaseView imageWithStandardBarcode:code withType:type];
    }
}

+ (UIImage *)imageWithPLUCode:(NSString *)code
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(560, 350), NO, [UIScreen mainScreen].scale);
    
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:126],
                                     NSForegroundColorAttributeName: [UIColor blackColor]
                                     };
    
    CGSize textSize = [code boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:textAttributes context:nil].size;
    
    [code drawAtPoint:CGPointMake(280 - (textSize.width / 2), 110) withAttributes:textAttributes];
    
    [@"PLU" drawAtPoint:CGPointMake(245, 60) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:36],
                                                              NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    UIImage *PLUImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return PLUImage;
}

+ (UIImage *)imageWithStandardBarcode:(NSString *)code withType:(NSString *)barcodeType
{
    UIImage *codeImage = [CodeGen genCodeWithContents:code machineReadableCodeObjectType:barcodeType];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(560, 350), NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextDrawImage(context, CGRectMake(20, 75, 520, 200), [codeImage CGImage]);

    // text
    NSDictionary *textAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:34],
                                     NSForegroundColorAttributeName: [UIColor darkGrayColor],
                                     NSKernAttributeName: @10.f};
    CGSize textSize = [code boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:textAttributes context:nil].size;
    [code drawAtPoint:CGPointMake(280 - (textSize.width / 2), 280) withAttributes:textAttributes];
    
    CGContextRestoreGState(context);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
