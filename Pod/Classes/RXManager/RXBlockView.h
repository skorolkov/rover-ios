//
//  RXBlockView.h
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import <UIKit/UIKit.h>

@class RVBlock;
@protocol RXBlockViewDelegate;

@interface RXBlockView : UIView

+ (NSArray *)constraintsForBlockView:(UIView *)blockView withPreviousBlockView:(UIView *)previousBlockView inside:(UIView *)containerView;
+ (UIView *)viewForBlock:(RVBlock *)block;

@property (nonatomic, assign) id<RXBlockViewDelegate> delegate;

- (instancetype)initWithBlock:(RVBlock *)block;
 
@end

@protocol RXBlockViewDelegate <NSObject>

@optional
- (BOOL)shouldOpenURL:(NSURL *)url;

@end
