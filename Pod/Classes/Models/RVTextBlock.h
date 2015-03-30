//
//  RVTextBlock.h
//  Pods
//
//  Created by Ata Namvari on 2015-02-18.
//
//

#import "RVBlock.h"

@interface RVTextBlock : RVBlock

@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong, readonly) NSAttributedString *htmlText;

@end
