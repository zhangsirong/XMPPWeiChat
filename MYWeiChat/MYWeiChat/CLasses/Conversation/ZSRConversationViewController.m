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
#import "ZSRUserProfileManager.h"

@interface ZSRConversationViewController ()<EMChatManagerDelegate,UIAlertViewDelegate>
/** 好友的名称 */
@property (nonatomic, copy) NSString *buddyUsername;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (nonatomic, strong) UIView   *networkStateView;


@end

@implementation ZSRConversationViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
    }
    return self;
}
- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //设置代理
    [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self registerNotifications];
    [self removeEmptyConversationsFromDB];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self loadConversations];
}

- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.conversationType == eConversationTypeChatRoom)) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}

-(void)loadConversations{
    self.dataSource = [self loadDataSource];
    [self.tableView reloadData];
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



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ZSRChatListCell *cell = [ZSRChatListCell chatListCellWithTableView:tableView];
    
    // 4.设置cell的属性...
    
    EMConversation *conversation = self.dataSource[indexPath.row];
    
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


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {//拒绝好友请求
        [[EaseMob sharedInstance].chatManager rejectBuddyRequest:self.buddyUsername reason:@"我不认识你" error:nil];
    }else{//同意好友请求
        [[EaseMob sharedInstance].chatManager acceptBuddyRequest:self.buddyUsername error:nil];
        
    }
}

#pragma mark 历史会话列表更新
-(void)didUpdateConversationList:(NSArray *)conversationList{
    
    [self refreshDataSource];
}

#pragma mark 未读消息数改变
-(void)didUnreadMessagesCountChanged
{
    [self refreshDataSource];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self refreshDataSource];
}

-(void)showTabBarBadge{
    //遍历所有的会话记录，将未读取的消息数进行累
    
    NSInteger totalUnreadCount = 0;
    for (EMConversation *conversation in self.dataSource) {
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
    EMConversation *conversation = self.dataSource[indexPath.row];
    ZSRChatViewController *chatController;
    
    NSString *title = conversation.chatter;
    if (conversation.conversationType != eConversationTypeChat) {
        if ([[conversation.ext objectForKey:@"groupSubject"] length])
        {
            title = [conversation.ext objectForKey:@"groupSubject"];
        }
        else
        {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    title = group.groupSubject;
                    break;
                }
            }
        }
    } else if (conversation.conversationType == eConversationTypeChat) {
        title = [[ZSRUserProfileManager sharedInstance] getNickNameWithUsername:conversation.chatter];
    }
    
    chatController = [[ZSRChatViewController alloc] initWithChatter:conversation.chatter conversationType:conversation.conversationType];
    chatController.title = title;

    [self.navigationController pushViewController:chatController animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversation *converation = [self.dataSource objectAtIndex:indexPath.row];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:YES append2Chat:YES];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}



#pragma mark - public

-(void)refreshDataSource
{
    self.dataSource = [self loadDataSource];
    [self.tableView reloadData];
}

- (void)isConnect:(BOOL)isConnect{
    if (!isConnect) {
        self.tableView.tableHeaderView = self.networkStateView;
    }
    else{
        self.tableView.tableHeaderView = nil;
    }
    
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
        self.tableView.tableHeaderView = self.networkStateView;
    }
    else{
        self.tableView.tableHeaderView = nil;
    }
}

- (void)willReceiveOfflineMessages{
    NSLog(NSLocalizedString(@"message.beginReceiveOffine", @"Begin to receive offline messages"));
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    [self refreshDataSource];
}

- (void)didFinishedReceiveOfflineMessages{
    NSLog(NSLocalizedString(@"message.endReceiveOffine", @"End to receive offline messages"));
}

#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc{
    [self unregisterNotifications];
}

@end
