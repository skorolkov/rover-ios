//
//  RVHeartIcon.h
//  Rover
//
//  Created by Sean Rucker on 2014-07-04.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RVCardViewButtonIconTypeHeart,
    RVCardViewButtonIconTypeBang
} RVCardViewButtonIconType;

@interface RVCardViewButtonIcon : UIView

@property (nonatomic) RVCardViewButtonIconType iconType;
@property (nonatomic) UIColor *color;

@end
