//
//  RVModalView.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-28.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModalView.h"
#import "RVCardDeckView.h"
#import "RVCloseButton.h"
#import "RVNextButton.h"

@implementation RVModalView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        [self configureLayout];
    }
    return self;
}

- (void)addSubviews
{
    self.background = [[UIImageView alloc] initWithFrame:self.bounds];
    self.background.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.background];
    
    self.cardDeck = [[RVCardDeckView alloc] initWithFrame:self.bounds];
    self.cardDeck.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.cardDeck];
}

- (void)configureLayout
{
    [self removeConstraints:self.constraints];
    
    NSDictionary *views = @{@"background": self.background,
                            @"cardDeck": self.cardDeck };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[background]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[background]|" options:0 metrics:nil views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[cardDeck]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cardDeck]|" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cardDeck attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
}

@end
