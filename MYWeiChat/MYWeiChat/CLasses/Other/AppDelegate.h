//
//  AppDelegate.h
//  MYWeiChat
//
//  Created by hp on 16/1/21.
//  Copyright (c) 2016年 hp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSRTabBarViewController.h"
#import "ZSRApplyViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, IChatManagerDelegate>
{
    EMConnectionState _connectionState;
}


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ZSRTabBarViewController *mainController;

@end

