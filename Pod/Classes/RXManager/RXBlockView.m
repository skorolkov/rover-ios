//
//  RXBlockView.m
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import "RXBlockView.h"

@implementation RXBlockView

+ (NSArray *)constraintsForBlockView:(RXBlockView *)blockView withPreviousBlockView:(RXBlockView *)previousBlockView inside:(UIView *)containerView {
    return @[
             [NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
             [NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeRight multiplier:1 constant:0],
             [NSLayoutConstraint constraintWithItem:blockView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:previousBlockView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]
             ];
}

- (instancetype)init {
    self = (RXBlockView *)[UITextView new];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor greenColor];
        //[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:25]];
        [(UITextView *)self setAttributedText:[RXBlockView attributedTextFromHTMLString:@"<h1 style='margin-left:10px;'>test</h1>the shit" withFont:[UIFont systemFontOfSize:13] styles:nil]];
        [(UITextView *)self setScrollEnabled:NO];
        [(UITextView *)self setEditable:NO];
        [self setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        CGSize contentSize = [(UITextView *)self sizeThatFits:CGSizeMake(100, MAXFLOAT)];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:contentSize.height]];
        self.userInteractionEnabled = NO;
    }
    return self;
}

+ (NSAttributedString *)attributedTextFromHTMLString:(NSString *)htmlString withFont:(UIFont *)font styles:(NSArray *)styles
{
    NSMutableArray *mutableStyles = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"font-family: '%@';", font.fontName],
                                     [NSString stringWithFormat:@"font-size: %0.1fpx;", roundf(font.pointSize)],
                                     @"line-height: 21px;", nil];
    [mutableStyles addObjectsFromArray:styles];
    
    NSString *html = [NSString stringWithFormat:@"<div style=\"%@\">%@<div>", [mutableStyles componentsJoinedByString:@" "], htmlString];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    return attributedString;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
