//
//  RXModalViewController.h
//  Pods
//
//  Created by Ata Namvari on 2015-01-12.
//
//

#import <UIKit/UIKit.h>
#import "RXVisitViewController.h"

@interface RXModalViewController : RXVisitViewController

@property (nonatomic, strong) UIColor *backdropTintColor;
@property (nonatomic, assign) NSUInteger backdropBlurRadius;

@end
