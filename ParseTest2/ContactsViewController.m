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
#import "ContactTableViewCell.h"


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
    }

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.contactsTableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshContactRequests) forControlEvents:UIControlEventValueChanged];
    
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated {
    
    //subscribe to pushes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"NewMessage"
                                               object:nil];
    
    //subscribe to user's Parse Push channel
    NSString *channelSpeller = [NSString stringWithFormat:@"user_%@", [[PFUser currentUser] email]];
    NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"'#%^&{}[]/~|\?.<,@"];
    NSString *userChannel = [[channelSpeller componentsSeparatedByCharactersInSet:chs] componentsJoinedByString:@""];
    NSLog(@"User channel to set: %@", userChannel);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    
    [currentInstallation addUniqueObject:userChannel forKey:@"channels"];
    [currentInstallation saveEventually];

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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // build me some contacts cells
    if ([self.userContacts isEqual:@[]]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noContactsCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Tap the + to add contacts.";
        return cell;
    } else {
        ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
        cell.contactEmailLabel.text = [self.userContacts[indexPath.row] email];
        PFQuery *messagesQuery = [PFQuery queryWithClassName:@"Message"];
        NSString *roomIdentifier = [self getRoomIdentifier:self.userContacts[indexPath.row]];
        [messagesQuery whereKey:@"roomIdentifier" equalTo:roomIdentifier];
        [messagesQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            if (array) {
                if ([[[array lastObject] objectForKey:@"read"] isEqualToString:@"no"] &&
                    ![[[array lastObject] objectForKey:@"sendingUserEmail"] isEqual:[PFUser currentUser].email]) {
                        cell.puppyLabel.hidden = NO;
                        cell.puppyLabel.text = @"🐶";
                } else {
                    cell.puppyLabel.hidden = YES;
                }
            }
        }];
        return cell;
    }

}




#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //send selected user to ChattrMessagesViewCongroller to handle creation of the chat room
    if ([[sender class] isEqual:[ContactTableViewCell class]]) {
        ContactTableViewCell *sendingCell = sender;
        NSIndexPath *indexPath = [self.contactsTableView indexPathForCell:sendingCell];
        ChattrMessagesViewController *destination = [segue destinationViewController];
        destination.recievingUser = self.userContacts[indexPath.row];
    }
}

-(void) refreshContactRequests {
    
    //this method is pretty well named.
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
    
    //load contact requests
    for (PFObject *contactRequest in self.contactRequests) {
        PFUser *requestingUser = contactRequest[@"requestFrom"];
        [requestingUser fetchIfNeeded];
        PFUser *currentUser = [PFUser currentUser];
        
        //display contact requests and add them if approved
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

- (void) receiveTestNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    if ([[notification name] isEqualToString:@"NewMessage"]) {
        [self refreshContactRequests];
    }
    
}

-(NSString *)getRoomIdentifier: (PFUser *) receivingUser {
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"email" ascending:YES];
    NSArray *users = @[receivingUser, [PFUser currentUser]];
    NSArray *sortedUsers = [users sortedArrayUsingDescriptors:@[sorter]];
    PFUser *firstUser = sortedUsers[0];
    PFUser *secondUser = sortedUsers[1];
    NSString *roomIdentifier = [NSString stringWithFormat:@"%@-%@", firstUser.email, secondUser.email];
    return roomIdentifier;
}



@end
