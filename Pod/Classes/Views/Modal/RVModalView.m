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

@interface RVModalView ()

@property (nonatomic, strong) RVCloseButton *closeButton;

@end

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
    
    self.closeButton = [[RVCloseButton alloc] initWithFrame:CGRectMake(272.0, 24.0, 44.0, 44.0)];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.alpha = 0.0;
    [self addSubview:self.closeButton];

}

- (void)configureLayout
{
    [self removeConstraints:self.constraints];
    
    NSDictionary *views = @{@"background": self.background,
                            @"cardDeck": self.cardDeck,
                            @"closeButton": self.closeButton};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[background]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[background]|" options:0 metrics:nil views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[cardDeck]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[closeButton(40)][cardDeck]|" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cardDeck attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[closeButton(44)]" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-12]];
}

- (void)animateIn
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.closeButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.closeButton.userInteractionEnabled = YES;
    }];
}

#pragma mark - Actions

- (void)closeButtonPressed
{
    if (self.delegate) {
        [self.delegate modalViewCloseButtonPressed:self];
    }
}

@end
