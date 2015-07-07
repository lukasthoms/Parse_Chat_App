//
//  ContactTableViewCell.h
//  ParseTest2
//
//  Created by Lukas Thoms on 7/6/15.
//  Copyright (c) 2015 Lukas Thoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *puppyLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactEmailLabel;

@end
