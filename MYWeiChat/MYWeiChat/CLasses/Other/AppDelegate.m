//
//  AppDelegate.m
//  MYWeiChat
//
//  Created by hp on 16/1/21.
//  Copyright (c) 2016年 hp. All rights reserved.
//

#import "AppDelegate.h"
#import "ZSRTabBarViewController.h"
#import "ZSRStartViewController.h"
#import "ZSRNavigationViewController.h"
#import "ZSRApplyViewController.h"
#import "EaseMob.h"
@interface AppDelegate ()<EMChatManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    ZSRLog(@"%@",NSHomeDirectory());

    //registerSDKWithAppKey:注册的appKey，详细见下面注释。
    //apnsCertName:推送证书名(不需要加后缀)，详细见下面注释。
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"lpzsrong#chatapp" apnsCertName:nil otherConfig:@{kSDKConfigEnableConsoleLogger:@(NO)}];
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    
    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
    self.window =[[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    ZSRNavigationViewController *navVc = [[ZSRNavigationViewController alloc] initWithRootViewController:[[ZSRStartViewController alloc] init]];
    self.window.rootViewController = navVc;
    
    // 3.如果登录过，直接来到主界面
    if ([[EaseMob sharedInstance].chatManager isAutoLoginEnabled]) {
        //加载申请通知的数据
        // 来主界面
        ZSRTabBarViewController *vc = [[ZSRTabBarViewController alloc] init];
//        [[ZSRApplyViewController shareController] loadDataSourceFromLocalDB];
        //    [self.navigationController pushViewController:vc animated:YES ];
        self.window.rootViewController = vc;
    }
    [self.window makeKeyAndVisible];
    return YES;
}
#pragma mark 自动登录的回调
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    if (!error) {
        NSLog(@"自动登录成功 %@",loginInfo);
    }else{
        NSLog(@"自动登录失败 %@",error);
    }
    
}
// App进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

// App将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

// 申请处理时间
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}



@end
