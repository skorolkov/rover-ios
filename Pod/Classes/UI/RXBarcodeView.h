//
//  RXBarcodeView.h
//  Pods
//
//  Created by Ata Namvari on 2015-03-10.
//
//

#import <UIKit/UIKit.h>
#import "RVBarcodeBlock.h"

/** A view that can display barcodes with extra attributed label underneath/
 */
@interface RXBarcodeView : UIView

/** Designated Initializer.
 @param code The code assoociated with the barcode.
 @param barcodeType The type of the barcode. RVBarcodeTypeCode128 or RVBarcodeTypePLU.
 @param attributedLabel The label to display underneath the barcode.
 */
- (instancetype)initWithCode:(NSString *)code type:(RVBarcodeType)barcodeType attributedLabel:(NSAttributedString *)attributedLabel;

@end
