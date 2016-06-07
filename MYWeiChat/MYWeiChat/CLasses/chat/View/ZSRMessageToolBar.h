//
//  ZSRmessageToolBar.h
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHMessageTextView.h"

#import "DXChatBarMoreView.h"
#import "DXFaceView.h"
#import "DXRecordView.h"

#define kInputTextViewMinHeight 36
#define kInputTextViewMaxHeight 200
#define kHorizontalPadding 8
#define kVerticalPadding 5

@class ZSRMessageToolBar;

@protocol ZSRMessageToolBarDelegate <NSObject>

@optional

/** 在普通状态和语音状态之间进行切换时，会触发这个回调函数 */
- (void)didStyleChangeToRecord:(BOOL)changedToRecord;



/** 文字输入框开始编辑*/
- (void)inputTextViewDidBeginEditing:(XHMessageTextView *)messageInputTextView;

/** 文字输入框将要开始编辑 */
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView;

/** 发送文字消息，可能包含系统自带表情 */
- (void)didSendText:(NSString *)text;

/** 发送第三方表情，不会添加到文字输入框中 */
- (void)didSendFace:(NSString *)faceLocalPath;

/** 按下录音按钮开始录音*/
- (void)didStartRecordingVoiceAction:(UIView *)recordView;

/**  手指向上滑动取消录音 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView;

/** 松开手指完成录音*/
- (void)didFinishRecoingVoiceAction:(UIView *)recordView;

/**  当手指离开按钮的范围内时，主要为了通知外部的HUD */
- (void)didDragOutsideAction:(UIView *)recordView;

/** 当手指再次进入按钮的范围内时，主要也是为了通知外部的HUD */
- (void)didDragInsideAction:(UIView *)recordView;

@required
/** 高度变到toHeight */
- (void)didChangeFrameToHeight:(CGFloat)toHeight;
@end
@interface ZSRMessageToolBar : UIView

@property (nonatomic, weak) id<ZSRMessageToolBarDelegate> delegate;



@property (strong, nonatomic) UIButton *recordButton;

/** 操作栏背景图片*/
@property (strong, nonatomic) UIImage *toolbarBackgroundImage;

/** 背景图片 */
@property (strong, nonatomic) UIImage *backgroundImage;

/** 更多的附加页面*/
@property (strong, nonatomic) UIView *moreView;

/** 表情的附加页面*/
@property (strong, nonatomic) UIView *faceView;

/** 录音的附加页面*/
@property (strong, nonatomic) UIView *recordView;

/** 用于输入文本消息的输入框*/
@property (strong, nonatomic) XHMessageTextView *inputTextView;

/** 文字输入区域最大高度，必须 > KInputTextViewMinHeight(最小高度)并且 < KInputTextViewMaxHeight，否则设置无效 */
@property (nonatomic) CGFloat maxTextInputViewHeight;


- (instancetype)initWithFrame:(CGRect)frame;

/** 默认高度 */
+ (CGFloat)defaultHeight;

/** 取消触摸录音键 */
- (void)cancelTouchRecord;

@end
