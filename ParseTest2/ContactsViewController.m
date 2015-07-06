//
//  ContactsViewController.m
//  ParseTest2
//
//  Created by Lukas Thoms on 7/5/15.
//  Copyright (c) 2015 Lukas Thoms. All rights reserved.
//

#import "ContactsViewController.h"
#import "ChattrMessagesViewController.h"
#import <Parse/Parse.h>


@interface ContactsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (strong, nonatomic) NSArray *contactRequests;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *requestButton;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentUser = [PFUser currentUser];
    self.contactsTableView.delegate = self;
    self.contactsTableView.dataSource = self;
    self.userContacts = [self.currentUser objectForKey:@"contacts"];
    for (PFUser *contact in self.userContacts) {
        [contact fetchIfNeeded];
        
    
    NSString *channelSpeller = [NSString stringWithFormat:@"user_%@", [[PFUser currentUser] email]];
    NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"'#%^&{}[]/~|\?.<,@"];
    NSString *userChannel = [[channelSpeller componentsSeparatedByCharactersInSet:chs] componentsJoinedByString:@""];
        NSLog(@"User channel to set: %@", userChannel);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    NSLog(@"Channels: %@", currentInstallation.channels);
    
    [currentInstallation addUniqueObject:userChannel forKey:@"channels"];
    [currentInstallation saveEventually];
    NSLog(@"Channels: %@", currentInstallation.channels);
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.contactsTableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshContactRequests) forControlEvents:UIControlEventValueChanged];
    
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated {

    [self refreshContactRequests];
    
    [self.contactsTableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.userContacts.count == 0 || [self.userContacts isEqual:nil]) {
        return 1;
    } else {
        return self.userContacts.count;
    }
    
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([self.userContacts isEqual:@[]]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noContactsCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Tap the + to add contacts.";
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
        cell.textLabel.text = [self.userContacts[indexPath.row] email];
        return cell;
    }

}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[sender class] isEqual:[UITableViewCell class]]) {
        UITableViewCell *sendingCell = sender;
        NSIndexPath *indexPath = [self.contactsTableView indexPathForCell:sendingCell];
        ChattrMessagesViewController *destination = [segue destinationViewController];
        destination.recievingUser = self.userContacts[indexPath.row];
    }
}

-(void) refreshContactRequests {
    
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *requestsQuery = [PFQuery queryWithClassName:@"contactRequest"];
    [requestsQuery whereKey:@"requestTo" equalTo:currentUser];
    [requestsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            self.contactRequests = objects;
            NSString *requestQueue = [NSString stringWithFormat:@"Requests(%lu)", (unsigned long)objects.count];
            self.requestButton.title = requestQueue;
        }
    }];
    [self.refreshControl endRefreshing];
    [self.contactsTableView reloadData];
}



- (IBAction)requestsButtonTapped:(id)sender {
    for (PFObject *contactRequest in self.contactRequests) {
        PFUser *requestingUser = contactRequest[@"requestFrom"];
        [requestingUser fetchIfNeeded];
        PFUser *currentUser = [PFUser currentUser];
        NSString *requestAlertTitle = [NSString stringWithFormat:@"%@ is requesting you add them as a contact.", requestingUser.email];
        UIAlertController *requestChooser = [UIAlertController alertControllerWithTitle:requestAlertTitle
                                                                                message:@"What would you like to do?"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSArray *currentContacts = currentUser[@"contacts"];
            NSMutableArray *mutableContacts = [currentContacts mutableCopy];
            [mutableContacts addObject:requestingUser];
            currentUser[@"contacts"] = mutableContacts;
            [currentUser save];
            [contactRequest deleteInBackground];
            [self refreshContactRequests];
            self.userContacts = [self.currentUser objectForKey:@"contacts"];
            [self.contactsTableView reloadData];
            
            
        }];
        [requestChooser addAction:add];
        
        UIAlertAction *ignore = [UIAlertAction actionWithTitle:@"Ignore" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [contactRequest deleteInBackground];
            [self refreshContactRequests];
        }];
        [requestChooser addAction:ignore];
        [self presentViewController:requestChooser animated:YES completion:nil];
    }
    
}



@end
