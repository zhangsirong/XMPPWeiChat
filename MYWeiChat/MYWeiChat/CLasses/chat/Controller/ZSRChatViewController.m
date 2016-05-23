//
//  ZSRChatViewController.m
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRChatViewController.h"
#import "ZSRInputView.h"
#import "ZSRMessageCell.h"
#import "ZSRMessageModel.h"
#import "ZSRMessageFrameModel.h"
#import "EMCDDeviceManager.h"



@interface ZSRChatViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,EMChatManagerDelegate,ZSRInputViewDelegate>

@property (nonatomic, strong) NSLayoutConstraint *inputViewBottomConstraint;//inputView底部约束
@property (nonatomic, strong) NSLayoutConstraint *inputViewHegihtConstraint;//inputView高度约束
@property (nonatomic, weak) ZSRInputView *inputView;
@property (nonatomic, weak) UITableView *tableView;

/**
 *  消息数组（里面放的都是ZSRMessageFrameModel模型，一个ZSRMessageFrameModel对象就代表一条消息）
 */
@property (nonatomic, strong) NSMutableArray *messagesFrames;


@end

@implementation ZSRChatViewController

-(NSMutableArray *)messagesFrames{
    if (!_messagesFrames) {
        _messagesFrames = [NSMutableArray array];
    }
    return _messagesFrames;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupView];
    [self loadLocalChatRecords];
    self.title = self.buddy.username;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置聊天管理器的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    
    //1.监听键盘弹出，把inputToolbar(输入工具条)往上移
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //2.监听键盘退出，inputToolbar恢复原位
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];

    //3.监听键盘完全弹出，inputToolbar恢复原位
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [self scrollToBottom];
}

-(void)loadLocalChatRecords{
    
    NSMutableArray *messages = [NSMutableArray array];

    // 要获取本地聊天记录使用 会话对象
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    
    // 加载与当前聊天用户所有聊天记录
    NSArray *msgS = [conversation loadAllMessages];
    
    for (EMMessage *msg in msgS) {
        ZSRLog(@"%@",msg);
        //1.时间
        ZSRMessageModel *msgModel = [[ZSRMessageModel alloc] init];
        
        //2.谁发的
        msgModel.isSender = ![msg.from isEqualToString:self.buddy.username];//发送方
        //3.文本
        msgModel.message = msg;
        
        
        
        //取出上一个模型
        ZSRMessageModel *lastMsg = [messages lastObject];
        //
        //            //隐藏时间
        msgModel.hideTime = [msgModel.time isEqualToString:lastMsg.time];
        //

        [messages addObject:msgModel];
        
    }
    // 添加到数据源
    self.messagesFrames = [self messageFramesWithMessage:messages];
}

-(void)setupView{
    // 代码方式实现自动布局 VFL
    // 创建一个Tableview;
    UITableView *tableView = [[UITableView alloc] init];
    //cell 不可选中
    tableView.allowsSelection = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    tableView.delegate = self;
    tableView.dataSource = self;
#warning 代码实现自动布局，要设置下面的属性为NO
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 创建输入框View
    ZSRInputView *inputView = [ZSRInputView inputView];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    inputView.delegate = self;
    // 设置TextView代理
    inputView.textView.delegate = self;
    [self.view addSubview:inputView];
    
    self.inputView = inputView;

    
    // 自动布局
    
    // 水平方向的约束
    NSDictionary *views = @{@"tableview":tableView,
                            @"inputView":inputView};
    
    // 1.tabview水平方向的约束
    NSArray *tabviewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableview]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:tabviewHConstraints];
    
    // 2.inputView水平方向的约束
    NSArray *inputViewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inputView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:inputViewHConstraints];
    
    
    // 垂直方向的约束
    NSArray *vContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableview]-0-[inputView(46)]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:vContraints];
    self.inputViewBottomConstraint = [vContraints lastObject];
    self.inputViewHegihtConstraint = vContraints[vContraints.count-2] ;
    ZSRLog(@"%@",vContraints);
}

#pragma mark -ZSRInputView代理
- (void)inputView:(ZSRInputView *)inputView didClickVoiceButton:(UIButton *)button
{
    inputView.recordBtn.hidden = !inputView.recordBtn.hidden;
    
    if (!inputView.recordBtn.hidden){
        [self.inputView.textView resignFirstResponder];
    }else{
        [self.inputView.textView becomeFirstResponder];
    }

}

- (void)inputView:(ZSRInputView *)inputView didBeginRecord:(UIButton *)button{
    // 文件名以时间命名
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    ZSRLog(@"按钮点下去开始录音");
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        if (!error) {
            ZSRLog(@"开始录音成功");
        }
    }];

}

-(void)inputView:(ZSRInputView *)inputView didEndRecord:(UIButton *)button
{
    ZSRLog(@"手指从按钮松开结束录音");
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            ZSRLog(@"录音成功");
            ZSRLog(@"%@",recordPath);
            // 发送语音给服务器
            [self sendVoice:recordPath duration:aDuration];
            
        }else{
            ZSRLog(@"== %@",error);
            
        }
    }];
}

-(void)inputView:(ZSRInputView *)inputView didCancelRecord:(UIButton *)button
{
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
    [MBProgressHUD showSuccess:@"录音已取消"];
}



#pragma mark -表格的数据源
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messagesFrames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZSRMessageCell *cell = [ZSRMessageCell messageCellWithTableView:tableView];
    //取出model
    ZSRMessageFrameModel *model = self.messagesFrames[indexPath.row];
    //设置model
    cell.frameMessage = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZSRMessageFrameModel *model = self.messagesFrames[indexPath.row];
    return model.cellH;//cell 的高度
}

#pragma mark 键盘显示时会触发的方法
-(void)kbWillShow:(NSNotification *)noti{

    
    //1.获取键盘高度
    //1.1获取键盘结束时候的位置
    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbHeight = kbEndFrm.size.height;
    
    
    //2.更改inputToolbar 底部约束
    self.inputViewBottomConstraint.constant = kbHeight;
    //添加动画
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    
}
#pragma mark 键盘退出时会触发的方法
-(void)kbWillHide:(NSNotification *)noti{
    //inputToolbar恢复原位
    self.inputViewBottomConstraint.constant = 0;
    
}



#pragma mark 键盘完全显示时会触发的方法
-(void)kbDidShow:(NSNotification *)noti{
    [self scrollToBottom];
}



-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextView代理
-(void)textViewDidChange:(UITextView *)textView{
    
    ZSRLog(@"contentOffset %@",NSStringFromCGPoint(textView.contentOffset));
    // 1.计算TextView的高度，
    CGFloat textViewH = 0;
    CGFloat minHeight = 33;//textView最小的高度
    CGFloat maxHeight = 68;//textView最大的高度
    
    // 获取contentSize的高度
    CGFloat contentHeight = textView.contentSize.height;
    if (contentHeight < minHeight) {
        textViewH = minHeight;
    }else if (contentHeight > maxHeight){
        textViewH = maxHeight;
    }else{
        textViewH = contentHeight;
    }
    
    
    
    NSString *text = textView.text;
    // 换行就等于点击了的send
    if ([text rangeOfString:@"\n"].location!= 0 && [text rangeOfString:@"\n"].location != NSNotFound) {
        ZSRLog(@"发送数据 %@",text);
        // 去除换行字符
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self sendMessage:text];
        //清空数据
        textView.text = nil;
        // 发送时，textViewH的高度为33
        textViewH = minHeight;
        
    }else{
        ZSRLog(@"%@",textView.text);
        
    }
    
    // 3.调整整个InputToolBar 高度
    self.inputViewHegihtConstraint.constant = 6 + 7 + textViewH;
    // 加个动画
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    
    // 4.记光标回到原位
#warning 技巧
    [textView setContentOffset:CGPointZero animated:YES];
    [textView scrollRangeToVisible:textView.selectedRange];
    
}


#pragma mark 发送文本消息
-(void)sendMessage:(NSString *)text{
    
        //消息 ＝ 消息头 + 消息体
#warning 每一种消息类型对象不同的消息体
    //    EMTextMessageBody 文本消息体
    //    EMVoiceMessageBody 录音消息体
    //    EMVideoMessageBody 视频消息体
    //    EMLocationMessageBody 位置消息体
    //    EMImageMessageBody 图片消息体
    
    ZSRLog(@"要发送给 %@",self.buddy.username);
    
    //    return;
    // 创建一个聊天文本对象
    EMChatText *chatText = [[EMChatText alloc] initWithText:text];
    
    //创建一个文本消息体
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    
    //1.创建一个消息对象
    EMMessage *msgObj = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[textBody]];
    
    // 2.发送消息
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msgObj progress:nil prepare:^(EMMessage *message, EMError *error) {
        ZSRLog(@"准备发送消息");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        ZSRLog(@"完成消息发送 %@",error);
    } onQueue:nil];
    
    
    
    //1. 添加模型数据
    ZSRMessageModel *msgModel = [[ZSRMessageModel alloc]init];
    msgModel.message= msgObj;
    msgModel.isSender = YES;
    

    
    //取出上一个模型
    ZSRMessageFrameModel *lastMsgFrame = [self.messagesFrames lastObject];
    //隐藏时间
    msgModel.hideTime = [msgModel.time isEqualToString:lastMsgFrame.msgModel.time];
    
    //设置内容的frame
    ZSRMessageFrameModel *fm = [[ZSRMessageFrameModel alloc]init];
    //将msg 赋值给 fm 中的message
    fm.msgModel = msgModel;
    
    [self.messagesFrames addObject:fm];
    
    //2.刷新表格
    [self.tableView reloadData];
    // 4.把消息显示在顶部
    [self scrollToBottom];
    
}

#pragma mark 发送语音消息
-(void)sendVoice:(NSString *)recordPath duration:(NSInteger)duration{
    // 1.构造一个 语音消息体
    EMChatVoice *chatVoice = [[EMChatVoice alloc] initWithFile:recordPath displayName:@"[语音]"];
    //    chatVoice.duration = duration;
    
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:chatVoice];
    voiceBody.duration = duration;
    
    // 2.构造一个消息对象
    EMMessage *msgObj = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[voiceBody]];
    //聊天的类型 单聊
    msgObj.messageType = eMessageTypeChat;
    
    // 3.发送
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msgObj progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送语音");
        
        
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            NSLog(@"语音发送成功");
            //1. 添加模型数据
            ZSRMessageModel *msgModel = [[ZSRMessageModel alloc]init];
            msgModel.message= msgObj;
            msgModel.isSender = YES;
            
            //设置内容的frame
            ZSRMessageFrameModel *fm = [[ZSRMessageFrameModel alloc]init];
            //将msg 赋值给 fm 中的message
            fm.msgModel = msgModel;
            fm.msgModel.message= msgObj;
            [self.messagesFrames addObject:fm];
            
            //2.刷新表格
            [self.tableView reloadData];
            // 4.把消息显示在顶部
            [self scrollToBottom];
        }else{
            NSLog(@"语音发送失败");
        }
    } onQueue:nil];
    
}


/**
 *  将message模型转为MessageFrame模型
 */
- (NSMutableArray *)messageFramesWithMessage:(NSArray *)messages
{
    NSMutableArray *frames = [NSMutableArray array];
    for (ZSRMessageModel *msgModel in messages) {
        ZSRMessageFrameModel *f = [[ZSRMessageFrameModel alloc] init];
        f.msgModel = msgModel;
        [frames addObject:f];
    }
    return frames;
}

-(void)scrollToBottom{
    //1.获取最后一行
    if (self.messagesFrames.count == 0) {
        return;
    }
    
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.messagesFrames.count - 1 inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark 接收好友回复消息
-(void)didReceiveMessage:(EMMessage *)message{
    id<IEMMessageBody> msgBody = message.messageBodies.firstObject;
    ZSRMessageModel *msgModel = [[ZSRMessageModel alloc]init];

    switch (msgBody.messageBodyType) {
        case eMessageBodyType_Text:
        {
            // 收到的文字消息
#warning from 一定等于当前聊天用户才可以刷新数据
            if ([message.from isEqualToString:self.buddy.username]) {
                //1. 添加模型数据
                msgModel.message = message;
                msgModel.text = ((EMTextMessageBody *)msgBody).text;
                msgModel.isSender = NO;
               

            }
        }
            break;
        case eMessageBodyType_Image:
        {
            
        }
            break;
        case eMessageBodyType_Location:
        {
            
        }
            break;
        case eMessageBodyType_Voice:
        {
            
            EMVoiceMessageBody *body = (EMVoiceMessageBody *)msgBody;
            msgModel.message = message;

        }
            break;
        case eMessageBodyType_Video:
        {
           
        }
            break;
        case eMessageBodyType_File:
        {
                   }
            break;
            
        default:
            break;
    }
    
    
    //设置内容的frame
    ZSRMessageFrameModel *fm = [[ZSRMessageFrameModel alloc]init];
    //将msg 赋值给 fm 中的message
    fm.msgModel = msgModel;
    [self.messagesFrames addObject:fm];
    
    //2.刷新表格
    [self.tableView reloadData];
    
    //3.显示数据到底部
    [self scrollToBottom];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.inputView.textView resignFirstResponder];

}
@end
