//
//  RVTouchpoint.h
//  Pods
//
//  Created by Ata Namvari on 2014-12-23.
//
//

#import <Foundation/Foundation.h>
#import "RVModel.h"

@class CLBeaconRegion;

@interface RVTouchpoint : RVModel

/** The minor number for the touchpoint
 */
@property (nonatomic, strong) NSNumber *minor;

/** The notification for the touchpoint
 */
@property (nonatomic, strong) NSString *notification;

/** The title for the touchpoint
 */
@property (nonatomic, strong) NSString *title;

/** The cards for touchpoint
 */
@property (nonatomic, strong) NSArray *cards;


- (BOOL)isInRegion:(CLBeaconRegion *)beaconRegion;

@end
