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
//语音
@property (nonatomic, weak)UIButton *voiceView;
@property (nonatomic, weak)UILabel *voiceTimeLabel;

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
        
        //3.头像
        UIImageView *icon = [[UIImageView alloc]init];
        [self.contentView addSubview:icon];
        self.iconView = icon;
        
        //4.语音
        UIButton *voiceView = [[UIButton alloc]init];
        voiceView.titleLabel.font = bBtnFont;
        voiceView.titleLabel.numberOfLines = 0;//自动换行
        voiceView.contentEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        [voiceView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:voiceView];
        self.voiceView = voiceView;
        
        UILabel *voiceTimeLabel = [[UILabel alloc]init];
        voiceTimeLabel.textAlignment = NSTextAlignmentCenter;
        voiceTimeLabel.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:voiceTimeLabel];
        self.voiceTimeLabel = voiceTimeLabel;
        
        self.backgroundColor = [UIColor clearColor];//请cell的背景颜色，contentView 是只读的
    }
    return self;
}

//设置内容和frame
- (void)setFrameMessage:(ZSRMessageFrameModel *)frameMessage
{
    //这行必须带上
    _frameMessage = frameMessage;
    
    ZSRMessageModel *model = frameMessage.msgModel;
    
    //1.时间
    self.time.frame = frameMessage.timeF;
    self.time.text = model.time;
    
    //2.头像
    self.iconView.frame = frameMessage.headImageF;
    
    if (model.isSender) {
        self.iconView.image = [UIImage imageNamed:@"Gatsby"];
    }else{
        self.iconView.image = [UIImage imageNamed:@"Jobs"];
    }
    
    //3.正文
    self.textView.frame = frameMessage.textViewF;
    self.voiceView.frame = frameMessage.voiceImageF;
    self.voiceTimeLabel.frame = frameMessage.voiceTimeF;
    switch (model.type) {
            
        case eMessageBodyType_Text:
            [self.textView setTitle:model.text forState:UIControlStateNormal];
        break;
            
        case eMessageBodyType_Voice:
            [self.textView setTitle:@"" forState:UIControlStateNormal];
            self.voiceTimeLabel.text = [NSString stringWithFormat:@"%ld\"",model.voiceTime];
        break;
        default:
            ZSRLog(@"未知类型");
        break;
    }
 
    if (model.isSender) {
        //设置正文的背景图片
        [self.textView setBackgroundImage:[UIImage resizeWithImageName:@"chat_send_nor"] forState:UIControlStateNormal];

        [self.voiceView setBackgroundImage:[UIImage imageNamed:@"chat_sender_audio_playing_full"] forState:UIControlStateNormal];
    }else{
        //设置正文的背景图片
        [self.textView setBackgroundImage:[UIImage resizeWithImageName:@"chat_recive_nor"] forState:UIControlStateNormal];
        [self.voiceView setBackgroundImage:[UIImage imageNamed:@"chat_receiver_audio_playing_full"] forState:UIControlStateNormal];

    }
}
#pragma mark 返回语音富文本
-(NSAttributedString *)voiceAtt{
    // 创建一个可变的富文本
    NSMutableAttributedString *voiceAttM = [[NSMutableAttributedString alloc] init];
    
    // 1.接收方： 富文本 ＝ 图片 + 时间
//    if ([self.reuseIdentifier isEqualToString:ReceiverCell]) {
    if (!self.frameMessage.msgModel.isSender) {
        // 1.1接收方的语音图片
        UIImage *receiverImg = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
        
        // 1.2创建图片附件
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc] init];
        imgAttachment.image = receiverImg;
        imgAttachment.bounds = CGRectMake(0, -7, 30, 30);
        // 1.3图片富文本
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        [voiceAttM appendAttributedString:imgAtt];
        
        // 1.4.创建时间富文本
        // 获取时间
        EMVoiceMessageBody *voiceBody =  (EMVoiceMessageBody *)self.frameMessage.msgModel.messageBody;
        NSInteger duration = voiceBody.duration;
        NSString *timeStr = [NSString stringWithFormat:@"%ld'",duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeStr];
        [voiceAttM appendAttributedString:timeAtt];
        
    }else{
        // 2.发送方：富文本 ＝ 时间 + 图片
        // 2.1 拼接时间
        // 获取时间
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody *)self.frameMessage.msgModel.messageBody;
        NSInteger duration = voiceBody.duration;
        NSString *timeStr = [NSString stringWithFormat:@"%ld'",duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeStr];
        [voiceAttM appendAttributedString:timeAtt];
        
        
        // 2.1拼接图片
        UIImage *receiverImg = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
        
        // 创建图片附件
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc] init];
        imgAttachment.image = receiverImg;
        imgAttachment.bounds = CGRectMake(0, -7, 30, 30);
        // 图片富文本
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        [voiceAttM appendAttributedString:imgAtt];
        
    }
    
    return [voiceAttM copy];
    
}

@end
