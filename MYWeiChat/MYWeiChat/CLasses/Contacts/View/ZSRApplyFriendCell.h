//
//  ZSRApplyFriendCell.h
//  MYWeiChat
//
//  Created by hp on 6/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ZSRApplyFriendCellDelegate;

@interface ZSRApplyFriendCell : UITableViewCell

@property (nonatomic) id<ZSRApplyFriendCellDelegate> delegate;

@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) UIImageView *headerImageView;//头像
@property (strong, nonatomic) UILabel *titleLabel;//标题
@property (strong, nonatomic) UILabel *contentLabel;//详情
@property (strong, nonatomic) UIButton *addButton;//接受按钮
@property (strong, nonatomic) UIButton *refuseButton;//拒绝按钮
@property (strong, nonatomic) UIView *bottomLineView;

+ (CGFloat)heightWithContent:(NSString *)content;

@end

@protocol ZSRApplyFriendCellDelegate <NSObject>

- (void)applyCellAddFriendAtIndexPath:(NSIndexPath *)indexPath;
- (void)applyCellRefuseFriendAtIndexPath:(NSIndexPath *)indexPath;
@end