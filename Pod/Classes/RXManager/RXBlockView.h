//
//  RXBlockView.h
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import <UIKit/UIKit.h>

@class RVBlock;

@interface RXBlockView : UIView

+ (NSArray *)constraintsForBlockView:(UIView *)blockView withPreviousBlockView:(UIView *)previousBlockView inside:(UIView *)containerView;

+ (UIView *)viewForBlock:(RVBlock *)block;

- (instancetype)initWithBlock:(RVBlock *)block;
 
@end
