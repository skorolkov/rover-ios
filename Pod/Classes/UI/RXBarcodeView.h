//
//  RXBarcodeView.h
//  Pods
//
//  Created by Ata Namvari on 2015-03-10.
//
//

#import <UIKit/UIKit.h>
#import "RVBarcodeBlock.h"

@interface RXBarcodeView : UIView

// Designated Initializer

- (instancetype)initWithCode:(NSString *)code type:(RVBarcodeType)barcodeType attributedLabel:(NSAttributedString *)attributedLabel;

@end
