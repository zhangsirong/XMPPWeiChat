//
//  ZSRMessageReadManager.h
//  MYWeiChat
//
//  Created by hp on 6/13/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhotoBrowser.h"
#import "ZSRMessageModel.h"
typedef void (^FinishBlock)(BOOL success);
typedef void (^PlayBlock)(BOOL playing, ZSRMessageModel *messageModel);

@class EMChatFireBubbleView;
@interface ZSRMessageReadManager : NSObject<MWPhotoBrowserDelegate>

@property (strong, nonatomic) MWPhotoBrowser *photoBrowser;
@property (strong, nonatomic) FinishBlock finishBlock;

@property (strong, nonatomic) ZSRMessageModel *audioMessageModel;

+ (id)defaultManager;

//default
- (void)showBrowserWithImages:(NSArray *)imageArray;

/**
 *  准备播放语音文件
 *
 *  @param messageModel     要播放的语音文件
 *  @param updateCompletion 需要更新model所在的Cell
 *
 *  @return 若返回NO，则不需要调用播放方法
 *
 */
- (BOOL)prepareMessageAudioModel:(ZSRMessageModel *)messageModel
            updateViewCompletion:(void (^)(ZSRMessageModel *prevAudioModel, ZSRMessageModel *currentAudioModel))updateCompletion;

- (ZSRMessageModel *)stopMessageAudioModel;

@end
