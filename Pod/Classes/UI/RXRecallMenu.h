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

@property (nonatomic, assign, readonly) NSUInteger itemCount;
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, assign, readonly) BOOL isExpanded;
@property (nonatomic, strong) UIView *backdropView;

- (void)addItem:(RXMenuItem *)item animated:(BOOL)animated;
- (void)removeItem:(RXMenuItem *)item animated:(BOOL)animated;

- (void)collapse:(BOOL)animated completion:(void (^)())completion;
- (void)expand:(BOOL)animated completion:(void (^)())completion;

@end