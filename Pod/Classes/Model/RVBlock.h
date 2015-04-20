//
//  RVBlock.h
//  Pods
//
//  Created by Ata Namvari on 2015-02-12.
//
//

#import "RVModel.h"
#import <UIKit/UIKit.h>
#import "RVBackgroundImage.h"

typedef NS_ENUM(NSInteger, RVBlockType) {
    RVBlockImageType,
    RVBlockTextType,
    RVBlockBarcodeType,
    RVBlockButtonType,
    RVBlockHeaderType
};

@interface RVBlock : RVModel <RVBackgroundImage>

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) UIEdgeInsets borderWidth;
@property (nonatomic, assign) UIEdgeInsets padding;
@property (nonatomic, assign, readonly) RVBlockType blockType;
@property (nonatomic, strong) NSURL *url;

- (CGFloat)heightForWidth:(CGFloat)width;
- (CGFloat)paddingAdjustedValueForWidth:(CGFloat)width;

@end
