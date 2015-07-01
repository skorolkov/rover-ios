//
//  RXRecallMenu.h
//  Pods
//
//  Created by Ata Namvari on 2015-06-16.
//
//

#import <UIKit/UIKit.h>
#import "RXRecallButton.h"


/** This is the recall menu for the Nearby experience.
 */
@interface RXRecallMenu : RXRecallButton

/** Number of menu items.
 */
@property (nonatomic, assign, readonly) NSUInteger itemCount;

/** The array of menu items.
 */
@property (nonatomic, readonly) NSArray *items;

/** A boolean value indicating if the menu is currently in the expanded state.
 */
@property (nonatomic, assign, readonly) BOOL isExpanded;

/** The backdrop to display when the menu gets expanded. By default this is a black UIView with .3 opacity
 */
@property (nonatomic, strong) UIView *backdropView;


/** Use this method to add items to the menu.
 */
- (void)addItem:(UIButton *)item animated:(BOOL)animated;

/** Use this method to remove items from the menu.
 */
- (void)removeItem:(UIButton *)item animated:(BOOL)animated;

/** Use this method to collapse the menu if its in a expanded state.
 */
- (void)collapse:(BOOL)animated completion:(void (^)())completion;

/** Use this method to expand the menu if not alteady in the expanded state.
 */
- (void)expand:(BOOL)animated completion:(void (^)())completion;

@end