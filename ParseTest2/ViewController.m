//
//  ViewController.m
//  ParseTest2
//
//  Created by Lukas Thoms on 6/29/15.
//  Copyright (c) 2015 Lukas Thoms. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *testField;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (strong, nonatomic) NSString *currentUserPhone;
@property (strong, nonatomic) NSString *sendingToUserPhone;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentUserPhone = @"3097889881";
    self.sendingToUserPhone=@"3092694613";
    
//    NSString *channelToAdd = [NSString stringWithFormat:@"user_%@", self.currentUserPhone];
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    NSLog(@"%@", currentInstallation.channels);
//    [currentInstallation addUniqueObject:channelToAdd forKey:@"channels"];
//    [currentInstallation saveInBackground];
    
//    NSLog(@"%@", currentInstallation.channels);
//    
//

    
    
    
}

-(void)viewDidAppear:(BOOL)animated {

    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation saveInBackground]; 

//    if (![[currentInstallation channels] containsObject:channelToAdd]) {
//        [currentInstallation addUniqueObject:@"Lukas" forKey:@"channels"];
//        NSLog(@"%@", currentInstallation.channels);
//        [currentInstallation save];
//    }
//    NSLog(@"%@", currentInstallation.channels);
//    [currentInstallation saveInBackground];
    
}
- (IBAction)saveTestTapped:(id)sender {
    
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = self.testField.text;
    [testObject saveInBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessageTapped:(id)sender {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    PFObject *messageObject = [PFObject objectWithClassName:@"Message"];
    messageObject[@"content"] = self.messageField.text;
    messageObject[@"senderInstallID"] = currentInstallation.installationId;
    messageObject[@"currentUserPhone"] = self.currentUserPhone;
    messageObject[@"sendingToUserPhone"] = self.sendingToUserPhone;

    [messageObject saveInBackground];
    
}

@end
