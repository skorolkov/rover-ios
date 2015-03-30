//
//  RVBarcodeBlock.h
//  Pods
//
//  Created by Ata Namvari on 2015-02-18.
//
//

#import "RVBlock.h"

#define kRVBarcodeHeight 56

typedef NS_ENUM(NSInteger, RVBarcodeType) {
    RVBarcodeTypeCode128 = 1,
    RVBarcodeTypePLU = 2
};

@interface RVBarcodeBlock : RVBlock

@property (nonatomic, strong) NSString *barcodeString;
@property (nonatomic, strong) NSString *barcodeLabel;
@property (nonatomic, readonly) NSAttributedString *barcodeLabelAttributedString;
@property (nonatomic, assign) RVBarcodeType barcodeType;

@end
