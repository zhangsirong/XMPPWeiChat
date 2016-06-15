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
#import "ZSRAudioPlayTool.h"
#import "EMCDDeviceManager.h"
#import "UIImageView+WebCache.h"
#import "UIResponder+Router.h"

@interface ZSRMessageCell()

//时间
@property (nonatomic, weak)UILabel *timeLabel;

//用户头像
@property (nonatomic, weak)UIImageView *headImageView;

//背景
@property (nonatomic, weak)UIButton *textView;

//正文
@property (nonatomic, weak)UIButton *backgView;

//语音
@property (nonatomic, weak)UIButton *voiceView;
@property (nonatomic, weak)UILabel *voiceTimeLabel;

//图片
@property (nonatomic, weak)UIImageView *chatImgView;

//视频图片
@property (nonatomic, weak)UIImageView *videoImgView;


@property (nonatomic, strong)NSMutableArray *photos;

@property (nonatomic, weak)UIButton *videoPlayButton;



@end

@implementation ZSRMessageCell
+ (instancetype)messageCellWithTableView:(UITableView *)tableview
{
    static NSString *ID = @"messageCell";
    ZSRMessageCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        
        cell = [[self alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       
    }
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //1.时间
        UILabel *timeLabel = [[UILabel alloc]init];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        UITapGestureRecognizer *headImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImagePressed:)];
        //2.头像
        UIImageView *headImageView = [[UIImageView alloc]init];
        [headImageView addGestureRecognizer:headImageTap];
        headImageView.userInteractionEnabled = YES;
        headImageView.multipleTouchEnabled = YES;
        [self.contentView addSubview:headImageView];
        self.headImageView = headImageView;
        
        //3.背景
        UIButton *backgView = [[UIButton alloc]init];
        backgView.titleLabel.font = bBtnFont;
        backgView.titleLabel.numberOfLines = 0;//自动换行
        backgView.contentEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        [backgView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:backgView];
        self.backgView = backgView;
        
        //4.正文
        UIButton *textView = [[UIButton alloc]init];
        textView.titleLabel.font = bBtnFont;
        textView.titleLabel.numberOfLines = 0;//自动换行
        textView.contentEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        [textView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:textView];
        self.textView = textView;
        
        //5.语音
        UIButton *voiceView = [[UIButton alloc]init];
        voiceView.contentEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        [voiceView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:voiceView];
        self.voiceView = voiceView;
        [self.voiceView addTarget:self action:@selector(voiceViewAction) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *voiceTimeLabel = [[UILabel alloc]init];
        voiceTimeLabel.textAlignment = NSTextAlignmentCenter;
        voiceTimeLabel.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:voiceTimeLabel];
        self.voiceTimeLabel = voiceTimeLabel;
        
        //6.图片
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePressed:)];

        UIImageView *imgView = [[UIImageView alloc] init];
        [imgView addGestureRecognizer:imageTap];
        imgView.userInteractionEnabled = YES;
        imgView.multipleTouchEnabled = YES;
        [self.contentView addSubview:imgView];
        self.chatImgView = imgView;

        
        //6.视频图片
        
        UIImageView *videoImgView = [[UIImageView alloc] init];
        [self.contentView addSubview:videoImgView];
        self.videoImgView = videoImgView;
        
        
        UIButton *videoPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [videoPlayButton addTarget:self action:@selector(videoPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:videoPlayButton];

        self.videoPlayButton = videoPlayButton;
        
        self.backgroundColor = [UIColor clearColor];//请cell的背景颜色，contentView 是只读的
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)voiceViewAction{
    
    BOOL isSend = self.frameMessage.msgModel.isSender;
    [ZSRAudioPlayTool playWithMessage:self.frameMessage.msgModel.message msgButton:self.voiceView isSend:isSend];
    ZSRLog(@"播放语音");
//    [super routerEventWithName:kRouterEventAudioBubbleTapEventType userInfo:@{KMESSAGEKEY:self.frameMessage.msgModel}];

}

- (void)routerEventWithName:(ZSRRouterpEventType)eventName userInfo:(NSDictionary *)userInfo
{
    [super routerEventWithName:eventName userInfo:userInfo];
}

-(void)headImagePressed:(id)sender
{
    [super routerEventWithName:kRouterEventChatHeadImageTapEventType userInfo:@{KMESSAGEKEY:self.frameMessage.msgModel}];
}

-(void)imagePressed:(id)sender{
    [super routerEventWithName:kRouterEventImageBubbleTapEventType userInfo:@{KMESSAGEKEY:self.frameMessage.msgModel}];

}

-(void)videoPressed:(id)sender
{
    [super routerEventWithName:kRouterEventChatCellVideoTapEventType userInfo:@{KMESSAGEKEY:self.frameMessage.msgModel}];
}

//设置内容和frame
- (void)setFrameMessage:(ZSRMessageFrameModel *)frameMessage
{
    _frameMessage = frameMessage;
    ZSRMessageModel *model = frameMessage.msgModel;
    
    //1.时间
    self.timeLabel.frame = frameMessage.timeF;
    self.timeLabel.text = model.time;
    
    //2.头像
    self.headImageView.frame = frameMessage.headImageF;
    
    if (model.isSender) {
        self.headImageView.image = [UIImage imageNamed:@"Gatsby"];
        
    }else{
        self.headImageView.image = [UIImage imageNamed:@"Jobs"];
    }
    
    
    //3.正文
    self.backgView.frame = frameMessage.backgroundF;
    self.textView.frame = frameMessage.textViewF;
    self.voiceView.frame = frameMessage.voiceImageF;
    self.voiceTimeLabel.frame = frameMessage.voiceTimeF;
    self.chatImgView.frame = frameMessage.imageViewF;
    self.videoImgView.frame = frameMessage.videoViewF;
    self.videoPlayButton.frame = frameMessage.videoPlayButtonF;
    if (model.isSender) {
        //设置正文的背景图片
        [self.backgView setBackgroundImage:[UIImage resizeWithImageName:@"chat_send_nor"] forState:UIControlStateNormal];
        
        [self.voiceView setBackgroundImage:[UIImage imageNamed:@"chat_sender_audio_playing_full"] forState:UIControlStateNormal];
    }else{
        //设置正文的背景图片
        [self.backgView setBackgroundImage:[UIImage resizeWithImageName:@"chat_recive_nor"] forState:UIControlStateNormal];
        [self.voiceView setBackgroundImage:[UIImage imageNamed:@"chat_receiver_audio_playing_full"] forState:UIControlStateNormal];
        
    }
    switch (model.type) {
            
        case eMessageBodyType_Text:
            [self.textView setTitle:model.content forState:UIControlStateNormal];
        break;
            
        case eMessageBodyType_Voice:
//            [self.textView setTitle:@"" forState:UIControlStateNormal];
            self.voiceTimeLabel.text = [NSString stringWithFormat:@"%ld\"",model.audioTime];
        break;
            
        case eMessageBodyType_Image:{
            UIImage *image = model.isSender ? model.image : model.thumbnailImage;
            if (!image) {
                image = model.image;
                if (!image) {
                    [self.chatImgView sd_setImageWithURL:model.imageRemoteURL placeholderImage:[UIImage imageNamed:@"imageDownloadFail.png"]];
                } else {
                    self.chatImgView.image = image;
                }
            } else {
                self.chatImgView.image = image;
            }
            
            
        }
            
        break;
        case eMessageBodyType_Video:{
            NSFileManager *manager = [NSFileManager defaultManager];
            // 如果本地视频存在，直接从本地显示图片
            UIImage *palceImg = [UIImage imageNamed:@"downloading"];
            if ([manager fileExistsAtPath:model.localPath]) {
                [self.videoImgView sd_setImageWithURL:[NSURL fileURLWithPath:model.localPath] placeholderImage:palceImg];
            }else{
                // 如果本地视频不存，从网络加载图片
                [self.videoImgView sd_setImageWithURL:model.thumbnailRemoteURL placeholderImage:palceImg];
            }
            [self.videoPlayButton setBackgroundImage:[UIImage imageNamed:@"chat_video_play"] forState:UIControlStateNormal];

        }
        break;
            
        default:
            ZSRLog(@"未知类型");
        break;
    }
}
@end
