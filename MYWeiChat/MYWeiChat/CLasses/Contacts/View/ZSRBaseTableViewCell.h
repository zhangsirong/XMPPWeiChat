//
//  ZSRContactsCell.h
//  MYWeiChat
//
//  Created by hp on 6/15/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSRBaseTableViewCell : UITableViewCell

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UIView *bottomLineView;
@property (strong, nonatomic) NSString *username;
+(instancetype)contactCellWithTableView:(UITableView *)tableview;
+(instancetype)contactCellWithTableView:(UITableView *)tableview reuseIdentifier:(NSString *)ID;
@end

@protocol contastsTableCellDelegate <NSObject>

@end
