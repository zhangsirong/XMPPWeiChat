//
//  ZSRAddFriendViewController.m
//  MYWeiChat
//
//  Created by hp on 5/15/16.
//  Copyright © 2016 hp. All rights reserved.
//

#define pading 20
#define cellW 120
#define cellH 50
#import "ZSRAddFriendViewController.h"
#import "EaseMob.h"
@interface ZSRAddFriendViewController()
@property (nonatomic ,strong) UITextField *usernameField;
@property (nonatomic ,strong) UIButton *countryButton;

@property (nonatomic ,strong) UIButton *addFriendButton;

@end

@implementation ZSRAddFriendViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupChildView];
}

- (void)setupChildView
{
    [self.view setBackgroundColor:ZSRColor(217, 217, 217)];
    _countryButton=[[UIButton alloc] initWithFrame:CGRectMake(pading, 0, ScreenW - pading * 2, cellH)];
    [_countryButton setTitle:@"添加好友" forState:UIControlStateNormal];
    [_countryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:_countryButton];
    
    _usernameField=[[UITextField alloc] initWithFrame:CGRectMake(pading, cellH, ScreenW - pading * 2, cellH)];
    _usernameField.backgroundColor = [UIColor whiteColor];
    _usernameField.placeholder = [NSString stringWithFormat:@"请填写好友昵称"];
    _usernameField.text = @"zhangsan";
    _usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _usernameField.textAlignment = NSTextAlignmentCenter;
    [_usernameField becomeFirstResponder];
    [self.view addSubview:_usernameField];
    

    
    _addFriendButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_addFriendButton setFrame:CGRectMake(pading, cellH * 3, ScreenW - pading * 2, cellH)];
    [_addFriendButton setTitle:@"添加" forState:UIControlStateNormal];
    [_addFriendButton setBackgroundColor:ZSRColor(9, 187, 7)];
    
    [_addFriendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_addFriendButton addTarget:self action:@selector(addFriendAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addFriendButton];
}



- (void)addFriendAction{
    
    // 添加好友
    
    // 1.获取要添加好友的名字
    NSString *username = self.usernameField.text;
    
    
    // 2.向服务器发送一个添加好友的请求
    // buddy 哥儿们
    // message ： 请求添加好友的 额外信息
    NSString *loginUsername = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    NSString *message = [@"我是" stringByAppendingString:loginUsername];
    
    EMError *error =  nil;
//    [[EaseMob sharedInstance].chatManager addBuddy:@"6001" message:@"我想加您为好友" error:&error];
    BOOL isSuccess = [[EaseMob sharedInstance].chatManager addBuddy:username message:message error:&error];
    if (error && isSuccess) {
        NSLog(@"添加好友有问题 %@",error);
        
    }else{
        NSLog(@"添加好友没有问题");
    }
    
}

@end
