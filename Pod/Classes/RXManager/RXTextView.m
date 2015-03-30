//
//  RXTextView.m
//  Pods
//
//  Created by Ata Namvari on 2015-03-11.
//
//

#import "RXTextView.h"
@import CoreText;

@implementation RXTextView


- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    [self invalidateIntrinsicContentSize];
}

- (void)setBounds:(CGRect)bounds {
    if (self.bounds.size.width != bounds.size.width && self.bounds.size.height != bounds.size.height) {
        [self invalidateIntrinsicContentSize];
    }
    [super setBounds:bounds];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.bounds.size.width, [self.attributedText boundingRectWithSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height);
}

- (void)drawRect:(CGRect)rect {
    [_attributedText drawInRect:rect];
}


@end
