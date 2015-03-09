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

//#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>

UIViewContentMode UIViewContentModeFromRVBackgroundContentMode(RVBackgroundContentMode backgroundContentMode) {
    switch (backgroundContentMode) {
        case RVBackgroundContentModeScaleAspectFill:
            return UIViewContentModeScaleAspectFill;
            break;
        case RVBackgroundContentModeScaleAspectFit:
            return UIViewContentModeScaleAspectFit;
            break;
        case RVBackgroundContentModeScaleFill:
            return UIViewContentModeScaleToFill;
            break;
        default:
            return UIViewContentModeTop;
            break;
    }
}

@interface RXBlockView ()

@property (assign, nonatomic) UIEdgeInsets borderWidth;
@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) NSURL *url;

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

+ (UIImageView *)imageViewForBlock:(RVImageBlock *)block {
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    //[imageView setImageWithURL:block.imageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [imageView sd_setImageWithURL:block.imageURL];
    [imageView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeWidth multiplier:1/block.aspectRatio constant:0]];

    return imageView;
}

+ (UITextView *)textViewForBlock:(RVTextBlock *)block {
    UITextView *textView = [UITextView new];
    textView.backgroundColor = [UIColor clearColor];
    textView.attributedText = block.htmlText;
    textView.scrollEnabled = NO;
    textView.editable = NO;
    textView.userInteractionEnabled = NO;
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.textContainer.lineFragmentPadding = 0;

    return textView;
}

+ (UIView *)barcodeViewForBlock:(RVBarcodeBlock *)block {
    return [UIView new];
}

+ (UIView *)buttonViewForBlock:(RVButtonBlock *)block {
    UIView *buttonView = [UIView new];
    
    UITextView *titleView = [UITextView new];
    titleView.translatesAutoresizingMaskIntoConstraints = NO;
    titleView.backgroundColor = [UIColor clearColor];
    titleView.scrollEnabled = NO;
    titleView.editable = NO;
    titleView.userInteractionEnabled = NO;
    titleView.textContainerInset = UIEdgeInsetsZero;
    titleView.textContainer.lineFragmentPadding = 0;
    titleView.attributedText = block.label;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(titleView);
    
    [buttonView addSubview:titleView];
    [buttonView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[titleView]|" options:0 metrics:nil views:views]];
    [buttonView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleView]|" options:0 metrics:nil views:views]];
    
    return  buttonView;
}

+ (UIView *)headerViewForBlock:(RVHeaderBlock *)block {
    UIView *headerView = [UIView new];
    
    UILabel *titleView = [UILabel new];
    titleView.translatesAutoresizingMaskIntoConstraints = NO;
    titleView.backgroundColor = [UIColor clearColor];
    titleView.attributedText = block.title;
    titleView.numberOfLines = 1;
    titleView.lineBreakMode = NSLineBreakByTruncatingTail;
    titleView.adjustsFontSizeToFitWidth = YES;
    titleView.minimumScaleFactor = .3;
    
    [headerView addSubview:titleView];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:10]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:titleView attribute:NSLayoutAttributeHeight multiplier:1 constant:20]];
    //[headerView addConstraint:[NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:headerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    return headerView;
}

- (instancetype)initWithBlock:(RVBlock *)block {
    self = [self init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.clipsToBounds = YES;
        
        // backgroundColor
        self.backgroundColor = block.backgroundColor;
        
        // backgroundImage
        if (block.backgroundImageURL) {
            __weak typeof(self) weakSelf = self;
            if (block.backgroundContentMode == RVBackgroundContentModeTile) {
//                [[SDWebImageManager sharedManager] downloadImageWithURL:block.backgroundImageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                    weakSelf.backgroundColor = [UIColor colorWithPatternImage:image];
//                }];
            } else {
                UIImageView *backgroundImageView = [UIImageView new];
                backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
                backgroundImageView.contentMode = UIViewContentModeFromRVBackgroundContentMode(block.backgroundContentMode);
                [backgroundImageView sd_setImageWithURL:block.backgroundImageURL];
                
                [self addSubview:backgroundImageView];
                
                NSDictionary *views = NSDictionaryOfVariableBindings(backgroundImageView);
                
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundImageView]|" options:0 metrics:nil views:views]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImageView]|" options:0 metrics:nil views:views]];
            }
        }
        
        UIView *contentView = [RXBlockView viewForBlock:block];
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
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
            //[self addGestureRecognizer:tapGestureRecognizer];
            self.url = block.url;
        //}
    }
    return self;
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

#pragma mark - TapGestureRecognizer Action

- (void)tapped:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(shouldOpenURL:)]) {
        if ([self.delegate shouldOpenURL:self.url]) {
            [[UIApplication sharedApplication] openURL:self.url];
        }
    }
}

@end
