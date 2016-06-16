//
//  ZSRConversationViewController.m
//
//
//  Created by hp on 16/1/21.
//
//

#import "ZSRConversationViewController.h"
#import "EaseMob.h"
#import "ZSRChatViewController.h"
#import "ZSRChatListCell.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "ZSRTimeTool.h"

@interface ZSRConversationViewController ()<EMChatManagerDelegate,UIAlertViewDelegate>
/** 好友的名称 */
@property (nonatomic, copy) NSString *buddyUsername;

/** 历史会话记录 */
@property (nonatomic, strong) NSArray *conversations;
@end


@implementation ZSRConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //获取历史会话记录
    [self loadConversations];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self loadConversations];
}

-(void)loadConversations{
    
    
    self.conversations = [self loadDataSource];
    [self.tableView reloadData];
    //显示总的未读数
    [self showTabBarBadge];
}

- (NSMutableArray *)loadDataSource
{
    NSMutableArray *ret = nil;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    if (conversations.count == 0) {
        conversations =  [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
    }
    
    NSMutableArray *realConversions = [NSMutableArray array];
    for (int i = 0; i<[conversations count];i++) {
        EMConversation  *conversation = conversations[i];
        if ( conversation.latestMessage) {
            [realConversions addObject:conversation];
        }
    }
    
    NSArray* sorte = [realConversions sortedArrayUsingComparator:
                      ^(EMConversation *obj1, EMConversation* obj2){
                          EMMessage *message1 = [obj1 latestMessage];
                          EMMessage *message2 = [obj2 latestMessage];
                          if(message1.timestamp > message2.timestamp) {
                              return(NSComparisonResult)NSOrderedAscending;
                          }else {
                              return(NSComparisonResult)NSOrderedDescending;
                          }
                      }];
    
    ret = [[NSMutableArray alloc] initWithArray:sorte];
    return ret;
}

#pragma mark - chatManager代理方法
//1.监听网络状态
- (void)didConnectionStateChanged:(EMConnectionState)connectionState{
    //    eEMConnectionConnected,   //连接成功
    //    eEMConnectionDisconnected,//未连接
    if (connectionState == eEMConnectionDisconnected) {
        NSLog(@"网络断开，未连接...");
        //        self.title = @"未连接.";
    }else{
        NSLog(@"网络通了...");
    }
    
}


-(void)willAutoReconnect{
    NSLog(@"将自动重连接...");
    //    self.title = @"连接中....";
}

-(void)didAutoReconnectFinishedWithError:(NSError *)error{
    if (!error) {
        NSLog(@"自动重连接成功...");
    }else{
        NSLog(@"自动重连接失败... %@",error);
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversations.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ZSRChatListCell *cell = [ZSRChatListCell chatListCellWithTableView:tableView];
    
    // 4.设置cell的属性...
    
    EMConversation *conversation = self.conversations[indexPath.row];
    
    cell.name = conversation.chatter;
    if (conversation.conversationType == eConversationTypeChat) {
        cell.placeholderImage = [UIImage imageNamed:@"Gatsby"];
    }
    else{
        NSString *imageName = @"Jobs";
        if (![conversation.ext objectForKey:@"groupSubject"] || ![conversation.ext objectForKey:@"isPublic"])
        {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    cell.placeholderImage = [UIImage imageNamed:@"Gatsby"];
                    cell.name = group.groupSubject;
                    imageName = group.isPublic ? @"groupPublicHeader" : @"groupPrivateHeader";
                    
                    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                    [ext setObject:group.groupSubject forKey:@"groupSubject"];
                    [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                    conversation.ext = ext;
                    break;
                }
            }
        }
        else
        {
            cell.name = [conversation.ext objectForKey:@"groupSubject"];
            imageName = [[conversation.ext objectForKey:@"isPublic"] boolValue] ? @"groupPublicHeader" : @"groupPrivateHeader";
        }
        cell.placeholderImage = [UIImage imageNamed:imageName];
    }
    cell.detailMsg = [self subTitleMessageByConversation:conversation];
    cell.time = [self lastMessageTimeByConversation:conversation];
    cell.unreadCount = [self unreadMessageCountByConversation:conversation];

    return cell;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ZSRChatListCell tableView:tableView heightForRowAtIndexPath:indexPath];
}

// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        ret = [ZSRTimeTool timeStr:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation
{
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    
    return  ret;
}

// 得到最后消息文字或者类型
-(NSString *)subTitleMessageByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                ret = @"[image]";
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                ret = didReceiveText;
            } break;
            case eMessageBodyType_Voice:{
                ret = @"[voice]";
            } break;
            case eMessageBodyType_Location: {
                ret = @"[location]";
            } break;
            case eMessageBodyType_Video: {
                ret = @"[video]";
            } break;
            default: {
            } break;
        }
    }
    
    return ret;
}


#pragma mark 自动登录的回调
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    if (error) {
        NSLog(@"自动登录失败 %@",error);
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {//拒绝好友请求
        [[EaseMob sharedInstance].chatManager rejectBuddyRequest:self.buddyUsername reason:@"我不认识你" error:nil];
    }else{//同意好友请求
        [[EaseMob sharedInstance].chatManager acceptBuddyRequest:self.buddyUsername error:nil];
        
    }
}



- (void)dealloc
{
    //移除聊天管理器的代理
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}


#pragma mark 历史会话列表更新
-(void)didUpdateConversationList:(NSArray *)conversationList{
    
    //给数据源重新赋值
    self.conversations = conversationList;
    
    //刷新表格
    [self.tableView reloadData];
    
    //显示总的未读数
    [self showTabBarBadge];
    
}

#pragma mark 未读消息数改变
- (void)didUnreadMessagesCountChanged{
    //更新表格
    [self.tableView reloadData];
    //显示总的未读数
    [self showTabBarBadge];
    
}

-(void)showTabBarBadge{
    //遍历所有的会话记录，将未读取的消息数进行累
    
    NSInteger totalUnreadCount = 0;
    for (EMConversation *conversation in self.conversations) {
        totalUnreadCount += [conversation unreadMessagesCount];
    }
    if (totalUnreadCount == 0) {
        
    }
    self.navigationController.tabBarItem.badgeValue = totalUnreadCount==0?nil:[NSString stringWithFormat:@"%ld",totalUnreadCount];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:totalUnreadCount];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //进入到聊天控制器
    //会话
    EMConversation *conversation = self.conversations[indexPath.row];
    EMBuddy *buddy = [EMBuddy buddyWithUsername:conversation.chatter];
    ZSRChatViewController *vc = [[ZSRChatViewController alloc] init];
    vc.buddy = buddy;
    if (conversation.conversationType == eConversationTypeGroupChat){
        vc.conversation = conversation;
    }
    [self.navigationController pushViewController:vc animated:YES];
}
@end
