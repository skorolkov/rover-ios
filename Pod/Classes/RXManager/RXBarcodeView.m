//
//  RXBarcodeView.m
//  Pods
//
//  Created by Ata Namvari on 2015-03-10.
//
//

#import "RXBarcodeView.h"
#import "RSBarcodes.h"
#import "RXTextView.h"

@interface RXBarcodeView ()



@end

@implementation RXBarcodeView

- (instancetype)initWithCode:(NSString *)code type:(RVBarcodeType)barcodeType attributedLabel:(NSAttributedString *)attributedLabel {
    self = [super init];
    if (self) {
        UIImageView *barcodeView = [[UIImageView alloc] initWithImage:[RXBarcodeView barcodeImageForCode:code type:barcodeType]];
        barcodeView.backgroundColor = [UIColor clearColor];
        barcodeView.translatesAutoresizingMaskIntoConstraints = NO;
        
        RXTextView *barcodeLabel = [RXTextView new];
        barcodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        barcodeLabel.backgroundColor = [UIColor clearColor];
        barcodeLabel.attributedText = attributedLabel;
        
        [self addSubview:barcodeLabel];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(barcodeView, barcodeLabel);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[barcodeLabel]|" options:0 metrics:nil views:views]];
        
        if (barcodeType != RVBarcodeTypePLU) {
            [self addSubview:barcodeView];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[barcodeView]|" options:0 metrics:nil views:views]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[barcodeView(%u)][barcodeLabel]|", kRVBarcodeHeight] options:0 metrics:nil views:views]];
        } else {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[barcodeLabel]|" options:0 metrics:nil views:views]];
        }
    }
    return self;
}

- (instancetype)init {
    NSLog(@"RXBarcodeView - Please use the designated initializer \"initWithCode:type:attributredLabel:\" to instantiate.");
    return nil;
}


#pragma mark - Barcode Helpers

+ (UIImage *)barcodeImageForCode:(NSString *)code type:(RVBarcodeType )type
{
    switch (type) {
        case RVBarcodeTypeCode128:
            return [RXBarcodeView imageWithStandardBarcode:code withType:AVMetadataObjectTypeCode128Code];
            break;
        default:
            return nil;
            break;
    }
}

+ (UIImage *)imageWithStandardBarcode:(NSString *)code withType:(NSString *)barcodeType
{
    UIImage *codeImage = [CodeGen genCodeWithContents:code machineReadableCodeObjectType:barcodeType];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([UIScreen mainScreen].bounds.size.width, kRVBarcodeHeight), NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextDrawImage(context, CGRectMake(0, -4, [UIScreen mainScreen].bounds.size.width, kRVBarcodeHeight + 8), [codeImage CGImage]);
    
    CGContextRestoreGState(context);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
