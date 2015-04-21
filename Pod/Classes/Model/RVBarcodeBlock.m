//
//  RVBarcodeBlock.m
//  Pods
//
//  Created by Ata Namvari on 2015-02-18.
//
//

#import "RVBarcodeBlock.h"

@interface RVBarcodeBlock ()

@property (nonatomic, strong) NSAttributedString *barcodeLabelAttributedString;

@end

@implementation RVBarcodeBlock

- (NSAttributedString *)barcodeLabelAttributedString {
    if (!_barcodeLabelAttributedString) {
        _barcodeLabelAttributedString = [[NSAttributedString alloc] initWithData:[self.barcodeLabel dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        
        // Remove any trailing newline
        if (_barcodeLabelAttributedString.length) {
            NSAttributedString *last = [_barcodeLabelAttributedString attributedSubstringFromRange:NSMakeRange(_barcodeLabelAttributedString.length - 1, 1)];
            if ([[last string] isEqualToString:@"\n"]) {
                _barcodeLabelAttributedString = [_barcodeLabelAttributedString attributedSubstringFromRange:NSMakeRange(0, _barcodeLabelAttributedString.length - 1)];
            }
        }
    }
    
    return _barcodeLabelAttributedString;
}

- (CGFloat)heightForWidth:(CGFloat)width {
    return [super heightForWidth:width] + round([[self barcodeLabelAttributedString] boundingRectWithSize:CGSizeMake([self paddingAdjustedValueForWidth:width], MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height) + (self.barcodeType == RVBarcodeTypePLU ? 0 : kRVBarcodeHeight);
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.barcodeString forKey:@"barcodeString"];
    [encoder encodeObject:self.barcodeLabel forKey:@"barcodeLabel"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.barcodeType] forKey:@"barcodeType"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.barcodeString = [decoder decodeObjectForKey:@"barcodeString"];
        self.barcodeLabel = [decoder decodeObjectForKey:@"barcodeLabel"];
        self.barcodeType = [[decoder decodeObjectForKey:@"barcodeType"] integerValue];
    }
    return self;
}

@end
