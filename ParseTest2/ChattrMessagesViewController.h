//
//  ChattrMessagesViewController.h
//  ParseTest2
//
//  Created by Lukas Thoms on 7/5/15.
//  Copyright (c) 2015 Lukas Thoms. All rights reserved.
//

#import "SOMessagingViewController.h"
#import "ChattrMessage.h"
#import <Parse/Parse.h>

@interface ChattrMessagesViewController : SOMessagingViewController

@property (strong, nonatomic) PFUser *recievingUser;

@end
