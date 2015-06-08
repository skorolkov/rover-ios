//
//  RXDraggableView.h
//  Pods
//
//  Created by Ata Namvari on 2015-05-26.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RXDraggableEdge) {
    RXDraggableEdgeBottom,
    RXDraggableEdgeTop,
    RXDraggableEdgeRight,
    RXDraggableEdgeLeft
};

@protocol RXDraggableViewDelegate;

@interface RXDraggableView : UIView

/** Delegate that gets notified of click events.
 */
@property (nonatomic, weak) id<RXDraggableViewDelegate> delegate;

/** The edge of the screen currently anchored to. (Bottom, Top, Right, Left)
 */
@property (nonatomic, assign, readonly) RXDraggableEdge anchoredEdge;

/** Margins to use as distance when anchoring to an edge.
 */
@property (nonatomic, assign) UIEdgeInsets margins;

/** Returns a CGPoint on the screen that the view would snap to when let go.
 */
- (CGPoint)snapPointToClosestEdgeFromPoint:(CGPoint)point offset:(UIOffset)offset;

@end


@protocol RXDraggableViewDelegate <NSObject>

@optional

/** Called when the view is clicked, but not moved.
 */
- (void)draggableViewClicked:(RXDraggableView *)draggableView;

@end
