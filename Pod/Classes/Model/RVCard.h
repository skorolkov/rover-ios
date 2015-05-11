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

@interface RVCard : RVModel

@property (nonatomic, strong) NSString *title;
@property (strong, nonatomic) NSArray *viewDefinitions;
@property (nonatomic, assign) BOOL isDeleted;
@property (nonatomic, assign) BOOL isViewed;
@property (nonatomic, readonly) RVViewDefinition *listView;

- (CGFloat)listViewHeightForWidth:(CGFloat)width;



@end