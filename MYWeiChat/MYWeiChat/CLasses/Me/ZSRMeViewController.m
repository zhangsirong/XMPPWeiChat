//
//  ZSRMeViewController.m
//  
//
//  Created by hp on 16/1/21.
//
//

#import "ZSRMeViewController.h"
#import "EaseMob.h"
#import "ZSRStartViewController.h"
@interface ZSRMeViewController ()

@end

@implementation ZSRMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStylePlain target:self action:@selector(logAction)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//显示每组多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//返回一个cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    // 当前登录的用户名
    NSString *loginUsername = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    cell.textLabel.text = loginUsername;
    cell.imageView.image = [UIImage imageNamed:@"DefaultProfileHead_phone"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)logAction{
    ZSRLog(@"logAction");
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        if (error) {
            NSLog(@"退出失败 %@",error);
            
        }else{
            NSLog(@"退出成功");
            // 回到登录界面
            ZSRStartViewController *vc = [[ZSRStartViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES ];
            
        }
    } onQueue:nil];

}
@end
