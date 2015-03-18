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

#import "Rover.h"

//#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>

#define kContentViewTag 500
#define kButtonTitleViewTag 600


@interface RXBlockView () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) UIEdgeInsets borderWidth;
@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) NSURL *url;

@property (nonatomic, strong) UIGestureRecognizer *gestureRecognizer;

@end

@implementation RXBlockView

+ (NSArray *)constraintsForBlockView:(UIView *)blockView withPreviousBlockView:(UIView *)previousBlockView inside:(UIView *)containerView{
    return @[
             [NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
             [NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeRight multiplier:1 constant:0],
             [NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:previousBlockView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]
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

+ (UIView *)imageViewForBlock:(RVImageBlock *)block {
    UIView *imageContainerView = [UIView new];
    
    UIImageView *imageView = [UIImageView new];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    //[imageView setImageWithURL:block.imageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [imageView sd_setImageWithURL:block.imageURL];
    [imageView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeWidth multiplier:1/block.aspectRatio constant:0]];

    [imageContainerView addSubview:imageView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(imageView);
    
    [imageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView]|" options:0 metrics:nil views:views]];
    [imageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views]];
    
    return imageContainerView;
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
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:10]];
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
        _borderColor = block.borderColor;
        _borderWidth = block.borderWidth;
        
        // Link
        //if (block.url) {
            // TODO: add touchdown states and stuff
//            UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
//            longPressGestureRecognizer.minimumPressDuration = 0;
//        //longPressGestureRecognizer.cancelsTouchesInView = NO;
//        longPressGestureRecognizer.delegate = self;
//        _gestureRecognizer = longPressGestureRecognizer;
//            [self addGestureRecognizer:longPressGestureRecognizer];
//        UIButton *invisibleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        invisibleButton.translatesAutoresizingMaskIntoConstraints = NO;
//        [invisibleButton addTarget:self action:@selector(makeBlockTransparent:) forControlEvents:UIControlEventTouchDown];
//        [invisibleButton addTarget:self action:@selector(blockTouchUp:) forControlEvents:UIControlEventTouchUpInside];
//        [invisibleButton addTarget:self action:@selector(resetBlockOpacity:) forControlEvents:UIControlEventTouchUpOutside];
//        
//        [self addSubview:invisibleButton];
//        
//        NSDictionary *buttonViews = NSDictionaryOfVariableBindings(invisibleButton);
//        
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[invisibleButton]|" options:0 metrics:nil views:buttonViews]];
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[invisibleButton]|" options:0 metrics:nil views:buttonViews]];
        
        self.url = block.url;
        //}
        
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
    }
}


- (void)drawRect:(CGRect)rect {
    // Draw borders
    CGFloat xMin = CGRectGetMinX(rect);
    CGFloat xMax = CGRectGetMaxX(rect);
    
    CGFloat yMin = CGRectGetMinY(rect);
    CGFloat yMax = CGRectGetMaxY(rect);
    
    CGFloat fWidth = self.frame.size.width;
    CGFloat fHeight = self.frame.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, _borderColor.CGColor);
    
    if (_borderWidth.left) {
        CGContextFillRect(context, CGRectMake(xMin, yMin, _borderWidth.left, fHeight));
    }
    
    if (_borderWidth.right) {
        CGContextFillRect(context, CGRectMake(xMax - _borderWidth.right, yMin, _borderWidth.right, fHeight));
    }
    
    if (_borderWidth.bottom) {
        CGContextFillRect(context, CGRectMake(xMin, yMax - _borderWidth.bottom, fWidth, _borderWidth.bottom));
    }
    
    if (_borderWidth.top) {
        CGContextFillRect(context, CGRectMake(xMin, yMin, fWidth, _borderWidth.top));
    }
}

#pragma mark - ButtonEvents

- (void)makeBlockTransparent:(id)sender {
    self.alpha = .5;
}

- (void)resetBlockOpacity:(id)sender {
    self.alpha = 1;
}

- (void)blockTouchUp:(id)sender {
    [self resetBlockOpacity:sender];
    NSLog(@"Clicked");
}

#pragma mark - LongPressGestureRecognizer Action

- (void)tapped:(UILongPressGestureRecognizer *)recognizer {
    static UIView *titleSubview;
    NSLog(@"received");
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
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
                NSLog(@"tapped");
                titleSubview.alpha = 1;
                titleSubview = nil;
            }
            break;
        default:
            break;
    }
//    if ([self.delegate respondsToSelector:@selector(blockview:shouldOpenURL:)]) {
//        if ([self.delegate blockview:self shouldOpenURL:self.url]) {
//            [[UIApplication sharedApplication] openURL:self.url];
//        }
//    }
}

#pragma mark - CloseButton Action

+ (void)closeMe:(id)sender {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentViewController = [Rover findCurrentViewController:rootViewController];
    [currentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]] && otherGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        gestureRecognizer.enabled = NO;
        return YES;
    }
    gestureRecognizer.enabled = YES;
    return [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]];
}

@end
