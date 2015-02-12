//
//  RVBlock.h
//  Pods
//
//  Created by Ata Namvari on 2015-02-12.
//
//

#import "RVModel.h"

@class UIColor;

struct RVVector {
    CGFloat top;
    CGFloat bottom;
    CGFloat left;
    CGFloat right;
};
typedef struct RVVector RVVector;

@interface RVBlock : RVModel

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) RVVector borderWidth;
@property (nonatomic, assign) RVVector padding;

@end
