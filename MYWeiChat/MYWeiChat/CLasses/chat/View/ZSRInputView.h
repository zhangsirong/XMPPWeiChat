//
//  ZSRInputView.h
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSRInputView;

@protocol ZSRInputViewDelegate <NSObject>

@optional
- (void)inputView:(ZSRInputView *)inputView didClickVoiceButton:(UIButton *)button;
- (void)inputView:(ZSRInputView *)inputView didBeginRecord:(UIButton *)button;
- (void)inputView:(ZSRInputView *)inputView didEndRecord:(UIButton *)button;
- (void)inputView:(ZSRInputView *)inputView didCancelRecord:(UIButton *)button;


@end


@interface ZSRInputView : UIView

@property (nonatomic, weak) id<ZSRInputViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *faceBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
+(instancetype)inputView;
@end
