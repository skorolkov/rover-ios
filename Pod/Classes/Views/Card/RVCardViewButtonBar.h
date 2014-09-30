//
//  RVCardViewButtonBar.h
//  Rover
//
//  Created by Sean Rucker on 2014-07-04.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVCardViewButton;
@protocol RVCardViewButtonBarDelegate;

@interface RVCardViewButtonBar : UIView

@property (weak, nonatomic) id <RVCardViewButtonBarDelegate> delegate;

@property (strong, nonatomic) UIColor *fontColor;
@property (strong, nonatomic) UIColor *activeColor;

@property (nonatomic) BOOL leftButtonActivated;
@property (nonatomic) BOOL rightButtonActivated;

@end

@protocol RVCardViewButtonBarDelegate

- (void)buttonBarLeftButtonPressed:(RVCardViewButtonBar *)buttonBar;
- (void)buttonBarRightButtonPressed:(RVCardViewButtonBar *)buttonBar;

@end
