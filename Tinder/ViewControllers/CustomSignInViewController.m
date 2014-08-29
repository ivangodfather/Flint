//
//  CustomSignInViewController.m
//  Tinder
//
//  Created by John Blanchard on 8/27/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#define emailIdentifier @"@"

#import "CustomSignInViewController.h"

@interface CustomSignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIImageView *keyImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *containerViewPassword;

@end

@implementation CustomSignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    [self customizeView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];

}

#pragma mark - Resign the textField's keyboard
- (IBAction)resignTheKeyboard:(UITextField*)sender
{
    [sender resignFirstResponder];
}

#pragma mark - login button pressed
- (IBAction)enterTinderWorld:(id)sender
{
    [PFUser logInWithUsernameInBackground:self.emailTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (error) {
            [self showAlertForInvalidLogin];
        } else {
            [self performSegueWithIdentifier:@"login" sender:self];
        }
    }];
}

#pragma mark - alert message
-(void) showAlertForInvalidLogin
{
    NSString* message = @"";
    if ([self.emailTextField.text isEqualToString:@""]) {
        message = [message stringByAppendingString:@"Blank login field\n"];
    }
    if ([self.passwordTextField.text isEqualToString:@""]) {
        message = [message stringByAppendingString:@"Blank password field\n"];
    }
    message = [message stringByAppendingString:@"Enter valid login credentials"];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error with login" message:message delegate:self cancelButtonTitle:@"Done" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - customize view

- (void)customizeView
{
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.signInButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [[self.signInButton layer] setBorderWidth:1.0f];

    [self.containerView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.containerView.layer setBorderWidth:1.0f];
    [self.containerViewPassword.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.containerViewPassword.layer setBorderWidth:1.0f];
    
}


- (IBAction)passBegin:(UITextField *)textfield
{
    textfield.alpha = 1;
    self.keyImageView.alpha = 1;

}
- (IBAction)endPassword:(UITextField *)textField {
    textField.alpha = 0.5;
    self.keyImageView.alpha = 0.5;


}

- (IBAction)endUsername:(UITextField *)textField {

    textField.alpha = 0.5;
    self.userImageView.alpha = 0.5;

}

- (IBAction)usernameBegin:(UITextField *)textfield {
    textfield.alpha = 1;
    self.userImageView.alpha = 1;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setFrame:CGRectMake(0,-80,320,460)];
    } completion:^(BOOL finished) {

    }];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setFrame:CGRectMake(0,0,320,460)];
    } completion:^(BOOL finished) {

    }];
}
@end
