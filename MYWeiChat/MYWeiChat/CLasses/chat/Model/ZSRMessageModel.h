//
//  ZSRMessageModel.h
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KFIRETIME 20
@interface ZSRMessageModel : NSObject
{
    BOOL _isPlaying;
}
//时间
@property (nonatomic, copy)NSString *time;

@property (nonatomic,assign)BOOL hideTime; //是否隐藏时间

@property (nonatomic) MessageBodyType type;
@property (nonatomic, readonly) MessageDeliveryState status;

@property (nonatomic) BOOL isSender;    //是否是发送者
@property (nonatomic) BOOL isRead;      //是否已读
@property (nonatomic) EMMessageType messageType;  // 消息类型（单聊，群里，聊天室）

@property (nonatomic, strong, readonly) NSString *messageId;
@property (nonatomic, strong) NSURL *headImageURL;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *username;

//text
@property (nonatomic, strong) NSString *text;

//image
@property (nonatomic) CGSize imageSize;
@property (nonatomic) CGSize thumbImageSize;

@property (nonatomic, strong) NSString  *imageRemotePath;
@property (nonatomic, strong) NSString *thumbImageRemotePath;
@property (nonatomic, strong) NSString *thumbImageLocalPath;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnailImage;

//audio
@property (nonatomic, strong) NSString *localPath;
@property (nonatomic, strong) NSString *remotePath;
@property (nonatomic) NSInteger voiceTime;
@property (nonatomic, strong) EMChatVoice *chatVoice;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isPlayed;

//video
@property (nonatomic) CGSize videoSize;
@property (nonatomic, strong) NSString  *videoRemotePath;

@property (nonatomic, strong) NSString *thumbVideoRemotePath;


@property (nonatomic, strong) UIImage *thumbVideoImage;
@property (nonatomic, strong) NSString *thumbVideoImageLocalPath;
@property (nonatomic, strong) NSString *thumbVideoImageRemotePath;



//location
@property (nonatomic, strong) NSString *address;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (nonatomic, strong)id<IEMMessageBody> messageBody;
@property (nonatomic, strong)EMMessage *message;
@end
