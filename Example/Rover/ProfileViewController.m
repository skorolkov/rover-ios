//
//  SignInViewController.m
//  Rover App
//
//  Created by Sean Rucker on 2014-07-15.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "ProfileViewController.h"
#import <Rover/Rover.h>

@interface ProfileViewController()

@property (strong, nonatomic) RVCustomer *customer;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *customerIDField;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    RVCustomer *customer = [Rover shared].customer;
    self.nameField.text = customer.name;
    self.emailField.text = customer.email;
    self.phoneField.text = [customer get:@"phone"];
    self.customerIDField.text = customer.customerID;
}

- (IBAction)saveButtonPressed:(id)sender {
    [self.view endEditing:YES];
    
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
    
    if (self.phoneField.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your phone number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.customerIDField.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a customer ID" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    RVCustomer *customer = [[Rover shared] customer];
    customer.name = self.nameField.text;
    customer.email = self.emailField.text;
    [customer set:@"phone" to:self.phoneField.text];
    customer.customerID = self.customerIDField.text;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"User details saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
