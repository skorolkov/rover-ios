//
//  RXMenuItem.m
//  Pods
//
//  Created by Ata Namvari on 2015-06-16.
//
//

#import "RXMenuItem.h"

@implementation RXMenuItem

- (instancetype)init {
    self = [self initWithFrame:CGRectMake(0, 0, 64, 64)];
    if (self) {

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = frame.size.height / 2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = .5;
        self.layer.shadowRadius = 2;
        
        //        UILabel *titleLabel = self.titleLabel;
        //        [titleLabel removeFromSuperview];
        //        [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        //        titleLabel.center = CGPointMake(0, 0);
        //        [self addSubview:titleLabel];
        self.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.titleLabel.layer.shadowOffset = CGSizeZero;
        self.titleLabel.layer.shadowRadius = 2;
        self.titleLabel.layer.shadowOpacity = .9;
        self.titleLabel.layer.masksToBounds = NO;
        //self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        //[self setContentEdgeInsets:UIEdgeInsetsMake(0, -300, 0, self.frame.size.width)];
    }
    return self;
}

#pragma mark - Overridden Methods

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self.titleLabel pointInside:[self.titleLabel convertPoint:point fromView:self] withEvent:event]) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}


@end
