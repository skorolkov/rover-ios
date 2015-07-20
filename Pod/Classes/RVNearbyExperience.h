//
//  RVSimpleExperience.h
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import <Foundation/Foundation.h>
#import "Rover.h"

@interface RVNearbyExperience : NSObject <RoverDelegate>

/** The button menu used to recall cards.
 */
@property (nonatomic, strong) RXRecallMenu *recallMenu;

/** The transitioning delegate used to slide the cards downward when visit is alive.
 */
@property (nonatomic, strong) RXModalTransition *modalTransition;

/** Called when a menu item is clicked. If you subclass make sure to call super.
 */
- (void)menuItemClicked:(RXMenuItem *)menuItem;

/** Called to return a menu item for a touchpoint. If you subclass make sure to call super.
 */
- (RXMenuItem *)menuItemForTouchpoint:(RVTouchpoint *)touchpoint;

/** Method to present cards for a specific touchpoint. If you subclass make sure to call super.
 */
- (void)presentModalForTouchpoint:(RVTouchpoint *)touchpoint;

@end
