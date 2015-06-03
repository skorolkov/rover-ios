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

@interface RXRecallButton : RXDraggableView

- (void)hide:(BOOL)animated completion:(void (^)())completion;
- (void)show:(BOOL)animated completion:(void (^)())completion;

@end
