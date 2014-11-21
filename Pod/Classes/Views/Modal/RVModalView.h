//
//  RVModalView.h
//  Rover
//
//  Created by Sean Rucker on 2014-06-28.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVCardDeckView, RVCloseButton, RVNextButton;
@protocol RVModalViewDelegate;

@interface RVModalView : UIView

@property (weak, nonatomic) id <RVModalViewDelegate> delegate;

@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) RVCardDeckView *cardDeck;

- (void)animateIn;

@end

@protocol RVModalViewDelegate <NSObject>

- (void)modalViewBackgroundPressed:(RVModalView *)modalView;
- (void)modalViewCloseButtonPressed:(RVModalView *)modalView;

@end
