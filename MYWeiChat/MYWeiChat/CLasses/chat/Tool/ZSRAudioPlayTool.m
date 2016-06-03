//
//  ZSRAudioPlayTool.m
//  MYWeiChat
//
//  Created by hp on 6/3/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRAudioPlayTool.h"
#import "EMCDDeviceManager.h"

static UIImageView *animatingImageView;//正在执行动画的ImageView


@implementation ZSRAudioPlayTool

+(void)playWithMessage:(EMMessage *)msg msgButton:(UIButton *)msgButton isSend:(BOOL)isSend{
    
    // 把以前的动画移除
    [animatingImageView stopAnimating];
    [animatingImageView removeFromSuperview];
    
    //1.播放语音
    //获取语音路径
    EMVoiceMessageBody *voiceBody = msg.messageBodies[0];
    
    // 本地语音文件路径
    NSString *path = voiceBody.localPath;
    
    // 如果本地语音文件不存在，使用服务器语音
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        path = voiceBody.remotePath;
    }
    
    [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:path completion:^(NSError *error) {
        
        NSLog(@"语音播放完成 %@",error);
        // 移除动画
        [animatingImageView stopAnimating];
        [animatingImageView removeFromSuperview];
        
        
    }];
    
    //2.添加动画
    //2.1创建一个UIImageView 添加到Label上
    UIImageView *imgView = [[UIImageView alloc] init];
    [msgButton addSubview:imgView];
    
    //2.2添加动画图片
    if (isSend) {
        imgView.animationImages = @[[UIImage imageNamed:@"chat_sender_audio_playing_000"],
                                    [UIImage imageNamed:@"chat_sender_audio_playing_001"],
                                    [UIImage imageNamed:@"chat_sender_audio_playing_002"],
                                    [UIImage imageNamed:@"chat_sender_audio_playing_003"]];
        
        imgView.frame = CGRectMake(msgButton.bounds.size.width - 40, 0, 40, 40);
      
    }else{
        imgView.animationImages = @[[UIImage imageNamed:@"chat_receiver_audio_playing000"],
                                    [UIImage imageNamed:@"chat_receiver_audio_playing001"],
                                    [UIImage imageNamed:@"chat_receiver_audio_playing002"],
                                    [UIImage imageNamed:@"chat_receiver_audio_playing003"]];
        imgView.frame = CGRectMake(0, 0, 40, 40);
    }
    
    imgView.animationDuration = 1;
    [imgView startAnimating];
    animatingImageView = imgView;
    
}
@end
