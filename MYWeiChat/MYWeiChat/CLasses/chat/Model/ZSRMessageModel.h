//
//  ZSRMessageModel.h
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSRMessageModel : NSObject

//正文
@property (nonatomic, copy)NSString *text;

//时间
@property (nonatomic, copy)NSString *time;


@property (nonatomic,copy) UIImage *photo;


//发送类型 是自己
@property (nonatomic, assign) BOOL isOutgoing;

//是否隐藏时间
@property (nonatomic,assign)BOOL hideTime;
@end
