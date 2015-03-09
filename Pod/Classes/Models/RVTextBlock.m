//
//  RVTextBlock.m
//  Pods
//
//  Created by Ata Namvari on 2015-02-18.
//
//

#import "RVTextBlock.h"
#import "RVModelProject.h"

@interface RVTextBlock ()

@property (nonatomic, strong) NSAttributedString *htmlText;

@end

@implementation RVTextBlock

//- (void)setHtmlString:(NSString *)htmlString {
//    _htmlString = htmlString;
//    _attributedHtmlString = nil;
//}

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    
    // htmlText
    NSString *htmlText = [JSON objectForKey:@"textContent"];
    if (htmlText && htmlText != (id)[NSNull null]) {
        self.htmlString = htmlText;
    }
}

- (NSAttributedString *)htmlText {
    if (!_htmlText) {
        _htmlText = [[NSAttributedString alloc] initWithData:[self.htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        
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
    return [super heightForWidth:width] + [[self htmlText] boundingRectWithSize:CGSizeMake([self paddingAdjustedValueForWidth:width], MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height;
}

@end
