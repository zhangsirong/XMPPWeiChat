//
//  ZSRLoginViewController.m
//  
//
//  Created by hp on 16/1/22.
//
//
#define pading 20
#define cellW 120
#define cellH 50

#import "ZSRLoginViewController.h"
#import "ZSRTabBarViewController.h"
#import "EaseMob.h"

@interface ZSRLoginViewController ()

@property (nonatomic ,strong) UIButton *countryButton;
@property (nonatomic ,strong) UITextField *numberField;
@property (nonatomic ,strong) UITextField *passwordField;
@property (nonatomic ,strong) UIButton *loginButton;
@property (nonatomic ,strong) UIButton *messageLoginButton;
@property (nonatomic ,strong) UIButton *helpButton;

@property (nonatomic ,strong) UIButton *otherLoginButton;

@end

@implementation ZSRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupChildView];
}

- (void)setupChildView
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _countryButton=[[UIButton alloc] initWithFrame:CGRectMake(pading, 0, ScreenW - pading * 2, cellH)];
    [_countryButton setTitle:@"登录" forState:UIControlStateNormal];
    [_countryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:_countryButton];

    _numberField=[[UITextField alloc] initWithFrame:CGRectMake(pading, cellH, ScreenW - pading * 2, cellH)];
    _numberField.backgroundColor = [UIColor whiteColor];
    _numberField.placeholder = [NSString stringWithFormat:@"你的手机号码"];
    _numberField.text = @"zhangsan";
    [_numberField becomeFirstResponder];
    [self.view addSubview:_numberField];
    
    _passwordField=[[UITextField alloc] initWithFrame:CGRectMake(pading, cellH * 2, ScreenW - pading * 2, cellH)];
    _passwordField.backgroundColor = [ UIColor whiteColor];
    _passwordField.placeholder = [NSString stringWithFormat:@"填写密码"];
    _passwordField.text = @"123456";
    _passwordField.secureTextEntry = YES;
    [self.view addSubview:_passwordField];
    
    _loginButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_loginButton setFrame:CGRectMake(pading, cellH * 3, ScreenW - pading * 2, cellH)];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [_loginButton setBackgroundColor:ZSRColor(9, 187, 7)];
    
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
    
    _messageLoginButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_messageLoginButton setFrame:CGRectMake(pading, cellH * 4, ScreenW - pading * 2, cellH)];
    [_messageLoginButton setTitle:@"用短信验证码登录" forState:UIControlStateNormal];
    [self.view addSubview:_messageLoginButton];
    
    _otherLoginButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_otherLoginButton setFrame:CGRectMake(pading , ScreenH - pading - cellH  - 64, ScreenW / 2 - pading, cellH)];
    [_otherLoginButton setTitle:@"登录遇到问题" forState:UIControlStateNormal];
    [self.view addSubview:_otherLoginButton];
    
    _otherLoginButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_otherLoginButton setFrame:CGRectMake(pading + ScreenW / 2, ScreenH - pading - cellH  - 64, ScreenW / 2 - pading, cellH)];
    [_otherLoginButton setTitle:@"用其他方式登录" forState:UIControlStateNormal];
    [self.view addSubview:_otherLoginButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginAction
{
    NSString *username = self.numberField.text;
    NSString *password = self.passwordField.text;
    
    if (username.length == 0 || password.length == 0) {
        NSLog(@"请输入账号和密码");
        return;
    }
    // 登录
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username password:password completion:^(NSDictionary *loginInfo, EMError *error) {
        // 登录请求完成后的block回调
        if (!error) {
            NSLog(@"登录成功 %@",loginInfo);
            
            // 设置自动登录
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
            
            // 来主界面
            ZSRTabBarViewController   *vc = [[ZSRTabBarViewController alloc] init];
            //    [self.navigationController pushViewController:vc animated:YES ];
            [self presentViewController:vc animated:YES completion:nil];
            
        }else{
            NSLog(@"登录失败 %@",error);
            //User do not exist.
            /** 每一个应用都有自己的注册用户*/
        }
    } onQueue:dispatch_get_main_queue()];
}
@end
