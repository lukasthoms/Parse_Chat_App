//
//  ContactsViewController.h
//  ParseTest2
//
//  Created by Lukas Thoms on 7/5/15.
//  Copyright (c) 2015 Lukas Thoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSArray *userContacts;

@end
