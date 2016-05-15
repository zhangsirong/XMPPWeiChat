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
#import "EMSDK.h"
#import "EMClient.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //AppKey:注册的AppKey，详细见下面注释。
    //apnsCertName:推送证书名（不需要加后缀），详细见下面注释。
    EMOptions *options = [EMOptions optionsWithAppkey:@"lpzsrong#chatapp"];
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    self.window =[[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    ZSRNavigationViewController *navVc = [[ZSRNavigationViewController alloc] initWithRootViewController:[[ZSRStartViewController alloc] init]];

    self.window.rootViewController = navVc;
    [self.window makeKeyAndVisible];
    return YES;
}

// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}


@end
