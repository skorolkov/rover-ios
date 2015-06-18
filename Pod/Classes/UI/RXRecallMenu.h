//
//  RXRecallMenu.h
//  Pods
//
//  Created by Ata Namvari on 2015-06-16.
//
//

#import <UIKit/UIKit.h>
#import "RXRecallButton.h"

@class RXMenuItem;

@interface RXRecallMenu : RXRecallButton

@property (nonatomic, assign, readonly) BOOL isExpanded;

- (void)addItem:(RXMenuItem *)item animated:(BOOL)animated;
- (void)removeItem:(RXMenuItem *)item animated:(BOOL)animated;

@end