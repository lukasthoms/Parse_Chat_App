//
//  CreateAccountViewController.m
//  ParseTest2
//
//  Created by Lukas Thoms on 7/4/15.
//  Copyright (c) 2015 Lukas Thoms. All rights reserved.
//

#import "CreateAccountViewController.h"
#import <Parse/Parse.h>

@interface CreateAccountViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPassword;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end

@implementation CreateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.phoneField.delegate = self;
    self.repeatPassword.delegate = self;
    self.passwordField.secureTextEntry = YES;
    self.repeatPassword.secureTextEntry = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSArray *textFields = @[self.emailField, self.passwordField, self.repeatPassword, self.phoneField];
    
    NSUInteger currentPosistion = [textFields indexOfObject:textField];
    
    if ([textField isEqual:self.repeatPassword] && ![textField.text isEqual:self.passwordField.text]) {
        UIAlertController *noMatch = [UIAlertController alertControllerWithTitle:@"Passwords don't match." message:@"Please try re-entering your passwords" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [noMatch addAction:ok];
        [self presentViewController:noMatch animated:YES completion:nil];
    } else if (currentPosistion < 3) {
        [[textFields objectAtIndex:(currentPosistion+1)] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (IBAction)saveAccountTapped:(id)sender {
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    if (self.emailField.text.length > 0 && self.passwordField.text.length > 0 && self.phoneField.text.length > 0 && [self.passwordField.text isEqual:self.repeatPassword.text]) {
        PFUser *newUser = [PFUser user];
        newUser.username = self.emailField.text;
        newUser.email = self.emailField.text;
        newUser.password = self.passwordField.text;
        newUser[@"phone"] = [self phoneFormat:self.phoneField.text];
        newUser[@"contacts"] = [@[] mutableCopy];
        newUser[@"contactRequests"] = [@[] mutableCopy];
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }];
                UIAlertController *failedSignUp = [UIAlertController alertControllerWithTitle:@"Sign up failed." message:errorString preferredStyle:UIAlertControllerStyleAlert];
                [failedSignUp addAction:ok];
                [self presentViewController:failedSignUp animated:YES completion:nil];
            }
        }];
        
    }  else if (![self.passwordField.text isEqual:self.repeatPassword.text]) {
        UIAlertController *noMatch = [UIAlertController alertControllerWithTitle:@"Passwords don't match." message:@"Please try re-entering your passwords" preferredStyle:UIAlertControllerStyleAlert];
        [noMatch addAction:ok];
        [self presentViewController:noMatch animated:YES completion:nil];
        
        
    } else {
        UIAlertController *needInfo = [UIAlertController alertControllerWithTitle:@"More info please." message:@"Please fill out all of the fields." preferredStyle:UIAlertControllerStyleAlert];
        [needInfo addAction:ok];
        [self presentViewController:needInfo animated:YES completion:nil];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSString *) phoneFormat: (NSString*) userPhone {
    
    NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"'#%^&{}[]()/~|\?.<,@-"];
    NSString *userChannel = [[userPhone componentsSeparatedByCharactersInSet:chs] componentsJoinedByString:@""];
    return userChannel;
    
}

@end
