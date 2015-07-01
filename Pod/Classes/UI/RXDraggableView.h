//
//  RXDraggableView.h
//  Pods
//
//  Created by Ata Namvari on 2015-05-26.
//
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, RXDraggableSnappedEdge) {
    RXDraggableSnappedEdgeBottom = 1 << 0,
    RXDraggableSnappedEdgeTop = 1 << 1,
    RXDraggableSnappedEdgeRight = 1 << 2,
    RXDraggableSnappedEdgeLeft = 1 << 3
};

/** This UIControl is draggable around the screen. It attaches itself to the current UIWindow and has the ability
    to snap to the edges/corners of the screen.
 */
@interface RXDraggableView : UIControl

@property (nonatomic, assign) BOOL snapToCorners;

/** The edge of the screen currently anchored to. (Bottom, Top, Right, Left)
 */
@property (nonatomic, assign, readonly) RXDraggableSnappedEdge anchoredEdge;

/** Margins to use as distance when anchoring to an edge.
 */
@property (nonatomic, assign) UIEdgeInsets margins;

/** Returns a CGPoint on the screen that the view would snap to when let go.
 */
- (CGPoint)snapPointToClosestEdgeFromPoint:(CGPoint)point offset:(UIOffset)offset;

@end
