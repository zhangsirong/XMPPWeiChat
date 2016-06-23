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
#import "ZSRApplyViewController.h"
#import "ZSRLoginViewController.h"
#import "AppDelegate+EaseMob.h"

#import "EaseMob.h"
@interface AppDelegate ()<EMChatManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    _connectionState = eEMConnectionConnected;
    
    // 初始化环信SDK，详细内容在AppDelegate+EaseMob.m 文件中
    [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self loginStateChange:nil];

    [self.window makeKeyAndVisible];
    return YES;
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

#pragma mark - private
//登陆状态改变
-(void)loginStateChange:(NSNotification *)notification
{
    BOOL isAutoLogin = [[[EaseMob sharedInstance] chatManager] isAutoLoginEnabled];
    BOOL loginSuccess = [notification.object boolValue];
    
    if (isAutoLogin || loginSuccess) {//登陆成功加载主窗口控制器
        //加载申请通知的数据
        [[ZSRApplyViewController shareController] loadDataSourceFromLocalDB];
        if (_mainController == nil) {
            // 来主界面
            ZSRTabBarViewController *mainController = [[ZSRTabBarViewController alloc] init];
            _mainController = mainController;
        }
        self.window.rootViewController = _mainController;
    }else{//登陆失败加载登陆页面控制器
        _mainController = nil;
        ZSRNavigationViewController *loginController = [[ZSRNavigationViewController alloc] initWithRootViewController:[[ZSRStartViewController alloc] init]];
        
        self.window.rootViewController = loginController;
    }
}
@end
    

