//
//  ChattrMessagesViewController.m
//  ParseTest2
//
//  Created by Lukas Thoms on 7/5/15.
//  Copyright (c) 2015 Lukas Thoms. All rights reserved.
//

#import "ChattrMessagesViewController.h"


@interface ChattrMessagesViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;

@property (strong, nonatomic) NSMutableArray *dataStore;

@property (strong, nonatomic) NSString *roomIdentifier;

@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation ChattrMessagesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.currentUser = [PFUser currentUser];
    self.roomIdentifier = [self getRoomIdentifier];
    self.navigationBar.title = self.recievingUser.email;
    NSLog(@"%@", self.roomIdentifier);
    

/* ------ test messsage w/o Parse ----------
    SOMessage *message1 = [[SOMessage alloc] init];
    message1.text = @"Hello world.";
    message1.date = [NSDate date];
    message1.fromMe = NO;
    message1.type = SOMessageTypeText;
    NSMutableArray *testMessages = [@[message1] mutableCopy];
 */

}

-(void) viewWillAppear:(BOOL)animated {
    
    //retrieve messages using roomIdenfier
    PFQuery *messagesQuery = [PFQuery queryWithClassName:@"Message"];
    [messagesQuery whereKey:@"roomIdentifier" equalTo:self.roomIdentifier];
    NSError *error = nil;
    NSArray *queryResults = [messagesQuery findObjects:&error];
    
    //convert PFObjects to SOMessages and display
    NSMutableArray *convertedMessages = [self convertToSOMessageArray:queryResults];
    self.dataStore = convertedMessages;
    if ([self.dataStore isEqual:[@[]mutableCopy]]) {
        SOMessage *typeSomething = [[SOMessage alloc] init];
        typeSomething.text = @"Send me a message!";
        typeSomething.type = SOMessageTypeText;
        typeSomething.fromMe = NO;
        self.dataStore = [@[typeSomething]mutableCopy];
    }
    [self refreshMessages];
    
    //covert all unread messages to read status
    PFQuery *unreadQuery = [PFQuery queryWithClassName:@"Message"];
    [unreadQuery whereKey:@"read" equalTo:@"no"];
    [unreadQuery whereKey:@"roomIdentifier" equalTo:self.roomIdentifier];
    [unreadQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array) {
            for (PFObject *message in array) {
                message[@"read"] = @"yes";
                [message saveInBackground];
            }
        } else {
            NSLog(@"Read Messages Error: %@", error.description);
        }
    }];
    
    //start listening for new messages
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"NewMessage"
                                               object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewMessage" object:nil];
}

- (NSMutableArray *)messages {
    //provide SOMessageView with messages array loaded in ViewDidLoad
    return self.dataStore;
}

- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index
{
    SOMessage *message = self.dataStore[index];
    
    // Customize balloon
    if (message.fromMe) {
        cell.contentInsets = UIEdgeInsetsMake(0, 3.0f, 0, 0); //Move content for 3 pt. to right
        cell.textView.textColor = [UIColor blackColor];
    } else {
        cell.contentInsets = UIEdgeInsetsMake(0, 0, 0, 3.0f); //Move content for 3 pt. to left
        cell.textView.textColor = [UIColor whiteColor];
        
    }
}

- (void)didSelectMedia:(NSData *)media inMessageCell:(SOMessageCell *)cell
{
    // Show selected media in fullscreen
    [super didSelectMedia:media inMessageCell:cell];
}

- (void)messageInputView:(SOMessageInputView *)inputView didSendMessage:(NSString *)message
{
    if (![[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return;
    }
    
    // create new SOMessage
    SOMessage *msg = [[SOMessage alloc] init];
    msg.text = message;
    msg.fromMe = YES;
    
    //create PFObject with Message class and save.
    PFObject *messageObject = [PFObject objectWithClassName:@"Message"];
    messageObject[@"content"] = msg.text;
    messageObject[@"sendingUserEmail"] = self.currentUser.email;
    messageObject[@"recievingUserEmail"] = self.recievingUser.email;
    messageObject[@"roomIdentifier"] = self.roomIdentifier;
    messageObject[@"sentTo"] = [self channelFormat:self.recievingUser.email];
    messageObject[@"read"] = @"no";
    NSLog(@"%@", [self channelFormat:self.recievingUser.email]);
    [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Message sent successfully.");
        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];
    
    [self sendMessage:msg];
}

- (void)messageInputViewDidSelectMediaButton:(SOMessageInputView *)inputView
{
    // Take a photo/video or choose from gallery
}

-(NSString *)getRoomIdentifier {
    //create unique identifier for conversation (the "Room"), ensuring the both clients generate the same identifer using a simple sort
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"email" ascending:YES];
    NSArray *users = @[self.recievingUser, [PFUser currentUser]];
    NSArray *sortedUsers = [users sortedArrayUsingDescriptors:@[sorter]];
    PFUser *firstUser = sortedUsers[0];
    PFUser *secondUser = sortedUsers[1];
    NSString *roomIdentifier = [NSString stringWithFormat:@"%@-%@", firstUser.email, secondUser.email];
    return roomIdentifier;
}

-(NSMutableArray *) convertToSOMessageArray: (NSArray*)parseMessages {
    
    //this method name is pretty self-explainitory tbh
    NSMutableArray *convertedMessages = [@[]mutableCopy];
    for (PFObject *message in parseMessages) {
        SOMessage *convertedMessage = [[SOMessage alloc] init];
        convertedMessage.text = message[@"content"];
        convertedMessage.date = message[@"createdAt"];
        convertedMessage.type = SOMessageTypeText;
        if ([message[@"sendingUserEmail"] isEqual:self.currentUser.email]) {
            convertedMessage.fromMe = YES;
        } else {
            convertedMessage.fromMe = NO;
        }
        [convertedMessages addObject:convertedMessage];
    }
    return convertedMessages;
}

-(NSString *) channelFormat: (NSString*) userEmail {
    
    NSString *channelSpeller = [NSString stringWithFormat:@"user_%@", userEmail];
    NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"'#%^&{}[]/~|\?.<,@"];
    NSString *userChannel = [[channelSpeller componentsSeparatedByCharactersInSet:chs] componentsJoinedByString:@""];
    return userChannel;
    
}

- (void) receiveTestNotification:(NSNotification *) notification
{
    // receive notification of a new message and retrieve it from Parse
    
    if ([[notification name] isEqualToString:@"NewMessage"]) {
            PFQuery *messagesQuery = [PFQuery queryWithClassName:@"Message"];
            [messagesQuery whereKey:@"roomIdentifier" equalTo:self.roomIdentifier];
            NSError *error = nil;
            NSArray *queryResults = [messagesQuery findObjects:&error];
            
            NSMutableArray *convertedMessages = [self convertToSOMessageArray:queryResults];
            self.dataStore = convertedMessages;
            [self refreshMessages];
            NSLog (@"Successfully received the test notification!");
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
