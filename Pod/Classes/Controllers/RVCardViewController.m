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
    self.view.useCloseButton = YES;
    self.view.delegate = self;
    [self configureView];
    [self.view expandToFrame:self.view.frame animated:YES];
}

- (void)configureView {
    if (!self.card) {
        return;
    }
    
    self.view.title = self.card.title;
    self.view.shortDescription = self.card.shortDescription;
    
    if (self.card.longDescription) {
        self.view.longDescription = self.card.longDescription;
    }
    
    self.view.imageURL = self.card.imageURL;
    self.view.backgroundColor = self.card.primaryBackgroundColor;
    self.view.fontColor = self.card.primaryFontColor;
    self.view.secondaryBackgroundColor = self.card.secondaryBackgroundColor;
    self.view.secondaryFontColor = self.card.secondaryFontColor;
    self.view.liked = self.card.likedAt != nil;
    self.view.discarded = self.card.discardedAt != nil;
    
    //if (self.card.barcode) {
        //self.view.barcode = @"12345678"; //self.card.barcode;
    //}
}

#pragma mark - RVCardViewDelegate

- (void)cardViewCloseButtonPressed:(RVCardView *)cardView {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
