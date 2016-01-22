//
//  ZSRStartViewController.m
//  
//
//  Created by hp on 16/1/22.
//
//
#define pading 20
#define btnH 50
#define btnW 120

#import "ZSRStartViewController.h"
#import "ZSRLoginViewController.h"
@interface ZSRStartViewController ()
@property (nonatomic,strong) UIButton *loginButton;
@property (nonatomic,strong) UIButton *regisgerButton;

@end
@implementation ZSRStartViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupChildView];
}

- (void)setupChildView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleToFill;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LaunchImage.png" ofType:nil];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    [imageView setImage:image];
    [self.view addSubview:imageView];
    
    _loginButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_loginButton setFrame:CGRectMake(pading, ScreenH - pading - btnH, btnW, btnH)];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [_loginButton setBackgroundColor:ZSRColor(9, 187, 7)];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
    
    _regisgerButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_regisgerButton setFrame:CGRectMake(ScreenW - pading - btnW, ScreenH - pading - btnH, btnW, btnH)];
    [_regisgerButton setTitle:@"注册" forState:UIControlStateNormal];
    [_regisgerButton setBackgroundColor:ZSRColor(164, 164, 164)];
    [_regisgerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:_regisgerButton];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"使用手机号登录" style:UIBarButtonItemStylePlain target:nil action:nil];

}
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;

}

- (void)login
{
    ZSRLoginViewController *vc = [[ZSRLoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES ];
//    [self presentViewController:vc animated:YES completion:nil];

}
@end