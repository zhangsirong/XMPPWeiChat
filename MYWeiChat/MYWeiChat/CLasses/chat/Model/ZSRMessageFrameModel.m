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
    
    
    //3.消息
    switch (msgModel.type) {
        case eMessageBodyType_Text: //文字
        {
            CGFloat textX;
            CGFloat textY = headImageY+ padding;
            
            CGSize textMaxSize = CGSizeMake(150, MAXFLOAT);
            CGSize textRealSize = [msgModel.text boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:bBtnFont} context:nil].size;
            
            CGSize btnSize = CGSizeMake(textRealSize.width + 40, textRealSize.height + 40);
            
            if (msgModel.isSender) {
                textX = bScreenWidth - headImageW - padding*2 - btnSize.width;
            }else{
                textX = padding + headImageW;
            }
            
            //    _textViewF = CGRectMake(textX, textY, <#CGFloat width#>, <#CGFloat height#>)
            _textViewF = (CGRect){{textX,textY},btnSize};
        }
            break;
        case eMessageBodyType_Voice://语音
        {
            
            CGFloat textX;
            CGFloat textY = headImageY+ padding;
            CGSize btnSize = CGSizeMake(70, 60);

            CGFloat voiceX;
            CGFloat voiceY = headImageY+ padding * 2;
            CGFloat voiceW = bVoiceW;
            CGFloat voiceH = bVoiceH;
            
            CGFloat voiceTimeX;
            CGFloat voiceTimeY = headImageY+ padding * 2;
            CGFloat voiceTimeW = bVoiceW;
            CGFloat voiceTimeH = bVoiceH;
            
            if (msgModel.isSender) {//自己发的
                
                textX = bScreenWidth - headImageW - padding * 2 - btnSize.width;
                voiceX = bScreenWidth - headImageW - padding * 3 - bVoiceW;
                voiceTimeX = bScreenWidth - headImageW - padding * 4 - btnSize.width;
                
            }else{//别人发的
                textX = padding + headImageW;
                voiceX = padding * 2 + headImageW;
                voiceTimeX = headImageW + btnSize.width - padding;

            }
            _textViewF = (CGRect){{textX,textY},btnSize};
            _voiceImageF =  CGRectMake(voiceX, voiceY, voiceW, voiceH);
            _voiceTimeF = CGRectMake(voiceTimeX, voiceTimeY, voiceTimeW, voiceTimeH);

        }
            break;
        case eMessageBodyType_Image://图片
        {
            CGFloat imageX;
            CGFloat imageY = headImageY+ padding;
            CGFloat imageW = msgModel.thumbnailSize.width;
            CGFloat imageH = msgModel.thumbnailSize.height;
            
            if (msgModel.isSender) {//自己发的
                
                imageX = bScreenWidth - headImageW - padding * 2 - imageW;
                
            }else{//别人发的
                imageX = padding * 2 + headImageW;
            }
            _imageViewF =  CGRectMake(imageX, imageY, imageW, imageH);

        }
            break;
      
        case eMessageBodyType_Video://视频
            break;
        case eMessageBodyType_Location://位置
            
        default:
            ZSRLog(@"未知类型");
            break;
    }
        //4.cell高度
    CGFloat iconMaxY = CGRectGetMaxY(_headImageF);
    CGFloat textMaxY = MAX(CGRectGetMaxY(_textViewF), CGRectGetMaxY(_imageViewF) + padding);
    
    _cellH = MAX(iconMaxY, textMaxY);
}
@end
