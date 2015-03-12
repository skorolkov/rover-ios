//
//  RXTextView.m
//  Pods
//
//  Created by Ata Namvari on 2015-03-11.
//
//

#import "RXTextView.h"
@import CoreText;

@interface RXTextView ()

//@property (nonatomic, strong)

@end

@implementation RXTextView

- (NSAttributedString *)attributedText {
    return [[NSAttributedString alloc] initWithString:@"Hello core text world!"];
}

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"init");
    }
    return self;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    // constraints here
    
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    NSLog(@"height: %f", rect.size.width);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    // Flip the coordinate system
//    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//    CGContextTranslateCTM(context, 0, self.bounds.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    
//    CGMutablePathRef path = CGPathCreateMutable(); //1
//    CGPathAddRect(path, NULL, rect );
//    
//    NSAttributedString* attString = [[NSAttributedString alloc]
//                                      initWithString:@"Hello core text world!"] ; //2
//    
//    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString); //3
//    CTFrameRef frame =
//    CTFramesetterCreateFrame(framesetter,
//                             CFRangeMake(0, [attString length]), path, NULL);
//    
//    CTFrameDraw(frame, context); //4
//    
//    CFRelease(frame); //5
//    CFRelease(path);
//    CFRelease(framesetter);
    NSAttributedString* attString = [[NSAttributedString alloc] initWithString:@"Hello core text world!"] ; //2
    [attString drawInRect:rect];
}


@end
