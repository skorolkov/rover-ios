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
    self = [super initWithFrame:CGRectMake(0, 0, 64, 64)];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = .5;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        //[self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)tapped {
    //[self sendActionsForControlEvents:UIControlEventTouchUpInside];
}


@end
