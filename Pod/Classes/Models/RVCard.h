//
//  RVCard.h
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RVModel.h"

/** Represents a Card from the [Rover Marketing Console](http://app.roverlabs.co/).
 */
@interface RVCard : RVModel

/** The title of the organization this card belongs to.
 */
@property (strong, nonatomic) NSString *organizationTitle;

/** The title of the card, displayed at the very top.
 */
@property (strong, nonatomic) NSString *title;

/** The three-line short description of the card displayed directly below the title.
 */
@property (strong, nonatomic) NSString *shortDescription;

/** The long description of the card displayed beneath the image when the card is in the expanded state. The long description is in HTML format.
 */
@property (strong, nonatomic) NSString *longDescription;

/** The URL to the location of the card's image hosted remotely. You can use this URL to download and display the image in your application.
 */
@property (strong, nonatomic) NSURL *imageURL;

/** The card's primary colour, used for the card's background.
 */
@property (strong, nonatomic) UIColor *primaryBackgroundColor;

/** The card's primary font colour, used for all text displayed on the card.
 */
@property (strong, nonatomic) UIColor *primaryFontColor;

/** The card's secondary colour, used to highlight active buttons as well as the corner that appears when a card is saved to a customer's list.
 */
@property (strong, nonatomic) UIColor *secondaryBackgroundColor;

/** The card's secondary font colour, used for the icon on the corner that appears when a card is saved to a customer's list.
 */
@property (strong, nonatomic) UIColor *secondaryFontColor;

/** The date and time the card was *first* viewed by the customer.
 */
@property (strong, nonatomic) NSDate *viewedAt;

/** The date and time the card was saved to the customer's list.
 */
@property (strong, nonatomic) NSDate *likedAt;

/** The date and time the card was discarded by the customer.
 */
@property (strong, nonatomic) NSDate *discardedAt;

/** Indicates whether the customer has viewed this card during *the current visit*. I.e. the customer may have seen this card before on a different visit but could still be unread for this visit. 
 */
@property (nonatomic) BOOL isUnread;

@end