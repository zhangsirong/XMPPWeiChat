//
//  ZSRChatViewController.h
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSRChatViewController : UIViewController
/** 好友 */
//@property (nonatomic, strong) EMBuddy *buddy;
@property (nonatomic, strong) EMConversation *conversation;

@property (strong, nonatomic, readonly) NSString *chatter;

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup;
- (instancetype)initWithChatter:(NSString *)chatter conversationType:(EMConversationType)type;

@end
