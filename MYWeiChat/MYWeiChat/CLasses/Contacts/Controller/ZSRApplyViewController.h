//
//  ZSRApplyViewController.h
//  MYWeiChat
//
//  Created by hp on 6/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ZSRApplyStyleFriend = 0,
    ZSRApplyStyleGroupInvitation,
    ZSRApplyStyleJoinGroup,
}ZSRApplyStyle;

@interface ZSRApplyViewController : UITableViewController
@property (strong, nonatomic) NSMutableArray *dataSource;

+ (instancetype)shareController;

- (void)addNewApply:(NSDictionary *)dictionary;

- (void)loadDataSourceFromLocalDB;

- (void)clear;
@end
