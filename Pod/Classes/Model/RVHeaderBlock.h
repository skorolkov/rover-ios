//
//  RVHeaderBlock.h
//  Pods
//
//  Created by Ata Namvari on 2015-02-18.
//
//

#import "RVBlock.h"

@interface RVHeaderBlock : RVBlock

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong, readonly) NSAttributedString *title;
@property (nonatomic, strong, readonly) NSURL *iconURL;

@end
