//
//  RXModalViewController.h
//  Pods
//
//  Created by Ata Namvari on 2015-01-12.
//
//

#import <UIKit/UIKit.h>
#import "RXVisitViewController.h"

/** This class is the rover out of the box modal view controller for displaying cards. If all you like to do is change button captions,
 and other basic styles, you should subclass this clas and register it via the registerModalViewControllerClass method on RVConfig.
 */
@interface RXModalViewController : RXVisitViewController

/** Tint color for the backdrop.
 */
@property (nonatomic, strong) UIColor *backdropTintColor;

/** Blur radius for the backdrop.
 */
@property (nonatomic, assign) NSUInteger backdropBlurRadius;

@end
