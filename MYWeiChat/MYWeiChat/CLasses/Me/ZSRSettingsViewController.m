//
//  ZSRMeViewController.m
//  
//
//  Created by hp on 16/1/21.
//
//

#import "ZSRSettingsViewController.h"
#import "ZSRStartViewController.h"
#import "ZSRApplyViewController.h"
#import "ZSRPushNotificationViewController.h"
#import "ZSREditNicknameViewController.h"
#import "ZSRUserProfileEditViewController.h"

@interface ZSRSettingsViewController ()

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UISwitch *autoLoginSwitch;
@property (strong, nonatomic) UISwitch *ipSwitch;
@property (strong, nonatomic) UISwitch *delConversationSwitch;
@property (strong, nonatomic) UISwitch *showCallInfoSwitch;

@end

@implementation ZSRSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = self.footerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UISwitch *)autoLoginSwitch
{
    if (_autoLoginSwitch == nil) {
        _autoLoginSwitch = [[UISwitch alloc] init];
        [_autoLoginSwitch setOn:[[EaseMob sharedInstance].chatManager isAutoLoginEnabled]];
        [_autoLoginSwitch addTarget:self action:@selector(autoLoginChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _autoLoginSwitch;
}

- (UISwitch *)ipSwitch
{
    if (_ipSwitch == nil) {
        _ipSwitch = [[UISwitch alloc] init];
        [_ipSwitch addTarget:self action:@selector(useIpChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _ipSwitch;
}

- (UISwitch *)delConversationSwitch
{
    if (!_delConversationSwitch)
    {
        _delConversationSwitch = [[UISwitch alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL delConversation = [defaults boolForKey:@"delConversation"];
        _delConversationSwitch.on = delConversation;
        [[EaseMob sharedInstance].chatManager setIsAutoDeleteConversationWhenLeaveGroup:delConversation];
        [_delConversationSwitch addTarget:self action:@selector(delConversationChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _delConversationSwitch;
}

- (UISwitch *)showCallInfoSwitch
{
    if (!_showCallInfoSwitch)
    {
        _showCallInfoSwitch = [[UISwitch alloc] init];
        _showCallInfoSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"showCallInfo"] boolValue];
        [_showCallInfoSwitch addTarget:self action:@selector(showCallInfoChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _showCallInfoSwitch;
}

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bScreenWidth, 80)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 0, _footerView.frame.size.width - 10, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_footerView addSubview:line];
        
        UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, _footerView.frame.size.width - 20, 45)];
        [logoutButton setBackgroundColor:[UIColor redColor]];
        NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
        NSString *username = [loginInfo objectForKey:kSDKUsername];
        NSString *logoutButtonTitle = [[NSString alloc] initWithFormat:@"注销(%@)", username];
        [logoutButton setTitle:logoutButtonTitle forState:UIControlStateNormal];
        [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:logoutButton];
    }
    
    return _footerView;
}
#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"自动登录";
            cell.accessoryView = self.autoLoginSwitch;
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"消息推送设置";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = @"诊断";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 3){
            cell.textLabel.text = @"使用IP";
            cell.accessoryView = self.ipSwitch;
        }
        else if (indexPath.row == 4){
            cell.textLabel.text = @"退群时删除会话";
            cell.accessoryView = self.delConversationSwitch;

        } else if (indexPath.row == 5){
            cell.textLabel.text = @"iOS离线推送昵称";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 6){
            cell.textLabel.text = @"显示视频通话信息";
            cell.accessoryView = self.showCallInfoSwitch;

        } else if (indexPath.row == 7){
            cell.textLabel.text = @"个人信息";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            while (cell.contentView.subviews.count) {
                UIView* child = cell.contentView.subviews.lastObject;
                [child removeFromSuperview];
            }
        }
    }
    return cell;

}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        ZSRPushNotificationViewController *pushController = [[ZSRPushNotificationViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:pushController animated:YES];
    }else if (indexPath.row == 5) {
        ZSREditNicknameViewController *editName = [[ZSREditNicknameViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:editName animated:YES];
    }else if (indexPath.row == 7){
        ZSRUserProfileEditViewController *userVc = [[ZSRUserProfileEditViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:userVc animated:YES];
    }
}

#pragma mark - action

- (void)autoLoginChanged:(UISwitch *)autoSwitch
{
        BOOL toOn = autoSwitch.isOn;
       [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:toOn];
}

- (void)useIpChanged:(UISwitch *)ipSwitch
{
    [[EaseMob sharedInstance].chatManager setIsUseIp:ipSwitch.isOn];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSNumber numberWithBool:ipSwitch.isOn] forKey:@"identifier_userip_enable"];
    [ud synchronize];
}

- (void)delConversationChanged:(UISwitch *)control
{
    [EaseMob sharedInstance].chatManager.isAutoDeleteConversationWhenLeaveGroup = control.isOn;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[NSNumber numberWithBool:control.isOn] forKey:@"delConversation"];
    [userDefaults synchronize];
}

- (void)showCallInfoChanged:(UISwitch *)control
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:control.isOn] forKey:@"showCallInfo"];
    [userDefaults synchronize];
}

- (void)refreshConfig
{
    [self.autoLoginSwitch setOn:[[EaseMob sharedInstance].chatManager isAutoLoginEnabled] animated:YES];
    [self.ipSwitch setOn:[[EaseMob sharedInstance].chatManager isUseIp] animated:YES];
    
    [self.tableView reloadData];
}

- (void)logoutAction{
    ZSRLog(@"logAction");
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        if (error) {
            [MBProgressHUD showError:@"注销失败"];

        }else{
            [MBProgressHUD showSuccess:@"注销成功"];
            // 回到登录界面
            [[ZSRApplyViewController shareController] clear];

            ZSRStartViewController *vc = [[ZSRStartViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES ];
            
        }
    } onQueue:nil];
    
}
@end
