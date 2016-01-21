//
//  ZSRNavigationViewController.m
//  
//
//  Created by hp on 16/1/21.
//
//

#import "ZSRNavigationViewController.h"

@interface ZSRNavigationViewController ()

@end

@implementation ZSRNavigationViewController

+ (void)initialize
{
    //设置整个项目所有item的主题样式
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    
    //设置普通状态
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor orangeColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    //设置不可用状态
    NSMutableDictionary *disableTextAttrs = [NSMutableDictionary dictionary];
    disableTextAttrs[NSForegroundColorAttributeName] = [UIColor lightGrayColor];
    
    disableTextAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    [item setTitleTextAttributes:disableTextAttrs forState:UIControlStateDisabled];
    
    //设置导航控制器标题字体大小 颜色
    UINavigationBar *navBar = [UINavigationBar appearance];
    NSMutableDictionary *titleTextAttrs = [NSMutableDictionary dictionary];
    titleTextAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    titleTextAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    [navBar setTitleTextAttributes:titleTextAttrs];
    [navBar setBackgroundColor:[UIColor blackColor]];
   
    // 高度不会拉伸，但是宽度会拉伸
    [navBar setBackgroundImage:[UIImage imageNamed:@"topbarbg_ios7"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
