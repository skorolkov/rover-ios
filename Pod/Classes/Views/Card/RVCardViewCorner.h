//
//  RVCardViewCorner.h
//  Rover
//
//  Created by Sean Rucker on 2014-08-06.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVCardViewButtonIcon;

@interface RVCardViewCorner : UIView

@property (strong, nonatomic) RVCardViewButtonIcon *icon;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *iconColor;

@end
