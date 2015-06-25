//
//  RXRecallButton.h
//  Pods
//
//  Created by Ata Namvari on 2015-06-02.
//
//

#import "RXDraggableView.h"

typedef NS_ENUM(NSInteger, RXRecallButtonPosition) {
    RXRecallButtonPositionBottomRight,
    RXRecallButtonPositionBottomLeft,
    RXRecallButtonPositionTopRight,
    RXRecallButtonPositionTopLeft
};

/** This is the recall button to bring the cards back up if the user dismisses them.
 */
@interface RXRecallButton : RXDraggableView

/** A read-only reference to the custom view inside the container.
 */
@property (nonatomic, strong, readonly) UIView *view;

/** Boolean value indicating if the recall button is currently visible on the screen.
 */
@property (nonatomic, readonly) BOOL isVisible;

/** The offscreen position for when the button is hidden.
 */
@property (nonatomic, readonly) CGPoint offscreenPosition;

/** Designated initializer.
 
 @param position The position to start off with.
 */
- (instancetype)initWithInitialPosition:(RXRecallButtonPosition)position;

/** Designated initializer.
 
 @param view Custom UIView to use inside the draggable container.
 @param position The position to start off with.
 */
- (instancetype)initWithCustomView:(UIView *)view initialPosition:(RXRecallButtonPosition)position;

/** Designated initializer.
 
 @param frame The frame to initialize the draggable container with.
 @param view Custom UIView to use inside the draggable container.
 @param position The position to start off with.
 */
- (instancetype)initWithFrame:(CGRect)frame customView:(UIView *)view initialPosition:(RXRecallButtonPosition)position;

/** Hides itself under the edge its currently anchored to.
 
 @param animated Boolean value indicating weather the action should be animated.
 @param completion Block to execute once the animation is complete.
 */
- (void)hide:(BOOL)animated completion:(void (^)())completion;

/** Shows itself from under the edge it was hidden under.
 
 @param animated Boolean value indicating weather the action should be animated.
 @param completion Block to execute once the animation is complete.
 */
- (void)show:(BOOL)animated completion:(void (^)())completion;

@end
