//
//  RVButtonBlock.h
//  Pods
//
//  Created by Ata Namvari on 2015-02-18.
//
//

#import "RVBlock.h"

@interface RVButtonBlock : RVBlock

@property (nonatomic, strong, readonly) NSAttributedString *label;
@property (nonatomic, strong) NSString *labelString;
@property (nonatomic, strong, readonly) NSURL *iconURL;

@end
