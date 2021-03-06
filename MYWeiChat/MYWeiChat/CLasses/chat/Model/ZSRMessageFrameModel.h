//
//  ZSRMessageFrameModel.h
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZSRMessageModel;
@interface ZSRMessageFrameModel : NSObject

//时间的frame
@property (nonatomic, assign,readonly)CGRect timeF;


//背景frame
@property (nonatomic, assign,readonly)CGRect backgroundF;

//正文的frame
@property (nonatomic, assign,readonly)CGRect textViewF;

//头像
@property (nonatomic, assign,readonly)CGRect headImageF;
//姓名
@property (nonatomic, assign,readonly)CGRect nameLabelF;

//声音
@property (nonatomic, assign,readonly)CGRect voiceImageF;
@property (nonatomic, assign,readonly)CGRect voiceTimeF;

//图片
@property (nonatomic, assign,readonly)CGRect imageViewF;

//视频
@property (nonatomic, assign,readonly)CGRect videoViewF;
//视频
@property (nonatomic, assign,readonly)CGRect videoPlayButtonF;

//cellH
@property (nonatomic, assign,readonly)CGFloat cellH;

//数据模型
@property (nonatomic, strong)ZSRMessageModel* msgModel;
@end
