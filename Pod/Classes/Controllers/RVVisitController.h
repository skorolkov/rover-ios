//
//  RVVisitController.h
//  Pods
//
//  Created by Ata Namvari on 2015-02-25.
//
//

#import <Foundation/Foundation.h>

@class RVCard;
@class RVVisit;

@protocol RVVisitControllerDelegate;

@interface RVVisitController : NSObject


@property (nonatomic, strong, readonly) RVVisit *visit;

@property (nonatomic, strong) NSPredicate *predicate;

@property (nonatomic, assign) id<RVVisitControllerDelegate> delegate;

/* Returns an array of objects that implement the RVVisitTouchpointInfo protocol.
 It's expected that developers use the returned array when implementing the following methods of the UITableViewDataSource protocol
 
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
 - (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
 
 */
@property (nonatomic, readonly) NSArray *touchpoints;


/* Returns the card at a given indexPath.
 */
- (RVCard *)cardAtIndexPath:(NSIndexPath *)indexPath;

/* Returns the index path of a given card.
 */
- (NSIndexPath *)indexPathForCard:(RVCard *)card;

//NSFetchedResultsController


@end


// ================== PROTOCOLS ==================

@protocol RVVisitTouchpointInfo

/* Name of the touchpoint
 */
@property (nonatomic, readonly) NSString *name;

/* Title of the touchpoint (used when displaying the index)
 */
@property (nonatomic, readonly) NSString *indexTitle;

/* Number of cards in touchpoint
 */
@property (nonatomic, readonly) NSUInteger numberOfCards;

/* Returns the array of cards in the touchpoint.
 */
@property (nonatomic, readonly) NSArray *cards;

@end // RVVisitTouchpointInfo


@protocol RVVisitControllerDelegate <NSObject>

typedef NS_ENUM(NSUInteger, RVVisitChangeType) {
    RVVisitChangeInsert = 1,
    RVVisitChangeDelete = 2
};

@optional
- (void)controller:(RVVisitController *)controller didChangeTouchpoint:(id<RVVisitTouchpointInfo>)touchpointInfo atIndex:(NSUInteger)touchpointIndex forChangeType:(RVVisitChangeType)type;
- (void)controller:(RVVisitController *)controller didChangeCard:(RVCard *)card atIndexPath:(NSIndexPath *)indexPath forChangeType:(RVVisitChangeType)type;

@end