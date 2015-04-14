//
//  RXConfig.h
//  Pods
//
//  Created by Ata Namvari on 2015-04-09.
//
//

#import <Foundation/Foundation.h>

@interface RXConfig : NSObject

/** Blur radius for the modal backdrop.
 */
@property (nonatomic) NSUInteger modalBackdropBlurRadius;

/** Tint color for the modal backdrop.
 */
@property (nonatomic, strong) UIColor *modalBackdropTintColor;

/** Create an RXConfig instance with the default values and override as necessary.
 */
+ (instancetype)defaultConfig;


@end
