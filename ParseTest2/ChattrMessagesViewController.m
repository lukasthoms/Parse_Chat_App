//
//  ChattrMessagesViewController.m
//  ParseTest2
//
//  Created by Lukas Thoms on 7/5/15.
//  Copyright (c) 2015 Lukas Thoms. All rights reserved.
//

#import "ChattrMessagesViewController.h"

@interface ChattrMessagesViewController ()

@property (strong, nonatomic) NSMutableArray *dataStore;

@end

@implementation ChattrMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SOMessage *message1 = [[SOMessage alloc] init];
    message1.text = @"Hello world.";
    message1.date = [NSDate date];
    message1.fromMe = NO;
    message1.type = SOMessageTypeText;

    NSMutableArray *testMessages = [@[message1] mutableCopy];
    self.dataStore = testMessages;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)messages {
    
    return self.dataStore;

}

- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index
{
    SOMessage *message = self.messages[0];
    
    // Customize balloon as you wish
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
    
    SOMessage *msg = [[SOMessage alloc] init];
    msg.text = message;
    msg.fromMe = YES;
    
    [self sendMessage:msg];
}

- (void)messageInputViewDidSelectMediaButton:(SOMessageInputView *)inputView
{
    // Take a photo/video or choose from gallery
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
