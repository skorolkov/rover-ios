//
//  RVCard.h
//  Rover
//
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RVModel.h"

@class RVViewDefinition;

/** Represents a Card from the [Rover Marketing Console](http://app.roverlabs.co/).
 */
@interface RVCard : RVModel

/** The title of the card.
 */
@property (nonatomic, strong) NSString *title;

/** The view definitions for the card.
 */
@property (strong, nonatomic) NSArray *viewDefinitions;

@property (nonatomic, assign) BOOL isDeleted;

@property (nonatomic, assign) BOOL isViewed;

@property (nonatomic, readonly) RVViewDefinition *listView;

- (CGFloat)listViewHeightForWidth:(CGFloat)width;



@end