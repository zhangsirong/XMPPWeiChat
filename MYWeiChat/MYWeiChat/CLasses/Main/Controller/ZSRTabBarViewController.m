//
//  ZSRTabBarViewController.m
//  
//
//  Created by hp on 16/1/21.
//
//

#import "ZSRTabBarViewController.h"
#import "ZSRNavigationViewController.h"

#import "ZSRMessageViewController.h"
#import "ZSRContactsViewController.h"
#import "ZSRDiscoverViewController.h"
#import "ZSRMeViewController.h"

@interface ZSRTabBarViewController ()

@end

@implementation ZSRTabBarViewController

+ (void)initialize
{
    
    //设置TabBar样式字体颜色
    UITabBar *bar = [UITabBar appearance];
    
    //设置选中状态颜色
    [bar setTintColor:ZSRColor(9, 187, 7)];
    
    //
//    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];??
//    textAttrs[NSForegroundColorAttributeName] = [UIColor orangeColor];
//    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:25];
//    
//    UITabBarItem *item = [UITabBarItem appearance];
//    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
 
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    ZSRMessageViewController *messageVc = [[ZSRMessageViewController alloc] init];
    [self addChildVc:messageVc title:@"微信" image:@"tabbar_mainframe.png" selectedImage:@"tabbar_mainframeHL.png"];
    
    ZSRContactsViewController *contactsVc = [[ZSRContactsViewController alloc] init];
    [self addChildVc:contactsVc title:@"通讯录" image:@"tabbar_contacts.png" selectedImage:@"tabbar_contactsHL.png"];
    
    ZSRDiscoverViewController *discoverVc = [[ZSRDiscoverViewController alloc] init];
    [self addChildVc:discoverVc title:@"发现" image:@"tabbar_discover.png" selectedImage:@"tabbar_discoverHL.png"];
    
    ZSRMeViewController *meVc = [[ZSRMeViewController alloc] init];
    [self addChildVc:meVc title:@"我" image:@"tabbar_me.png" selectedImage:@"tabbar_meHL.png"];
    

}

- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    childVc.tabBarItem.title = title;
    childVc.tabBarItem.image = [UIImage imageNamed:image];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    childVc.view.backgroundColor = ZSRRandomColor;
    // 先给外面传进来的小控制器 包装 一个导航控制
    ZSRNavigationViewController *nav = [[ZSRNavigationViewController alloc] initWithRootViewController:childVc];
    // 设置文字的样式
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal |UIControlStateSelected];
    // 添加为子控制器
    [self addChildViewController:nav];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
