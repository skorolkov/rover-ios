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



/** The meta data associated with the card
 */
@property (strong, nonatomic) NSDictionary *metaData;

/** The view blocks for when in list view
 */
@property (strong, nonatomic) NSArray *listviewBlocks;

/** The view blocks for when in detail view
 */
@property (strong, nonatomic) NSArray *detailviewBlocks;


// TODO: reevaluate these

/** The id of the card. This is the same ID seen form the web console.
 */
@property (strong, nonatomic) NSNumber *cardId;



/** The date and time the card was *first* viewed by the customer.
 */
@property (strong, nonatomic) NSDate *viewedAt;

/** The date and time the card was saved to the customer's list.
 */
@property (strong, nonatomic) NSDate *likedAt;

/** The date and time the card was discarded by the customer.
 */
@property (strong, nonatomic) NSDate *discardedAt;

/** The date and time the card expires.
 */
@property (strong, nonatomic) NSDate *expiresAt;





/** Indicates whether the customer has viewed this card during *the current visit*. I.e. the customer may have seen this card before on a different visit but could still be unread for this visit. 
 */
@property (nonatomic) BOOL isUnread;

/** Analytics properties
 */

@property (strong, nonatomic) NSString *lastViewedFrom;
@property (strong, nonatomic) NSNumber *lastViewedPosition;
@property (strong, nonatomic) NSDate *lastExpandedAt;
@property (strong, nonatomic) NSDate *lastViewedBarcodeAt;

@end