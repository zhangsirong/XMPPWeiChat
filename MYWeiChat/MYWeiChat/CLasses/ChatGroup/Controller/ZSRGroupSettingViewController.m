//
//  ZSRGroupSettingViewController.m
//  MYWeiChat
//
//  Created by hp on 6/20/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRGroupSettingViewController.h"
@interface ZSRGroupSettingViewController()
{
    EMGroup *_group;
    BOOL _isOwner;
    UISwitch *_pushSwitch;
    UISwitch *_blockSwitch;
}

@end

@implementation ZSRGroupSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (instancetype)initWithGroup:(EMGroup *)group
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        _group = group;
        
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
        _isOwner = [_group.owner isEqualToString:loginUsername];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_isOwner) {
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
        [self.navigationItem setRightBarButtonItem:saveItem];
    }
    
    _pushSwitch = [[UISwitch alloc] init];
    [_pushSwitch addTarget:self action:@selector(pushSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [_pushSwitch setOn:_group.isPushNotificationEnabled animated:YES];
    
    _blockSwitch = [[UISwitch alloc] init];
    [_blockSwitch addTarget:self action:@selector(blockSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [_blockSwitch setOn:_group.isBlocked animated:YES];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (_isOwner) {
        return 1;
    }
    else{
        if (_blockSwitch.isOn) {
            return 1;
        }
        else{
            return 2;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ((_isOwner && indexPath.row == 0) || (!_isOwner && indexPath.row == 1)) {
        _pushSwitch.frame = CGRectMake(self.tableView.frame.size.width - (_pushSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - _pushSwitch.frame.size.height) / 2, _pushSwitch.frame.size.width, _pushSwitch.frame.size.height);
        
        if (_pushSwitch.isOn) {
            cell.textLabel.text = @"接收并提示群信息";
        }
        else{
            cell.textLabel.text = @"只接收不提示群信息";
        }
        
        [cell.contentView addSubview:_pushSwitch];
        [cell.contentView bringSubviewToFront:_pushSwitch];
    }
    else if(!_isOwner && indexPath.row == 0){
        _blockSwitch.frame = CGRectMake(self.tableView.frame.size.width - (_blockSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - _blockSwitch.frame.size.height) / 2, _blockSwitch.frame.size.width, _blockSwitch.frame.size.height);
        
        cell.textLabel.text = @"屏蔽群信息";
        [cell.contentView addSubview:_blockSwitch];
        [cell.contentView bringSubviewToFront:_blockSwitch];
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
}

#pragma mark - private

- (void)isIgnoreGroup:(BOOL)isIgnore
{
    [MBProgressHUD showMessage:@"设置属性"];
    
    [[EaseMob sharedInstance].chatManager asyncIgnoreGroupPushNotification:_group.groupId isIgnore:isIgnore completion:^(NSArray *ignoreGroupsList, EMError *error) {
        [MBProgressHUD hideHUD];
        if (!error) {
            [MBProgressHUD showSuccess:@"设置成功"];
        }
        else{
            [MBProgressHUD showError:@"设置失败"];
        }
    } onQueue:nil];
    
}

#pragma mark - action

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushSwitchChanged:(id)sender
{
    if (_isOwner) {
        BOOL toOn = _pushSwitch.isOn;
        [self isIgnoreGroup:!toOn];
    }
    [self.tableView reloadData];
}

- (void)blockSwitchChanged:(id)sender
{
    [self.tableView reloadData];
}

- (void)saveAction:(id)sender
{
    if (_blockSwitch.isOn != _group.isBlocked) {
        [MBProgressHUD showMessage:@"设置属性"];
        if (_blockSwitch.isOn) {
            [[EaseMob sharedInstance].chatManager asyncBlockGroup:_group.groupId completion:^(EMGroup *group, EMError *error) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"设置成功"];
            } onQueue:nil];
        }
        else{
            [[EaseMob sharedInstance].chatManager asyncUnblockGroup:_group.groupId completion:^(EMGroup *group, EMError *error) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"设置成功"];
            } onQueue:nil];
        }
    }
    
    if (_pushSwitch.isOn != _group.isPushNotificationEnabled) {
        [MBProgressHUD hideHUD];
        [self isIgnoreGroup:!_pushSwitch.isOn];
    }
}

@end