//
//  ZSRMessageCell.h
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZSRMessageFrameModel;
@interface ZSRMessageCell : UITableViewCell
+ (instancetype)messageCellWithTableView:(UITableView *)tableview;

//frame 的模型
@property (nonatomic, strong)ZSRMessageFrameModel *frameMessage;

@end
