//
//  CustomModalViewController.m
//  Rover
//
//  Created by Ata Namvari on 2015-01-14.
//  Copyright (c) 2015 Rover Labs Inc. All rights reserved.
//

#import "CustomModalViewController.h"
#import <Rover/Rover.h>

@interface CustomModalViewController () <RVCardViewActionDelegate>

@end

@implementation CustomModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (RVCardBaseView *)cardDeck:(RVCardDeckView *)cardDeck cardViewForItemAtIndex:(NSUInteger)index {
    RVCardView *cardView = (RVCardView *)[super cardDeck:cardDeck cardViewForItemAtIndex:index];
    
    if (cardView.card.likedAt) {
        [cardView addButtonWithTitle:@"Remove from Saved Cards"];
    } else {
        [cardView addButtonWithTitle:@"Add to Saved Cards"];
    }
    
    
    cardView.actionDelegate = self;
    
    return cardView;
}

- (void)cardView:(RVCardView *)cardView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:[NSString stringWithFormat:@"%@ has been added to your shopping list", cardView.card.title] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.delegate = self;
    [alert show];
    
    // Update the card
    RVCard *card = cardView.card;
    card.likedAt = card.likedAt ? nil : [NSDate date];
    [card save:nil failure:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.cardDeckView swipeToNextCard];
}

@end
