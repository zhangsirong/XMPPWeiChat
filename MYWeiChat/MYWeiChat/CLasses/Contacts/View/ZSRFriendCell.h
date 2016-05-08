//
//  ZSRFriendCell.h
//  MYWeiChat
//
//  Created by hp on 5/8/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZSRFriend;
@interface ZSRFriendCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) ZSRFriend *friendData;
@end
