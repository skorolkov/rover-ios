//
//  RVTextBlock.m
//  Pods
//
//  Created by Ata Namvari on 2015-02-18.
//
//

#import "RVTextBlock.h"

@interface RVTextBlock ()

@property (nonatomic, strong) NSAttributedString *htmlText;

@end

@implementation RVTextBlock


- (NSAttributedString *)htmlText {
    if (!_htmlText) {
        
        _htmlText = [[NSMutableAttributedString alloc] initWithData:[self.htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
     
        // TOOD: dry this out, its used in every block that can contain text 
        
        // Remove any trailing newline
        if (_htmlText.length) {
            NSAttributedString *last = [_htmlText attributedSubstringFromRange:NSMakeRange(_htmlText.length - 1, 1)];
            if ([[last string] isEqualToString:@"\n"]) {
                _htmlText = [_htmlText attributedSubstringFromRange:NSMakeRange(0, _htmlText.length - 1)];
            }
        }
    }
    
    return _htmlText;
}

- (CGFloat)heightForWidth:(CGFloat)width {
    return [super heightForWidth:width] + ([[self htmlText] boundingRectWithSize:CGSizeMake([self paddingAdjustedValueForWidth:width], MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.htmlString forKey:@"htmlString"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.htmlString = [decoder decodeObjectForKey:@"htmlString"];
    }
    return self;
}

@end
