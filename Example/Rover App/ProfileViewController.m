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
    self.nameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    self.emailField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    self.phoneField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"phone"];
    self.customerIDField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"];
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
    
    NSString *name = self.nameField.text;
    NSString *email = self.emailField.text;
    NSString *phone = self.phoneField.text;
    NSString *customerID = self.customerIDField.text;
    
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"name"];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"phone"];
    [[NSUserDefaults standardUserDefaults] setObject:customerID forKey:@"customerID"];
    
    RVCustomer *customer = [[Rover shared] customer];
    customer.name = name;
    customer.email = email;
    customer.customerID = customerID;
    [customer setAttribute:@"phone" to:phone];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"User details saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
