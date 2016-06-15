//
//  ZSRMessageFrameModel.m
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRMessageFrameModel.h"
#import "Constant.h"
#import "ZSRMessageModel.h"

@implementation ZSRMessageFrameModel
- (void)setMsgModel:(ZSRMessageModel *)msgModel
{
    _msgModel = msgModel;
    
    CGFloat padding = 10;
    //1. 时间
    if (msgModel.hideTime == NO) {
        CGFloat timeX = 0;
        CGFloat timeY = 0;
        CGFloat timeW = ScreenW;
        CGFloat timeH = bNormalH;
        
        _timeF = CGRectMake(timeX, timeY, timeW, timeH);
    }
    //2.头像
    CGFloat headImageX;
    CGFloat headImageY = CGRectGetMaxY(_timeF);
    CGFloat headImageW = bIconW;
    CGFloat headImageH = bIconH;
    
    if (msgModel.isSender) {//自己发的
        
        headImageX = ScreenW - headImageW - padding;
    }else{//别人发的
        headImageX = padding;
    }
    _headImageF =  CGRectMake(headImageX, headImageY, headImageW, headImageH);
    
    CGFloat backgroundX;
    CGFloat backgroundY = headImageY+ padding;
    CGSize backgSize;
    
    //3.消息
    switch (msgModel.type) {
        case eMessageBodyType_Text: //文字
        {
            CGFloat textX;
            CGFloat textY = headImageY+ padding;
            
            CGSize textMaxSize = CGSizeMake(150, MAXFLOAT);
            CGSize textRealSize = [msgModel.content boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:bBtnFont} context:nil].size;
            
           backgSize = CGSizeMake(textRealSize.width + 40, textRealSize.height + 40);
            
            if (msgModel.isSender) {
                textX = bScreenWidth - headImageW - padding*2 - backgSize.width;
                backgroundX = bScreenWidth - headImageW - padding*2 - backgSize.width;
            }else{
                textX = padding + headImageW;
                backgroundX = padding + headImageW;
            }
            
            //    _textViewF = CGRectMake(textX, textY, <#CGFloat width#>, <#CGFloat height#>)
            _textViewF = (CGRect){{textX,textY},backgSize};
        }
        break;
        case eMessageBodyType_Voice://语音
        {
            backgSize = CGSizeMake(70, 60);
            CGFloat voiceX;
            CGFloat voiceY = headImageY+ padding * 2;
            CGFloat voiceW = bVoiceW;
            CGFloat voiceH = bVoiceH;
            
            CGFloat voiceTimeX;
            CGFloat voiceTimeY = headImageY+ padding * 2;
            CGFloat voiceTimeW = bVoiceW;
            CGFloat voiceTimeH = bVoiceH;
            
            if (msgModel.isSender) {//自己发的
                backgroundX = bScreenWidth - headImageW - padding * 2 - backgSize.width;
                voiceX = bScreenWidth - headImageW - padding * 3 - bVoiceW;
                voiceTimeX = bScreenWidth - headImageW - padding * 4 - backgSize.width;
                
            }else{//别人发的
                backgroundX = padding + headImageW;
                voiceX = padding * 2 + headImageW;
                voiceTimeX = headImageW + backgSize.width - padding;

            }
            _voiceImageF =  CGRectMake(voiceX, voiceY, voiceW, voiceH);
            _voiceTimeF = CGRectMake(voiceTimeX, voiceTimeY, voiceTimeW, voiceTimeH);

        }
        break;
        case eMessageBodyType_Image://图片
        {
            
            CGFloat imageX;
            CGFloat imageY = headImageY+ padding * 2.5;
            CGFloat imageW = msgModel.thumbnailSize.width;
            CGFloat imageH = msgModel.thumbnailSize.height;
            backgSize = CGSizeMake(imageW + 30, imageH + 30);
            if (msgModel.isSender) {//自己发的
                
                imageX = bScreenWidth - headImageW - padding * 4.5 - imageW;
                backgroundX = bScreenWidth - headImageW - padding * 6  - imageW;
            }else{//别人发的
                imageX = padding * 2.5 + headImageW;
                backgroundX = headImageW + padding;
                
            }
            _imageViewF =  CGRectMake(imageX, imageY, imageW, imageH);
           
        }
        break;
      
        case eMessageBodyType_Video://视频
        {
            CGFloat videoX;
            CGFloat videoY = headImageY+ padding * 2.5;
            CGFloat videoW = msgModel.thumbnailSize.width;
            CGFloat videoH = msgModel.thumbnailSize.height;
            backgSize = CGSizeMake(videoW + 30, videoH + 30);
            
            
            
            if (msgModel.isSender) {//自己发的
                videoX = bScreenWidth - headImageW - padding * 4.5 - videoW;
                backgroundX = bScreenWidth - headImageW - padding * 6  - videoW;
            }else{//别人发的
                videoX = padding * 2.5 + headImageW;
                backgroundX = headImageW + padding;
                
            }
            
            CGFloat videoBtnX = videoX + videoW / 2- bIconW/2;
            CGFloat videoBtnY = videoY + videoH/2 - bIconH/2;
            CGFloat videoBtnW = bIconW;
            CGFloat videoBtnH = bIconH;
            _videoViewF =  CGRectMake(videoX, videoY, videoW, videoH);
            _videoPlayButtonF = CGRectMake(videoBtnX, videoBtnY, videoBtnW, videoBtnH);
            
        }
            
        break;
        case eMessageBodyType_Location://位置
            
        default:
            ZSRLog(@"未知类型");
        break;
    }
    
    _backgroundF = (CGRect){{backgroundX,backgroundY},backgSize};
    
    //4.cell高度
    CGFloat iconMaxY = CGRectGetMaxY(_headImageF);
    CGFloat textMaxY = MAX(CGRectGetMaxY(_backgroundF), CGRectGetMaxY(_imageViewF) + padding);
//    CGFloat textMaxY = CGRectGetMaxY(_backgroundF);

    
    _cellH = MAX(iconMaxY, textMaxY);
}
@end
