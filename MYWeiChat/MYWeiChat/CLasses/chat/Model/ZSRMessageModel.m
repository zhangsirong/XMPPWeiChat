//
//  ZSRMessageModel.m
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRMessageModel.h"
#import "ZSRTimeTool.h"
@implementation ZSRMessageModel
- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        //code
    }
    
    return self;
}

- (void)dealloc{
    
}

- (NSString *)messageId
{
    return _message.messageId;
}

- (MessageDeliveryState)status
{
    return _message.deliveryState;
}

-(id<IEMMessageBody>)messageBody
{
    return _message.messageBodies.firstObject;
}

- (MessageBodyType)type
{
    return self.messageBody.messageBodyType;
}

- (NSString *)text
{
    return ((EMTextMessageBody *)self.messageBody).text;
}

-(NSString *)time
{
    return [ZSRTimeTool timeStr:self.message.timestamp];
}

-(NSInteger)voiceTime
{
    return ((EMVoiceMessageBody *)self.messageBody).duration;

}

-(CGSize)imageSize
{
    return ((EMImageMessageBody *)self.messageBody).size;
}

- (CGSize)thumbImageSize
{
    return ((EMImageMessageBody *)self.messageBody).thumbnailSize;

}

- (NSString *)thumbImageLocalPath
{
    return ((EMImageMessageBody *)self.messageBody).thumbnailLocalPath;

}

-(NSString *)thumbImageRemotePath
{
    return ((EMImageMessageBody *)self.messageBody).thumbnailRemotePath;

}

-(CGSize)videoSize{
    
    return ((EMVideoMessageBody *)self.messageBody).size;
}

- (NSString *)videoRemotePath
{
    return ((EMVideoMessageBody *)self.messageBody).remotePath;
}

-(NSString *)thumbVideoImageLocalPath
{
    return ((EMVideoMessageBody *)self.messageBody).thumbnailLocalPath;
}

- (NSString *)thumbVideoImageRemotePath{
    return ((EMVideoMessageBody *)self.messageBody).thumbnailRemotePath;

}

- (UIImage *)thumbVideoImage
{
    return [UIImage imageWithContentsOfFile:((EMVideoMessageBody *)self.messageBody).thumbnailRemotePath];
}


@end
