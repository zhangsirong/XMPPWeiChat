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
- (void)setMessage:(ZSRMessageModel *)message
{
    _message = message;
    
    CGFloat padding = 10;
    //1. 时间
    if (message.hideTime == NO) {
        CGFloat timeX = 0;
        CGFloat timeY = 0;
        CGFloat timeW = ScreenW;
        CGFloat timeH = bNormalH;
        
        _timeF = CGRectMake(timeX, timeY, timeW, timeH);
    }
    
    
    
    
    //2.头像
    CGFloat iconX;
    CGFloat iconY = CGRectGetMaxY(_timeF);
    CGFloat iconW = bIconW;
    CGFloat iconH = bIconH;
    
    if (message.isOutgoing) {//自己发的
        
        iconX = ScreenW - iconW - padding;
        
    }else{//别人发的
        iconX = padding;
    }
    
    _iconF =  CGRectMake(iconX, iconY, iconW, iconH);
    
    
    
    if (message.photo) {
        //4图像
        CGFloat imageX;
        CGFloat imageY = iconY+ padding;
        CGFloat imageW = bImageW;
        CGFloat imageH = bImageH;
        
        if (message.isOutgoing) {//自己发的
            
            imageX = bScreenWidth - iconW - padding;
            
        }else{//别人发的
            imageX = padding + iconW * 2;
        }
        _imageViewF =  CGRectMake(imageX, imageY, imageW, imageH);
    } else {
        //3.正文
        
        CGFloat textX;
        CGFloat textY = iconY+ padding;
        
        CGSize textMaxSize = CGSizeMake(150, MAXFLOAT);
        CGSize textRealSize = [message.text boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:bBtnFont} context:nil].size;
        
        CGSize btnSize = CGSizeMake(textRealSize.width + 40, textRealSize.height + 40);
        
        if (message.isOutgoing) {
            textX = bScreenWidth - iconW - padding*2 - btnSize.width;
        }else{
            textX = padding + iconW;
        }
        
        //    _textViewF = CGRectMake(textX, textY, <#CGFloat width#>, <#CGFloat height#>)
        _textViewF = (CGRect){{textX,textY},btnSize};
        
    }
    
    
    //4.cell高度
    
    CGFloat iconMaxY = CGRectGetMaxY(_iconF);
    CGFloat textMaxY = MAX(CGRectGetMaxY(_textViewF), CGRectGetMaxY(_imageViewF));
    
    _cellH = MAX(iconMaxY, textMaxY);
    
    
}
@end
