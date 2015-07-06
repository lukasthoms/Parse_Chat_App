//
//  AddContactViewController.m
//  ParseTest2
//
//  Created by Lukas Thoms on 7/5/15.
//  Copyright (c) 2015 Lukas Thoms. All rights reserved.
//

#import "AddContactViewController.h"
#import <Parse/Parse.h>

@interface AddContactViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchField;

@end

@implementation AddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addButtonTapped:(id)sender {
    
    PFQuery *phoneQuery = [PFUser query];
    [phoneQuery whereKey:@"phone" equalTo:self.searchField.text];

    [phoneQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {   NSLog(@"Error: %@", error.description);
         NSLog(@"Objects: %@", objects);
         if (objects.count == 1) {
             PFUser *user = [PFUser currentUser];
             NSMutableArray *newContactArray = user[@"contacts"];
             [newContactArray addObjectsFromArray:objects];
             user[@"contacts"] = newContactArray;


             
             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if (succeeded) {
                     UIAlertController *saving = [UIAlertController alertControllerWithTitle:@"Contact Added" message:nil preferredStyle:UIAlertControllerStyleAlert];
                     UIAlertAction *addMore = [UIAlertAction actionWithTitle:@"Add another." style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { }];
                     [saving addAction:addMore];
                     UIAlertAction *done = [UIAlertAction actionWithTitle:@"I'm done." style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                         [self dismissViewControllerAnimated:YES completion:nil];
                     }];
                     [saving addAction:done];
                     [self presentViewController:saving animated:YES completion:nil];
                     
                    
                 } else {
                     NSString *errorDescription = [NSString stringWithFormat:@"%@, please try again.", error.description];
                     UIAlertController *failedSave = [UIAlertController alertControllerWithTitle:@"Something went wrong."
                                                                                         message:errorDescription
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                     UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Continue."
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) { }];
                     [failedSave addAction:ok];
                     [self presentViewController:failedSave animated:YES completion:nil];
                     
                 }
             }];
         } else {
             UIAlertController *failedSearch = [UIAlertController alertControllerWithTitle:@"We couldn't find anyone."
                                                                                   message:@"Make sure to ask them if they've signed up!"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *cool = [UIAlertAction actionWithTitle:@"Fine."
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) { }];
             [failedSearch addAction:cool];
             [self presentViewController:failedSearch animated:YES completion:nil];
             
         }
     }];
}
- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
