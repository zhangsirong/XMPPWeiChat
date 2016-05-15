//
//  ZSRRegisgerViewController.m
//  MYWeiChat
//
//  Created by hp on 5/7/16.
//  Copyright © 2016 hp. All rights reserved.
//


#define pading 20
#define cellW 120
#define cellH 50
#import "ZSRRegisgerViewController.h"
#import "EaseMob.h"
#import "ZSRTabBarViewController.h"
#import "ZSRLoginViewController.h"
#import "MBProgressHUD+ZSR.h"
@interface ZSRRegisgerViewController ()

@property (nonatomic ,strong) UIButton *countryButton;
@property (nonatomic ,strong) UITextField *numberField;
@property (nonatomic ,strong) UITextField *passwordField;
@property (nonatomic ,strong) UIButton *regisgerButton;

@end

@implementation ZSRRegisgerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupChildView];
}

- (void)setupChildView
{
    [self.view setBackgroundColor:[UIColor whiteColor]];

    _countryButton=[[UIButton alloc] initWithFrame:CGRectMake(pading, 0, ScreenW - pading * 2, cellH)];
    [_countryButton setTitle:@"注册" forState:UIControlStateNormal];
    [_countryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:_countryButton];
    
    _numberField=[[UITextField alloc] initWithFrame:CGRectMake(pading, cellH, ScreenW - pading * 2, cellH)];
    _numberField.backgroundColor=[UIColor whiteColor];
    _numberField.placeholder=[NSString stringWithFormat:@"你的手机号码"];
    [self.view addSubview:_numberField];
    
    _passwordField=[[UITextField alloc] initWithFrame:CGRectMake(pading, cellH * 2, ScreenW - pading * 2, cellH)];
    _passwordField.backgroundColor=[UIColor whiteColor];
    _passwordField.placeholder=[NSString stringWithFormat:@"填写密码"];
    [self.view addSubview:_passwordField];
    
    _regisgerButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_regisgerButton setFrame:CGRectMake(pading, cellH * 3, ScreenW - pading * 2, cellH)];
    [_regisgerButton setTitle:@"注册" forState:UIControlStateNormal];
    [_regisgerButton setBackgroundColor:ZSRColor(9, 187, 7)];
    
    [_regisgerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_regisgerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_regisgerButton];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerAction
{
    NSString *username = self.numberField.text;
    NSString *password = self.passwordField.text;
    
    if (username.length == 0 || password.length == 0) {
        NSLog(@"请输入账号和密码");
        return;
    }
    // 注册
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:username password:password withCompletion:^(NSString *username, NSString *password, EMError *error) {
        NSLog(@"%@",[NSThread currentThread]);
        if (!error) {
            [MBProgressHUD showError:@"注册成功,请登录"];
        }else{
            [MBProgressHUD showError:@"注册失败,用户名已存在"];
         NSLog(@"注册失败 %@",error);
        }
        
    } onQueue:nil];
    
}
@end
