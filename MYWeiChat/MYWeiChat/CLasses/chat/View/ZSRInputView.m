//
//  ZSRInputView.m
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRInputView.h"

@implementation ZSRInputView

+(instancetype)inputView{
    return [[[NSBundle mainBundle] loadNibNamed:@"ZSRInputView" owner:nil options:nil] lastObject];
}

#pragma mark - Action
- (IBAction)voiceAction:(id)sender {
//    ZSRLog(@"voiceAction");
    
    if ([self.delegate respondsToSelector:@selector(inputView:didClickVoiceButton:)]) {
        [self.delegate inputView:self didClickVoiceButton:self.voiceBtn];
    }
}


#pragma mark 按钮点下去开始录音
- (IBAction)beginRecordAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(inputView:didBeginRecord:)]) {
        [self.delegate inputView:self didBeginRecord:self.recordBtn];
    }
}


#pragma mark 手指从按钮范围内松开结束录音

- (IBAction)endRecordAction:(id)sender {
//    ZSRLog(@"endRecordAction");
    if ([self.delegate respondsToSelector:@selector(inputView:didEndRecord:)]) {
        [self.delegate inputView:self didEndRecord:self.recordBtn];
    }

}

- (IBAction)cancelRecordAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(inputView:didCancelRecord:)]) {
        [self.delegate inputView:self didCancelRecord:self.recordBtn];
    }
}

@end
