//
//  RVCardViewButtonBar.h
//  Rover
//
//  Created by Sean Rucker on 2014-07-04.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVCardViewButton;
@class RVCardViewButton;
@protocol RVCardViewButtonBarDelegate;

@interface RVCardViewButtonBar : UIView

@property (weak, nonatomic) id <RVCardViewButtonBarDelegate> delegate;

@property (strong, nonatomic) UIColor *fontColor;
//@property (strong, nonatomic) UIColor *activeColor;
@property (strong, nonatomic) RVCardViewButton *leftButton;
@property (strong, nonatomic) RVCardViewButton *rightButton;

- (void)setLeftButtonTitle:(NSString *)leftButtonTitle andRightButtonTitle:(NSString *)rightButtonTitle;
- (void)setPressedCaption:(NSString *)pressedCaption forButton:(RVCardViewButton *)button;
- (void)setPressed:(BOOL)pressed forButton:(RVCardViewButton *)button;
@end

@protocol RVCardViewButtonBarDelegate

- (void)buttonBarLeftButtonPressed:(RVCardViewButtonBar *)buttonBar;
- (void)buttonBarRightButtonPressed:(RVCardViewButtonBar *)buttonBar;

@end
