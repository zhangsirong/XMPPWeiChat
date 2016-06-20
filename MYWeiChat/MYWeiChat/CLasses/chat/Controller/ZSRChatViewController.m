//
//  ZSRChatViewController.m
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "ZSRChatViewController.h"
#import "ZSRMessageToolBar.h"
#import "ZSRMessageCell.h"
#import "ZSRMessageModel.h"
#import "ZSRMessageModelManager.h"
#import "ZSRMessageFrameModel.h"
#import "EMCDDeviceManager.h"
#import "DXChatBarMoreView.h"
#import "ZSRMessageReadManager.h"
#import "ZSRAudioPlayTool.h"
#import "Constant.h"
#import "ZSRUserProfileViewController.h"
#import "ZSRChatGroupDetailViewController.h"


@import AVKit;
@interface ZSRChatViewController ()<UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate,ZSRMessageToolBarDelegate,EMCDDeviceManagerDelegate,DXChatBarMoreViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIMenuController *_menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    NSIndexPath *_longPressIndexPath;
    
    NSInteger _recordingCount;
    
    dispatch_queue_t _messageQueue;
    
    NSMutableArray *_messages;
    BOOL _isScrollToBottom;
}

@property (nonatomic) BOOL isGroup;
@property (nonatomic) BOOL isScrollToBottom;
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic) BOOL isKicked;
@property (nonatomic) BOOL isRobot;


@property (nonatomic) EMConversationType conversationType;

@property (nonatomic, strong) ZSRMessageToolBar *chatToolBar;
@property (nonatomic, strong) UITableView *tableView;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) ZSRMessageReadManager *messageReadManager;//message阅读的管理者



/**  消息数组（里面放的都是ZSRMessageFrameModel模型，一个ZSRMessageFrameModel对象就代表一条消息）*/
@property (nonatomic, strong) NSMutableArray *messagesFrames;

/** 当前会话对象 */

@end

@implementation ZSRChatViewController


- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup
{
    EMConversationType type = isGroup ? eConversationTypeGroupChat : eConversationTypeChat;
    self = [self initWithChatter:chatter conversationType:type];
    if (self) {
    }
    
    return self;
}

- (instancetype)initWithChatter:(NSString *)chatter conversationType:(EMConversationType)type
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isPlayingAudio = NO;
        _chatter = chatter;
        _conversationType = type;
        _messages = [NSMutableArray array];
        //根据接收者的username获取当前会话的管理者
        _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter
                                                                    conversationType:type];
        [_conversation markAllMessagesAsRead:YES];
    }
    
    return self;
}

- (BOOL)isGroup
{
    return _conversationType != eConversationTypeChat;
}


#pragma mark - helper
- (NSString *)convert2Mp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return [mp4Url relativePath];
}


#pragma mark - getter

- (ZSRMessageToolBar *)chatToolBar
{
    if (_chatToolBar == nil) {
        _chatToolBar = [[ZSRMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [ZSRMessageToolBar defaultHeight], bScreenWidth, [ZSRMessageToolBar defaultHeight])];
        ZSRLog(@"_chatToolBar%@",NSStringFromCGRect(_chatToolBar.frame));

        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _chatToolBar.delegate = self;
        ChatMoreType type = self.isGroup == YES ? ChatMoreTypeGroupChat : ChatMoreTypeChat;
        _chatToolBar.moreView = [[DXChatBarMoreView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), _chatToolBar.frame.size.width, 80) type:type];
        _chatToolBar.moreView.backgroundColor = ZSRColor(240, 242,247);
        _chatToolBar.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _chatToolBar;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, bScreenWidth, self.view.frame.size.height - self.chatToolBar.frame.size.height) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = ZSRColor(248, 248, 248);
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _tableView;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (ZSRMessageReadManager *)messageReadManager
{
    if (_messageReadManager == nil) {
        _messageReadManager = [ZSRMessageReadManager defaultManager];
    }
    
    return _messageReadManager;
}

-(NSMutableArray *)messagesFrames{
    if (!_messagesFrames) {
        _messagesFrames = [NSMutableArray array];
    }
    return _messagesFrames;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    _isPlayingAudio = NO;
    
    [self setupSubView];
    [self loadLocalChatRecords];
    [self setupBarButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kOrientationDidChange) name:UIDeviceOrientationDidChangeNotification  object:nil];
    // 设置聊天管理器的代理
    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    //将self注册为chatToolBar的moreView的代理
    if ([self.chatToolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
        [(DXChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
    }
}

- (void)kOrientationDidChange{
    [self.view layoutSubviews];
//    [self.view setNeedsDisplay];
//    [self.view reloadInputViews]
}
-(void)setupSubView{
    [self.view addSubview:self.chatToolBar];
    [self.view addSubview:self.tableView];
}

-(void)loadLocalChatRecords{
    // 要获取本地聊天记录使用 会话对象
     EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.conversation.chatter conversationType:self.conversationType];
    self.conversation = conversation;

    // 加载与当前聊天用户所有聊天记录
    NSArray *msgS = [conversation loadAllMessages];
    for (EMMessage *msg in msgS) {
        [self didAddMessage:msg];
        NSLog(@"%@",msg);
    }
}

- (void)setupBarButtonItem
{
    if (self.isGroup) {
        UIButton *detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        [detailButton setImage:[UIImage imageNamed:@"group_detail"] forState:UIControlStateNormal];
        [detailButton addTarget:self action:@selector(showRoomContact:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:detailButton];
    }
    else{
        UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [clearButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(removeAllMessages:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
    }
}

#pragma mark - ZSRMessageToolBarDelegate
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView{
    [_menuController setMenuItems:nil];
}

- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = self.view.frame.size.height - toHeight;
        self.tableView.frame = rect;
    }];
    [self scrollToBottom];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendText:text];
    }
}

/** 按下录音按钮开始录音*/
- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
    
    DXRecordView *tmpView = (DXRecordView *)recordView;
    tmpView.center = self.view.center;
    [self.view addSubview:tmpView];
    [self.view bringSubviewToFront:recordView];    // 文件名以时间命名
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

/**  松开手指完成录音*/
- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
    
    ZSRLog(@"手指从按钮松开结束录音");
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            ZSRLog(@"录音成功");
            ZSRLog(@"%@",recordPath);
            // 发送语音给服务器
            [self sendVoice:recordPath duration:aDuration];
            
        }else{
            [MBProgressHUD showSuccess:@"录音太短了"];
        }
    }];
}

/** 手指向上滑动取消录音 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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

#pragma mark 发送语音消息*
-(void)sendVoice:(NSString *)recordPath duration:(NSInteger)duration{
    // 1.构造一个 语音消息体
    EMChatVoice *chatVoice = [[EMChatVoice alloc] initWithFile:recordPath displayName:@"[语音]"];
    //    chatVoice.duration = duration;
    
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:chatVoice];
    voiceBody.duration = duration;
    
    [self sendMessage:voiceBody];
    
}

#pragma mark 发送视频消息
-(void)sendVideo:(NSString *)localPath{
    
    // 创建一个聊天视频对象
    EMChatVideo *videoChat = [[EMChatVideo alloc] initWithFile:localPath displayName:@"[视频]"];
    //创建一个文本消息体
    EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithChatObject:videoChat];
    
    [self sendMessage:body];
    
}

-(void)sendMessage:(id<IEMMessageBody>)body{
    
    NSString *chatter= _conversation.chatter;
    //1.构造消息对象
    EMMessage *message = [[EMMessage alloc] initWithReceiver:chatter bodies:@[body]];
    message.messageType = self.isGroup?eMessageTypeGroupChat:eMessageTypeChat;
    
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
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}




#pragma mark 接收好友回复消息
-(void)didReceiveMessage:(EMMessage *)message{
    if ([message.from isEqualToString:self.conversation.chatter]){
        [self didAddMessage:message];
    }
}

/**添加一条消息*/
- (void)didAddMessage:(EMMessage *)message{
    
    
    ZSRMessageModel *msgModel =  [ZSRMessageModelManager modelWithMessage:message];
    msgModel.message = message;
    
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
    
    //3.显示数据到底部
    [self scrollToBottom];
    
    //4.设置消息为已读取
    [self.conversation markMessageWithId:message.messageId asRead:YES];
    
}
#pragma mark - UIResponder actions

- (void)routerEventWithName:(ZSRRouterpEventType)eventType userInfo:(NSDictionary *)userInfo
{
    ZSRMessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    
    switch (eventType) {
        case kRouterEventChatHeadImageTapEventType:
            [self chatHeadCellBubblePressed:model];
            break;
            
        case kRouterEventImageBubbleTapEventType:
            [self chatImageCellBubblePressed:model];
            break;
        case kRouterEventAudioBubbleTapEventType:
            [self chatAudioCellBubblePressed:model];
            break;
        case kRouterEventChatCellVideoTapEventType:
            [self chatVideoeCellBubblePressed:model];
            break;
        default:
            ZSRLog(@"其他点击类型");
            break;
    }
}

- (void)chatHeadCellBubblePressed:(ZSRMessageModel *)model{
    
    ZSRUserProfileViewController *userprofile = [[ZSRUserProfileViewController alloc] initWithUsername:model.username];
    [self.navigationController pushViewController:userprofile animated:YES];}

-(void)chatImageCellBubblePressed:(ZSRMessageModel *)model
{
    __weak ZSRChatViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    if ([model.messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)model.messageBody;
        if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed) {
            if (imageBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
            {
                NSString *localPath = model.message == nil ? model.localPath : [[model.message.messageBodies firstObject] localPath];
                if (localPath && localPath.length > 0) {
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                    self.isScrollToBottom = NO;
                    if (image)
                    {
                        [self.messageReadManager showBrowserWithImages:@[image]];
                    }
                    else
                    {
                        NSLog(@"Read %@ failed!", localPath);
                    }
                    return ;
                }
            }
            [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                [MBProgressHUD hideHUD];
                if (!error) {
                    NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
                    if (localPath && localPath.length > 0) {
                        UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                        weakSelf.isScrollToBottom = NO;
                        if (image)
                        {
                            [weakSelf.messageReadManager showBrowserWithImages:@[image]];
                        }
                        else
                        {
                            NSLog(@"Read %@ failed!", localPath);
                        }
                        return ;
                    }
                }
                [MBProgressHUD showError:NSLocalizedString(@"message.imageFail", @"image for failure!")];
            } onQueue:nil];
        }else{
            //获取缩略图
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (error) {
                    [MBProgressHUD showError:NSLocalizedString(@"message.imageFail", @"image for failure!")];
                }
            } onQueue:nil];
        }
    }else if ([model.messageBody messageBodyType] == eMessageBodyType_Video) {
        //获取缩略图
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.messageBody;
        if (videoBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed) {
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (error) {
                    [MBProgressHUD showError:NSLocalizedString(@"message.imageFail", @"image for failure!")];
                }
            } onQueue:nil];
        }
    }
}

-(void)chatAudioCellBubblePressed:(ZSRMessageModel *)model
{
    
}

-(void)chatVideoeCellBubblePressed:(ZSRMessageModel *)model
{
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)model.messageBody;
    if (videoBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
    {
        NSString *localPath = model.message == nil ? model.localPath : [[model.message.messageBodies firstObject] localPath];
        if (localPath && localPath.length > 0)
        {
            [self playVideoWithVideoPath:localPath];
            return;
        }
    }
    
    __weak ZSRChatViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    [MBProgressHUD showMessage:@"正在下载。。。"];
    [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        [MBProgressHUD hideHUD];
        if (!error) {
            NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
            if (localPath && localPath.length > 0) {
                [weakSelf playVideoWithVideoPath:localPath];
            }
        }
    } onQueue:nil];
}

- (void)playVideoWithVideoPath:(NSString *)videoPath
{
    _isScrollToBottom = NO;
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    AVPlayerViewController *playerController = [[AVPlayerViewController alloc] init];
    playerController.player = [AVPlayer playerWithURL:videoURL];
    [self presentViewController:playerController animated:YES completion:NULL];

}



#pragma mark - EMChatBarMoreViewDelegate

-(void)moreViewPhotoAction:(DXChatBarMoreView *)moreView{
    // 弹出照片选择
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.delegate = self;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];}

- (void)moreViewVideoAction:(DXChatBarMoreView *)moreView
{
    // 弹出照片选择
    NSArray *availableTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    if ([availableTypes containsObject:(__bridge NSString *)kUTTypeMovie]) {
        [self.imagePicker setMediaTypes:@[(__bridge NSString *)kUTTypeMovie]];
    }
    self.imagePicker.delegate = self;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}


#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        
        // video url:   9
        // we will convert it to mp4 format
        NSString *mp4 = [self convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self sendVideo:mp4];
        
    }else{
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
         [self sendImg:orgImage];
    }
    //3.隐藏当前图片选择控制器
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GestureRecognizer
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.chatToolBar endEditing:YES];

}


// 点击背景隐藏
-(void)keyBoardHidden
{
    [self.chatToolBar endEditing:YES];
}

#pragma mark - EMCDDeviceManagerDelegate
- (void)proximitySensorChanged:(BOOL)isCloseToUser{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!_isPlayingAudio) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma - private
- (void)showRoomContact:(id)sender
{
    [self.view endEditing:YES];
    if (self.conversationType == eConversationTypeGroupChat) {
        ZSRChatGroupDetailViewController *detailController = [[ZSRChatGroupDetailViewController alloc] initWithGroupId:_chatter];
        detailController.title = self.title;
        [self.navigationController pushViewController:detailController animated:YES];
    }
}
@end
