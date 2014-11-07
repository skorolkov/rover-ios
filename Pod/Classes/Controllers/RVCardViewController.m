//
//  RVCardViewController.m
//  Rover
//
//  Created by Sean Rucker on 2014-09-15.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardViewController.h"
#import "RVCardView.h"
#import "RVCard.h"

@interface RVCardViewController () <RVCardViewDelegate>

@property (strong, nonatomic) RVCardView *view;

@end

@implementation RVCardViewController

@dynamic view;

#pragma mark - Properties

- (void)setCard:(RVCard *)card {
    _card = card;
    
    if (self.isViewLoaded) {
        [self configureView];
    }
}

#pragma mark - Initialization

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)loadView {
    self.view = [[RVCardView alloc] initWithFrame:UIScreen.mainScreen.applicationFrame];
}

- (void)viewDidLoad {
    //self.view.useCloseButton = YES;
    self.view.delegate = self;
    [self configureView];
    [self.view expandToFrame:self.view.frame animated:NO];
}

- (void)configureView {
    if (!self.card) {
        return;
    }
    
    [self.view setCard:self.card];
}

- (void)saveCard:(RVCard *)card {
    card.lastViewedFrom = @"ViewController";
    card.lastViewedPosition = nil;
    [card save:nil failure:nil];
}

#pragma mark - RVCardViewDelegate

- (void)cardViewCloseButtonPressed:(RVCardView *)cardView {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cardViewLikeButtonPressed:(RVCardView *)cardView {
    RVCard *card = cardView.card;
    cardView.liked = !cardView.liked;
    if (cardView.liked) {
        card.likedAt = [NSDate date];
        card.discardedAt = nil;
    } else {
        card.likedAt = nil;
    }
    [self saveCard:card];
}

- (void)cardViewBarcodeButtonPressed:(RVCardView *)cardView {
    RVCard *card = cardView.card;
    card.lastViewedBarcodeAt = [NSDate date];
    [self saveCard:card];
}


@end
