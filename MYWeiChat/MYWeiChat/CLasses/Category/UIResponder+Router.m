//
//  UIResponder+Router.m
//  MYWeiChat
//
//  Created by hp on 6/13/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "UIResponder+Router.h"


@implementation UIResponder (Router)
- (void)routerEventWithName:(ZSRRouterpEventType)eventName userInfo:(NSDictionary *)userInfo
{
    [[self nextResponder] routerEventWithName:eventName userInfo:userInfo];
}
@end
