//
//  SignInViewController.m
//  Rover App
//
//  Created by Sean Rucker on 2014-07-15.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "ProfileViewController.h"
#import "MBProgressHUD.h"
#import <Rover/Rover.h>

@interface ProfileViewController()

@property (strong, nonatomic) RVCustomer *customer;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *collectorField;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [Rover getCustomer:^(RVCustomer *customer, NSString *error) {
        if (customer) {
            self.customer = customer;
            self.nameField.text = customer.name;
            self.emailField.text = customer.email;
            self.collectorField.text = (NSString *)[customer getAttribute:@"collectorNumber"];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (IBAction)saveButtonPressed:(id)sender {
    if (self.nameField.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.emailField.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.collectorField.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your collector number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    self.customer.name = self.nameField.text;
    self.customer.email = self.emailField.text;
    [self.customer setAttribute:@"collectorNumber" value:self.collectorField.text];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.customer save:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSString *reason) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Something went wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

@end
