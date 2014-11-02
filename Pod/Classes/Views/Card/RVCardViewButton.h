//
//  RVCardViewButton.h
//  Rover
//
//  Created by Sean Rucker on 2014-07-04.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVCardViewButtonIcon;

@interface RVCardViewButton : UIButton

@property (nonatomic) BOOL active;

@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *activeColor;

@end