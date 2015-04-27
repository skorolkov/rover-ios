//
//  RXDetailViewController.h
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import <UIKit/UIKit.h>

@class RVViewDefinition;
@class RXBlockView;

/** This is the detail view controller to display the expanded view (detail view) of a card.
 */
@interface RXDetailViewController : UIViewController

/** RVViewDefinition used to build the views.
 */
@property (nonatomic, weak) RVViewDefinition *viewDefinition;

/** The UIScrollView that contains all block UI elements.
 */
@property (readonly) UIScrollView *scrollView;

/** For consistent auto layout features. All block UI elements are encapsulated in this container view inside the scrollView.
 */
@property (readonly) UIView *containerView;

/** A sticky view that acts as a header to the view controller. Elements in this view do not scroll with the rest of the UI elements.
 */
@property (readonly) UIView *titleBar;

/** Designated initializer.
 */
- (instancetype)initWithViewDefinition:(RVViewDefinition *)viewDefinition;

/** Method to add a block to view.
 */
- (void)addBlockView:(RXBlockView *)blockView;

/** Method to add a block view to the header.
 */
- (void)addHeaderBlockView:(RXBlockView *)blockView;

/** Method to add a block view to the bottom. This is used for sticky buttons at the bottom.
 */
- (void)addBottomStickyBlockView:(RXBlockView *)blockView;


@end
