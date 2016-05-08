//
//  ZSRHeaderView.h
//  MYWeiChat
//
//  Created by hp on 5/8/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSRFriendGroup, ZSRHeaderView;


@protocol ZSRHeaderViewDelegate <NSObject>
@optional
- (void)headerViewDidClickedNameView:(ZSRHeaderView *)headerView;
@end

@interface ZSRHeaderView : UITableViewHeaderFooterView
+ (instancetype)headerViewWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) ZSRFriendGroup *group;

@property (nonatomic, weak) id<ZSRHeaderViewDelegate> delegate;

@end
