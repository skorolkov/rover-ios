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

+ (NSArray *)constraintsForBlockView:(RXBlockView *)blockView withPreviousBlockView:(RXBlockView *)previousBlockView inside:(UIView *)containerView;

- (instancetype)initWithBlock:(RVBlock *)block;
 
@end
