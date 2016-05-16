//
//  ZSRMessageCell.m
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRMessageCell.h"
#import "ZSRMessageFrameModel.h"
#import "ZSRMessageModel.h"
#import "Constant.h"
#import "UIImage+ResizImage.h"

@interface ZSRMessageCell()
//时间
@property (nonatomic, weak)UILabel *time;
//正文
@property (nonatomic, weak)UIButton *textView;
//图片
@property (nonatomic, weak)UIImageView *imageView;

//用户头像
@property (nonatomic, weak)UIImageView *iconView;

@end

@implementation ZSRMessageCell
+ (instancetype)messageCellWithTableView:(UITableView *)tableview
{
    static NSString *ID = @"messageCell";
    ZSRMessageCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[self alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //1.时间
        UILabel *time = [[UILabel alloc]init];
        time.textAlignment = NSTextAlignmentCenter;
        time.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:time];
        self.time = time;
        
        //2.正文
        UIButton *textView = [[UIButton alloc]init];
        textView.titleLabel.font = bBtnFont;
        textView.titleLabel.numberOfLines = 0;//自动换行
        textView.contentEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        [textView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:textView];
        self.textView = textView;
        
        //1.头像
        UIImageView *icon = [[UIImageView alloc]init];
        [self.contentView addSubview:icon];
        self.iconView = icon;
        
        self.backgroundColor = [UIColor clearColor];//请cell的背景颜色，contentView 是只读的
    }
    return self;
}

//设置内容和frame
- (void)setFrameMessage:(ZSRMessageFrameModel *)frameMessage
{
    //这行必须带上
    _frameMessage = frameMessage;
    
    ZSRMessageModel *model = frameMessage.message;
    
    //1.时间
    self.time.frame = frameMessage.timeF;
    self.time.text = model.time;
    
    //2.头像
    self.iconView.frame = frameMessage.iconF;
    
    if (model.isOutgoing) {
        self.iconView.image = [UIImage imageNamed:@"Gatsby"];
    }else{
        self.iconView.image = [UIImage imageNamed:@"Jobs"];
    }
    
    //3.正文
    self.textView.frame = frameMessage.textViewF;
    [self.textView setTitle:model.text forState:UIControlStateNormal];
    
    
    if (model.isOutgoing) {
        //        [self.textView setBackgroundImage:[self resizeWithImageName:@"chat_send_nor"] forState:UIControlStateNormal];
        
        //设置正文的背景图片
        [self.textView setBackgroundImage:[UIImage resizeWithImageName:@"chat_send_nor"] forState:UIControlStateNormal];
    }else{
        //设置正文的背景图片
        [self.textView setBackgroundImage:[UIImage resizeWithImageName:@"chat_recive_nor"] forState:UIControlStateNormal];
    }
}


@end
