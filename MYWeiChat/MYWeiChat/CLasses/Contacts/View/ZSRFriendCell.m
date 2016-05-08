//
//  ZSRFriendCell.m
//  MYWeiChat
//
//  Created by hp on 5/8/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRFriendCell.h"
#import "ZSRFriend.h"
@implementation ZSRFriendCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"friend";
    ZSRFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[ZSRFriendCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

- (void)setFriendData:(ZSRFriend *)friendData
{
    _friendData = friendData;
    
    self.imageView.image = [UIImage imageNamed:friendData.icon];
    self.textLabel.text = friendData.name;
    self.textLabel.textColor = friendData.isVip ? [UIColor redColor] : [UIColor blackColor];
    self.detailTextLabel.text = friendData.intro;
}
@end
