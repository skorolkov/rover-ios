//
//  RVRetailExperienceManager.h
//  Pods
//
//  Created by Ata Namvari on 2015-05-19.
//
//

#import <Foundation/Foundation.h>
#import "Rover.h"

@interface RVMessageFeedExperience : NSObject <RoverDelegate>

/** The button used to recall the cards.
 */
@property (nonatomic, strong) RXRecallButton *recallButton;

/** The transitioning delegate used to slide the cards downward when visit is alive.
 */
@property (nonatomic, strong) RXModalTransition *modalTransitionManager;

/** Called when the recall button is clicked. If you subclass make sure to call super.
 */
- (void)recallButtonClicked:(RXDraggableView *)draggableView;

/** Method to display card modal. If you subclass make sure to call super.
 */
- (void)presentModalForVisit:(RVVisit *)visit;

@end
