//
//  UIResponder+Router.h
//  MYWeiChat
//
//  Created by hp on 6/13/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    kRouterEventChatHeadImageTapEventType = 0,
    kRouterEventImageBubbleTapEventType,
    kRouterEventAudioBubbleTapEventType,
    kRouterEventChatCellVideoTapEventType,
    kRouterEventLocationBubbleTapEventType,
    kRouterEventTextURLTapEventType,
    kRouterEventMenuTapEventType,
    kRouterEventChatCellBubbleTapEventType
    
} ZSRRouterpEventType;

@interface UIResponder (Router)
/**
 *  发送一个路由器消息, 对eventType感兴趣的 UIResponsder 可以对消息进行处理
 *
 *  @param eventType 发生的事件类型
 *  @param userInfo  传递消息时, 携带的数据, 数据传递过程中, 会有新的数据添加
 *
 */
- (void)routerEventWithName:(ZSRRouterpEventType)eventType userInfo:(NSDictionary *)userInfo;
@end
