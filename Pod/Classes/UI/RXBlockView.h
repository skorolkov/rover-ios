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

/** A UIView subclass that represents a block from the Rover console.
 */
@interface RXBlockView : UIView

/** Returns an NSArray of NSLayoutConstraints.
 @param blockView The RXBlockView to generate constraints for.
 @param previousBlockView The previous RXBlockView to pin to.
 @param containerView The UIView superview containing the block.
 */
+ (NSArray *)constraintsForBlockView:(UIView *)blockView withPreviousBlockView:(UIView *)previousBlockView inside:(UIView *)containerView;

/** Returns a UIView appropriate for the passed in block.
 */
+ (UIView *)viewForBlock:(RVBlock *)block;

/** Delegate that gets notified of block events.
 */
@property (nonatomic, assign) id<RXBlockViewDelegate> delegate;

/** The block model that describes this view.
 */
@property (nonatomic, weak, readonly) RVBlock *block;

/** Designated initializer
*/
 - (instancetype)initWithBlock:(RVBlock *)block;

@end

@protocol RXBlockViewDelegate <NSObject>

@optional
/** Called when user clicks on the block. If this delegate is implemented and returns NO, nothing will happen.
 If YES is returned then [[UIApplication sharedApplication] openURL:url] is called.
 @param url The NSURL to navigate to.
 */
- (BOOL)blockview:(RXBlockView *)blockview shouldOpenURL:(NSURL *)url;

@end
