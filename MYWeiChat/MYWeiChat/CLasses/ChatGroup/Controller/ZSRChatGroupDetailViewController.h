//
//  ZSRChatGroupDetailViewController.h
//  MYWeiChat
//
//  Created by hp on 6/20/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ZSRGroupOccupantTypeOwner,//创建者
    ZSRGroupOccupantTypeMember,//成员
}ZSRGroupOccupantType;

@interface ZSRChatGroupDetailViewController : UITableViewController<IChatManagerDelegate>

- (instancetype)initWithGroup:(EMGroup *)chatGroup;

- (instancetype)initWithGroupId:(NSString *)chatGroupId;
@end
