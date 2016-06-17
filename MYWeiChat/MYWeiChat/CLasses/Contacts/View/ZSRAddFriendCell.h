//
//  ZSRAddFriendCell.h
//  MYWeiChat
//
//  Created by hp on 6/17/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZSRAddFriendCellDelegete <NSObject>

- (void)cellAddFriendAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface ZSRAddFriendCell : UITableViewCell

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UIView *bottomLineView;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) UIButton *addButton;
@property (weak, nonatomic) id<ZSRAddFriendCellDelegete> delegate;

@end
