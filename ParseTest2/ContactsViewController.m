//
//  ContactsViewController.m
//  ParseTest2
//
//  Created by Lukas Thoms on 7/5/15.
//  Copyright (c) 2015 Lukas Thoms. All rights reserved.
//

#import "ContactsViewController.h"


@interface ContactsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentUser = [PFUser currentUser];
    self.contactsTableView.delegate = self;
    self.contactsTableView.dataSource = self;
    self.userContacts = [self.currentUser objectForKey:@"contacts"];
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated {
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
