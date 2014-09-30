//
//  RVCardViewController.h
//  Rover
//
//  Created by Sean Rucker on 2014-09-15.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RVCard;

/** The RVCardViewController is used to display an RVCard model. You should instantiate this class, set the card property and present it modally. 
 
 The most common use of this view controller is to display a card after the customer has selected one from their favourites list.
 
 This view controller contains a lot of useful functionality out of the box. By using the RVModalViewController you can get your app up and running with the Rover Platform quickly.
 */
@interface RVCardViewController : UIViewController

/** The RVCard model the view controller should display.
 */
@property (strong, nonatomic) RVCard *card;

@end
