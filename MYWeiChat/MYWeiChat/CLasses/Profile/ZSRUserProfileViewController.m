//
//  ZSRUserProfileViewController.m
//  MYWeiChat
//
//  Created by hp on 6/20/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRUserProfileViewController.h"

#import "ZSRChatViewController.h"
#import "ZSRUserProfileManager.h"
#import "UIImageView+HeadImage.h"


@interface ZSRUserProfileViewController ()

@property (strong, nonatomic) ZSRUserProfileEntity *user;

@property (strong, nonatomic) UIImageView *headImageView;
@property (strong, nonatomic) UILabel *usernameLabel;

@end

@implementation ZSRUserProfileViewController

- (instancetype)initWithUsername:(NSString *)username
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _username = username;
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"详细资料";
    
    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.allowsSelection = NO;
    [self loadUserProfile];
}

- (UIImageView*)headImageView
{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake(20, 10, 60, 60);
        _headImageView.contentMode = UIViewContentModeScaleToFill;
    }
    [_headImageView imageWithUsername:_username placeholderImage:nil];
    return _headImageView;
}

- (UILabel*)usernameLabel
{
    if (!_usernameLabel) {
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10.f, 10, 200, 20);
        _usernameLabel.text = _username;
        _usernameLabel.textColor = [UIColor lightGrayColor];
    }
    return _usernameLabel;
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row == 0) {
        //cell.textLabel.text = NSLocalizedString(@"setting.personalInfoUpload", @"Upload HeadImage");
        [cell.contentView addSubview:self.headImageView];
        [cell.contentView addSubview:self.usernameLabel];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"昵称";
        ZSRUserProfileEntity *entity = [[ZSRUserProfileManager sharedInstance] getUserProfileByUsername:_username];
        if (entity && entity.nickname.length>0) {
            cell.detailTextLabel.text = entity.nickname;
        } else {
            cell.detailTextLabel.text = _username;
        }
        //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 80;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)loadUserProfile
{
    [MBProgressHUD hideHUD];

    [MBProgressHUD showMessage:@"加载数据"];
    __weak typeof(self) weakself = self;
    [[ZSRUserProfileManager sharedInstance] loadUserProfileInBackground:@[_username] saveToLoacal:YES completion:^(BOOL success, NSError *error) {
    [MBProgressHUD hideHUD];
        if (success) {
            [weakself.tableView reloadData];
        }
    }];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
