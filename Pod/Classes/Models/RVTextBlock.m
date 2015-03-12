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

@property (nonatomic, strong) NSMutableAttributedString *htmlText;

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
        //self.htmlString = htmlText;
        self.htmlString = @"<style type=\"text/css\">h1{font-weight:normal;font-family: HelveticaNeue-Thin;font-size:22px;text-align:center;line-height:28px;min-height:24px;color:rgba(255,255,255,1);margin:0px 0px 10px 0px;}h2{font-weight:normal;font-family: HelveticaNeue-Bold;font-size:22px;text-align:left;line-height:22px;min-height:22px;color:rgba(129,129,129,1);margin:0px 0px 10px 0px;}p{font-weight:normal;font-family: HelveticaNeue-Light;font-size:14px;text-align:left;line-height:18px;min-height:18px;color:rgba(93,93,93,1);margin:0px 0px 10px 0px;}</style><h1>Earn 100 Bonus Rewards miles when you spend $40 or more in store</h1>";
    }
}

- (NSAttributedString *)htmlText {
    if (!_htmlText) {
        
        _htmlText = [[NSMutableAttributedString alloc] initWithData:[self.htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        
        //NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle ]
        
        //[_htmlText setAttributes:@{NSParagraphStyleAttributeName: } range:NSMakeRange(0, _htmlText.length)];
        

        
        // Remove any trailing newline
        if (_htmlText.length) {
            NSAttributedString *last = [_htmlText attributedSubstringFromRange:NSMakeRange(_htmlText.length - 1, 1)];
            if ([[last string] isEqualToString:@"\n"]) {
                _htmlText = [_htmlText attributedSubstringFromRange:NSMakeRange(0, _htmlText.length - 1)];
            }
        }
    }
    
    NSLog(@"htmlString: %@", self.htmlString);
    NSLog(@"htmlText : %@", _htmlText);
    
    return _htmlText;
}

- (CGFloat)heightForWidth:(CGFloat)width {
    return [super heightForWidth:width] + [[self htmlText] boundingRectWithSize:CGSizeMake([self paddingAdjustedValueForWidth:width], MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height;
}

@end
