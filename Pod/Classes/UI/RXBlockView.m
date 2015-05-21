//
//  RXBlockView.m
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import "RXBlockView.h"
#import "RVBlock.h"

#import "RVHeaderBlock.h"
#import "RVTextBlock.h"
#import "RVImageBlock.h"
#import "RVBarcodeBlock.h"
#import "RVButtonBlock.h"

#import "RXBarcodeView.h"
#import "RXCloseButton.h"
#import "RXTextView.h"

#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

#define kContentViewTag 500
#define kButtonTitleViewTag 600


@interface RXBlockView () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) UIEdgeInsets borderWidth;
@property (strong, nonatomic) UIColor *borderColor;
@property (copy, nonatomic) NSURL *url;

@property (nonatomic, strong) UIGestureRecognizer *gestureRecognizer;

@end

@implementation RXBlockView

+ (NSArray *)constraintsForBlockView:(UIView *)blockView withPreviousBlockView:(UIView *)previousBlockView inside:(UIView *)containerView{
    NSLayoutConstraint *topConstraint;
    
    if (previousBlockView) {
        topConstraint = [NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:previousBlockView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    } else {
        topConstraint = [NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    }
    
    return @[
             [NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
             [NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeRight multiplier:1 constant:0],
             topConstraint
             ];
}

+ (UIView *)viewForBlock:(RVBlock *)block {
    UIView *blockView;
    
    if (block.class == [RVImageBlock class]) {
        blockView = [self imageViewForBlock:(RVImageBlock *)block];
    } else if (block.class == [RVTextBlock class]) {
        blockView = [self textViewForBlock:(RVTextBlock *)block];
    } else if (block.class == [RVBarcodeBlock class]) {
        blockView = [self barcodeViewForBlock:(RVBarcodeBlock *)block];
    } else if (block.class == [RVButtonBlock class]) {
        blockView = [self buttonViewForBlock:(RVButtonBlock *)block];
    } else if (block.class == [RVHeaderBlock class]) {
        blockView = [self headerViewForBlock:(RVHeaderBlock *)block];
    }

    blockView.translatesAutoresizingMaskIntoConstraints = NO;
    blockView.clipsToBounds = YES;
    
    return blockView;
}

#pragma mark - BlockView Content Constructors

+ (UIImageView *)imageViewForBlock:(RVImageBlock *)block {
    UIImageView *imageView = [UIImageView new];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView setImageWithURL:block.imageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //[imageView sd_setImageWithURL:block.imageURL];
    [imageView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeWidth multiplier:1.f/block.aspectRatio constant:0]];
    
    return imageView;
}

+ (RXTextView *)textViewForBlock:(RVTextBlock *)block {
    RXTextView *textView = [RXTextView new];
    textView.backgroundColor = [UIColor clearColor];
    textView.attributedText = block.htmlText;
    
    return textView;
}

+ (UIView *)barcodeViewForBlock:(RVBarcodeBlock *)block {
    return [[RXBarcodeView alloc] initWithCode:block.barcodeString type:block.barcodeType attributedLabel:block.barcodeLabelAttributedString];
}

+ (UIView *)buttonViewForBlock:(RVButtonBlock *)block {
    UIView *buttonView = [UIView new];
    
    RXTextView *titleView = [RXTextView new];
    titleView.translatesAutoresizingMaskIntoConstraints = NO;
    titleView.backgroundColor = [UIColor clearColor];
    titleView.tag = kButtonTitleViewTag;
    titleView.attributedText = block.label;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(titleView);
    
    [buttonView addSubview:titleView];
    [buttonView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[titleView]|" options:0 metrics:nil views:views]];
    [buttonView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleView]|" options:0 metrics:nil views:views]];
    
    return  buttonView;
}

+ (UIView *)headerViewForBlock:(RVHeaderBlock *)block {
    UIView *headerView = [UIView new];
    
    RXTextView *titleView = [RXTextView new];
    titleView.translatesAutoresizingMaskIntoConstraints = NO;
    titleView.backgroundColor = [UIColor clearColor];
    titleView.attributedText = block.title;

    RXCloseButton *closeButton = [RXCloseButton new];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    closeButton.color = [UIColor colorWithCGColor:[[block.title attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:0] CGColor]];
    [closeButton addTarget:self action:@selector(closeMe:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *spacer = [UIView new];
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(titleView, closeButton, spacer);
    
    [headerView addSubview:titleView];
    [headerView addSubview:closeButton];
    [headerView addSubview:spacer];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|-[spacer(%f)]-[titleView]-[closeButton]-10-|", closeButton.intrinsicContentSize.width + 10] options:0 metrics:nil views:views]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:10]];
    
    return headerView;
}

- (instancetype)initWithBlock:(RVBlock *)block {
    self = [self init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.clipsToBounds = YES;
        
        // Background Color
        self.backgroundColor = block.backgroundColor;
        
        // Background Image
        if (block.backgroundImageURL) {
            [self setBackgroundImageWithURL:block.backgroundImageURL contentMode:block.backgroundContentMode];
        }
        
        // Content
        UIView *contentView = [RXBlockView viewForBlock:block];
        contentView.tag = kContentViewTag;
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:contentView];
        
        // Padding
        NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|-%f-[contentView]-%f-|", block.padding.left, block.padding.right] options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[contentView]-%f-|", block.padding.top, block.padding.bottom] options:0 metrics:nil views:views]];
    
        // Borders
        [self setBorder:block.borderWidth color:block.borderColor];
        
        // Link
        if (block.url) {
            UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
            longPressGestureRecognizer.minimumPressDuration = 0;
            longPressGestureRecognizer.delegate = self;
            [self addGestureRecognizer:longPressGestureRecognizer];
            self.url = block.url;
        }
        
        _block = block;
    }
    return self;
}

- (void)setBackgroundImageWithURL:(NSURL *)url contentMode:(RVBackgroundContentMode)contentmode {
    __weak typeof(self) weakSelf = self;
    if (contentmode == RVBackgroundContentModeTile) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            weakSelf.backgroundColor = [UIColor colorWithPatternImage:image];
        }];
    } else {
        UIImageView *backgroundImageView = [UIImageView new];
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        backgroundImageView.contentMode = UIViewContentModeFromRVBackgroundContentMode(contentmode);
        [backgroundImageView sd_setImageWithURL:url];
        
        [self addSubview:backgroundImageView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(backgroundImageView);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundImageView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImageView]|" options:0 metrics:nil views:views]];

        [backgroundImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        [backgroundImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    }
}

- (void)setBorder:(UIEdgeInsets)borderWidth color:(UIColor *)color {
    if (borderWidth.left) {
        UIView *leftBorder = [UIView new];
        leftBorder.translatesAutoresizingMaskIntoConstraints = NO;
        leftBorder.backgroundColor = color;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(leftBorder);
        
        [self addSubview:leftBorder];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|[leftBorder(%f)]", borderWidth.left] options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftBorder]|" options:0 metrics:nil views:views]];
    }
    
    if (borderWidth.right) {
        UIView *rightBorder = [UIView new];
        rightBorder.translatesAutoresizingMaskIntoConstraints = NO;
        rightBorder.backgroundColor = color;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(rightBorder);
        
        [self addSubview:rightBorder];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"[rightBorder(%f)]|", borderWidth.right] options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightBorder]|" options:0 metrics:nil views:views]];
    }
    
    if (borderWidth.bottom) {
        UIView *bottomBorder = [UIView new];
        bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        bottomBorder.backgroundColor = color;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(bottomBorder);
        
        [self addSubview:bottomBorder];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[bottomBorder]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[bottomBorder(%f)]|", borderWidth.bottom] options:0 metrics:nil views:views]];
    }
    
    if (borderWidth.top) {
        UIView *topBorder = [UIView new];
        topBorder.translatesAutoresizingMaskIntoConstraints = NO;
        topBorder.backgroundColor = color;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(topBorder);
        
        [self addSubview:topBorder];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[topBorder]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[topBorder(%f)]", borderWidth.top] options:0 metrics:nil views:views]];
    }
}

#pragma mark - LongPressGestureRecognizer Action

- (void)tapped:(UILongPressGestureRecognizer *)recognizer {
    static UIView *titleSubview;
    static BOOL touchCancelled = NO;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            touchCancelled = NO;
            [recognizer.view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
                if (subview.tag == kContentViewTag) {
                    [subview.subviews enumerateObjectsUsingBlock:^(UIView *contentSubview, NSUInteger idx, BOOL *stop) {
                        if (contentSubview.tag == kButtonTitleViewTag) {
                            titleSubview = contentSubview;
                            titleSubview.alpha = .5;
                            *stop = YES;
                        }
                    }];
                    *stop = YES;
                }
            }];
            break;
        case UIGestureRecognizerStateEnded:
            if (titleSubview) {
                titleSubview.alpha = 1;
                titleSubview = nil;
            }
            if ([self.delegate respondsToSelector:@selector(blockview:shouldOpenURL:)] && !touchCancelled) {
                if ([self.delegate blockview:self shouldOpenURL:self.url]) {
                    [[UIApplication sharedApplication] openURL:self.url];
                }
            }
            break;
        default:
            if (titleSubview) {
                titleSubview.alpha = 1;
                titleSubview = nil;
            }
            touchCancelled = YES;
            break;
    }
}

#pragma mark - CloseButton Action

+ (void)closeMe:(id)sender {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentViewController = [self findCurrentViewController:rootViewController];
    [currentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Class Helpers

+ (UIViewController *)findCurrentViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        return [self findCurrentViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *svc = (UISplitViewController *)vc;
        if (svc.viewControllers.count > 0) {
            return [self findCurrentViewController:svc.viewControllers.lastObject];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nvc = (UINavigationController *)vc;
        if (nvc.viewControllers.count > 0) {
            return [self findCurrentViewController:nvc.topViewController];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tbc = (UITabBarController *)vc;
        if (tbc.viewControllers.count > 0) {
            return [self findCurrentViewController:tbc.selectedViewController];
        } else {
            return vc;
        }
    } else {
        return vc;
    }
}

@end
