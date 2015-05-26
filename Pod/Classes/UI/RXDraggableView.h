//
//  RXDraggableView.h
//  Pods
//
//  Created by Ata Namvari on 2015-05-26.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RXDraggableEdge) {
    RXDraggableEdgeTop,
    RXDraggableEdgeBottom,
    RXDraggableEdgeRight,
    RXDraggableEdgeLeft
};

@protocol RXDraggableViewDelegate;

@interface RXDraggableView : UIView

@property (nonatomic, weak) id<RXDraggableViewDelegate> delegate;

@property (nonatomic, assign, readonly) RXDraggableEdge anchoredEdge;

@end


@protocol RXDraggableViewDelegate <NSObject>

@optional
- (void)draggableViewClicked:(RXDraggableView *)draggableView;

@end
