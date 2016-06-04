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




@interface ZSRChatViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,EMChatManagerDelegate,ZSRInputViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) NSLayoutConstraint *inputViewBottomConstraint;//inputView底部约束
@property (nonatomic, strong) NSLayoutConstraint *inputViewHegihtConstraint;//inputView高度约束
@property (nonatomic, weak) ZSRInputView *inputView;
@property (nonatomic, weak) UITableView *tableView;

/**
 *  消息数组（里面放的都是ZSRMessageFrameModel模型，一个ZSRMessageFrameModel对象就代表一条消息）
 */
@property (nonatomic, strong) NSMutableArray *messagesFrames;

/** 当前会话对象 */
@property (nonatomic, strong) EMConversation *conversation;

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
    // 要获取本地聊天记录使用 会话对象
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    
    self.conversation = conversation;

    // 加载与当前聊天用户所有聊天记录
    NSArray *msgS = [conversation loadAllMessages];
    for (EMMessage *msg in msgS) {
        [self didAddMessage:msg];
    }
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
- (void)inputView:(ZSRInputView *)inputView didPickImage:(UIButton *)button
{
    //显示图片选择的控制器
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    
    // 设置源
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imgPicker.delegate = self;
    
    [self presentViewController:imgPicker animated:YES completion:NULL];

}

/**用户选中图片的回调*/
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    //1.获取用户选中的图片
    UIImage *selectedImg =  info[UIImagePickerControllerOriginalImage];
    
    //2.发送图片
    [self sendImg:selectedImg];
    
    //3.隐藏当前图片选择控制器
    [self dismissViewControllerAnimated:YES completion:NULL];
    
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
        
        [self sendText:text];
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
-(void)sendText:(NSString *)text{
    
    // 创建一个聊天文本对象
    EMChatText *chatText = [[EMChatText alloc] initWithText:text];
    
    //创建一个文本消息体
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    
    [self sendMessage:textBody];
    
    
}


#pragma mark 发送图片
-(void)sendImg:(UIImage *)selectedImg{
    
    //1.构造图片消息体
    /*
     * 第一个参数：原始大小的图片对象 1000 * 1000
     * 第二个参数: 缩略图的图片对象  120 * 120
     */
    EMChatImage *orginalChatImg = [[EMChatImage alloc] initWithUIImage:selectedImg displayName:@"【图片】"];
    
    EMImageMessageBody *imgBody = [[EMImageMessageBody alloc] initWithImage:orginalChatImg thumbnailImage:nil];
    
    [self sendMessage:imgBody];
    
}

#pragma mark 发送语音消息
-(void)sendVoice:(NSString *)recordPath duration:(NSInteger)duration{
    // 1.构造一个 语音消息体
    EMChatVoice *chatVoice = [[EMChatVoice alloc] initWithFile:recordPath displayName:@"[语音]"];
    //    chatVoice.duration = duration;
    
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:chatVoice];
    voiceBody.duration = duration;
    
    [self sendMessage:voiceBody];
    
}

-(void)sendMessage:(id<IEMMessageBody>)body{
    //1.构造消息对象
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[body]];
    message.messageType = eMessageTypeChat;
    
    //2.发送消息
    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"发送成功 %@",error);
    } onQueue:nil];
    
    
    [self didAddMessage:message];
   
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
    [self didAddMessage:message];
}

/**添加一条消息*/
- (void)didAddMessage:(EMMessage *)message{
    
    
    ZSRMessageModel *msgModel = [[ZSRMessageModel alloc]init];
    msgModel.message = message;
    
    //取出上一个模型
    ZSRMessageFrameModel *lastMsgFrame = [self.messagesFrames lastObject];
    //隐藏时间
    msgModel.hideTime = [msgModel.time isEqualToString:lastMsgFrame.msgModel.time];
    
    msgModel.isSender = ![message.from isEqualToString:self.buddy.username];//发送方

    //设置内容的frame
    ZSRMessageFrameModel *fm = [[ZSRMessageFrameModel alloc]init];
    //将msg 赋值给 fm 中的message
    fm.msgModel = msgModel;
    [self.messagesFrames addObject:fm];
    
    //2.刷新表格
    [self.tableView reloadData];
    
    //3.显示数据到底部
    [self scrollToBottom];
    
    //4.设置消息为已读取
    [self.conversation markMessageWithId:message.messageId asRead:YES];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.inputView.textView resignFirstResponder];

}
@end
