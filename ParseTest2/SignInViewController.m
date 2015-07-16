//
//  SignInViewController.m
//  ParseTest2
//
//  Created by Lukas Thoms on 7/4/15.
//  Copyright (c) 2015 Lukas Thoms. All rights reserved.
//

#import "SignInViewController.h"
#import "ContactsViewController.h"
#import <Parse/Parse.h>
#import "ChattrNavigationViewController.h"


@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.passwordField.secureTextEntry = YES;
    self.passwordField.delegate = self;
    self.emailField.delegate = self;
    self.emailField.delegate = self;

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.emailField]) {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        
        
    }
    return YES;
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    reutrn YES;
//}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    [PFUser logInWithUsernameInBackground:self.emailField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
//        if (user) {
//            NSLog(@"Successful Login");
////            ChattrNavigationViewController *chattrNavController = [[ChattrNavigationViewController alloc] init];
//            //            ContactsViewController *contactsViewController = [[ContactsViewController alloc] init];
////            [self presentViewController:chattrNavController animated:YES completion:nil];
//            //            [chattrNavController pushViewController:contactsViewController animated:YES];
//            
//            
//        } else {
//            NSLog(@"Error: %@", error.description);
//            NSString *errorString = [error userInfo][@"error"];
//            if ([errorString isEqual:@"invalid login parameters"]) {
//                errorString = @"Either your username or password is wrong. Please try again.";
//            };
//            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { }];
//            UIAlertController *failedSignUp = [UIAlertController alertControllerWithTitle:@"Sign in failed." message:errorString preferredStyle:UIAlertControllerStyleAlert];
//            [failedSignUp addAction:ok];
//            [self presentViewController:failedSignUp animated:YES completion:nil];
//        }
//    }];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL isValid = YES;
    if ([sender isEqual:self.loginButton]) {
    
        NSError *error = nil;
        [PFUser logInWithUsername:self.emailField.text password:self.passwordField.text error:&error];
        NSLog(@"Error: %@", error.description);
        if (error != nil) {
            NSLog(@"Error: %@", error.description);
            NSString *errorString = [error userInfo][@"error"];
            if ([errorString isEqual:@"invalid login parameters"]) {
                errorString = @"Either your username or password is wrong. Please try again.";
            };
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { }];
            UIAlertController *failedSignUp = [UIAlertController alertControllerWithTitle:@"Sign in failed." message:errorString preferredStyle:UIAlertControllerStyleAlert];
            [failedSignUp addAction:ok];
            [self presentViewController:failedSignUp animated:YES completion:nil];
            isValid = NO;
        }
    }

    return isValid;
}




@end
