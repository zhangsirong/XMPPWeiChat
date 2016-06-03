//
//  ZSRAudioPlayTool.h
//  MYWeiChat
//
//  Created by hp on 6/3/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSRAudioPlayTool : NSObject
+(void)playWithMessage:(EMMessage *)msg msgButton:(UIButton *)msgButton isSend:(BOOL)isSend;

@end
