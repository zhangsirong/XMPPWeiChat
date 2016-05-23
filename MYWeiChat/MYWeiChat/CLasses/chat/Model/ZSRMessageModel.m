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

@end
