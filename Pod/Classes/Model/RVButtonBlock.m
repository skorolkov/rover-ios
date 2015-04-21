//
//  RVButtonBlock.m
//  Pods
//
//  Created by Ata Namvari on 2015-02-18.
//
//

#import "RVButtonBlock.h"

@interface RVButtonBlock()

@property (nonatomic, strong) NSString *iconPath;
@property (nonatomic, strong) NSAttributedString *label;

@end

@implementation RVButtonBlock

- (void)setLabelString:(NSString *)labelString {
    _labelString = labelString;
    _label = nil;
}

- (NSAttributedString *)label {
    if (!_label) {
        _label = [[NSAttributedString alloc] initWithData:[self.labelString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        
        // Remove any trailing newline
        if (_label.length) {
            NSAttributedString *last = [_label attributedSubstringFromRange:NSMakeRange(_label.length - 1, 1)];
            if ([[last string] isEqualToString:@"\n"]) {
                _label = [_label attributedSubstringFromRange:NSMakeRange(0, _label.length - 1)];
            }
        }
    }
    
    return _label;
}

- (NSURL *)iconURL {
    return [NSURL URLWithString:self.iconPath];
}

- (CGFloat)heightForWidth:(CGFloat)width {
    return [super heightForWidth:width] + round([[self label] boundingRectWithSize:CGSizeMake([self paddingAdjustedValueForWidth:width], MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.labelString forKey:@"labelString"];
    [encoder encodeObject:self.iconPath forKey:@"iconPath"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.labelString = [decoder decodeObjectForKey:@"labelString"];
        self.iconPath = [decoder decodeObjectForKey:@"iconPath"];
    }
    return self;
}

@end
