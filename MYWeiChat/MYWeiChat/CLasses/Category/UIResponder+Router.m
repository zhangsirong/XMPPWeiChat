//
//  UIResponder+Router.m
//  MYWeiChat
//
//  Created by hp on 6/13/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "UIResponder+Router.h"


@implementation UIResponder (Router)
- (void)routerEventWithName:(ZSRRouterpEventType)eventType userInfo:(NSDictionary *)userInfo
{
    [[self nextResponder] routerEventWithName:eventType userInfo:userInfo];
}
@end
