//
//  RVHeaderBlock.m
//  Pods
//
//  Created by Ata Namvari on 2015-02-18.
//
//

#import "RVHeaderBlock.h"
#import "RVModelProject.h"

@interface RVHeaderBlock ()

@property (nonatomic, strong) NSString  *iconPath;
@property (nonatomic ,strong) NSAttributedString *title;

@end


@implementation RVHeaderBlock

- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    _title = nil;
}

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    
    // title
    NSString *titleString = [JSON objectForKey:@"headerTitle"];
    if (titleString && titleString != (id)[NSNull null]) {
        self.titleString = titleString;
    }
    
    // iconPath
    NSString *iconPath = [JSON objectForKey:@"iconPath"];
    if (iconPath && iconPath != (id)[NSNull null]) {
        self.iconPath = iconPath;
    }
}

- (NSURL *)iconURL {
    return [NSURL URLWithString:self.iconPath];
}

- (NSAttributedString *)title {
    if (!_title) {
        _title = [[NSAttributedString alloc] initWithData:[self.titleString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        
        // Remove any trailing newline
        if (_title.length) {
            NSAttributedString *last = [_title attributedSubstringFromRange:NSMakeRange(_title.length - 1, 1)];
            if ([[last string] isEqualToString:@"\n"]) {
                _title = [_title attributedSubstringFromRange:NSMakeRange(0, _title.length - 1)];
            }
        }
    }
    
    return _title;
}

- (CGFloat)heightForWidth:(CGFloat)width {
    CGFloat height = [super heightForWidth:width] + ([[self title] boundingRectWithSize:CGSizeMake([self paddingAdjustedValueForWidth:width], MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height) + 20; // 20 for status bar
    return height;
}

@end
