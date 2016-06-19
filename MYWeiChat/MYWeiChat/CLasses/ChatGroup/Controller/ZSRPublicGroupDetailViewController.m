//
//  ZSRPublicGroupDetailViewController.m
//  MYWeiChat
//
//  Created by hp on 6/18/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRPublicGroupDetailViewController.h"
#import "Constant.h"
@interface ZSRPublicGroupDetailViewController ()<UIAlertViewDelegate>

@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) EMGroup *group;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIButton *footerButton;
@property (strong, nonatomic) UILabel *nameLabel;

@end

@implementation ZSRPublicGroupDetailViewController
- (instancetype)initWithGroupId:(NSString *)groupId
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        _groupId = groupId;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = self.footerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self fetchGroupInfo];
}


#pragma mark - getter

- (UIView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
        imageView.image = [UIImage imageNamed:@"groupPublicHeader"];
        [_headerView addSubview:imageView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 20, _headerView.frame.size.width - 80 - 20, 30)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.text = (_group.groupSubject && _group.groupSubject.length) > 0 ? _group.groupSubject : _group.groupId;
        [_headerView addSubview:_nameLabel];
}
    
    return _headerView;
}

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bScreenWidth, 80)];
        _footerView.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _footerView.frame.size.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_footerView addSubview:line];
        
        _footerButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 20, _footerView.frame.size.width - 80, 40)];
        [_footerButton setTitle:@"加入群组" forState:UIControlStateNormal];
        [_footerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_footerButton addTarget:self action:@selector(joinAction) forControlEvents:UIControlEventTouchUpInside];
        [_footerButton setBackgroundColor:ZSRColor(7, 187, 10)];
         _footerButton.enabled = NO;
        [_footerView addSubview:_footerButton];
    }
    
    return _footerView;
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bScreenWidth, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:line];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//点击cell没点击阴影效果
        cell.userInteractionEnabled = NO;//设置cell不能点击
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"群主";
        cell.detailTextLabel.text = _group.owner;
    }
    else{
        cell.textLabel.text = @"群简介";
        cell.detailTextLabel.text = _group.groupDescription;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 50;
    }
    else{
        CGSize size = [_group.groupDescription sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(220, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        
        return size.height > 30 ? (20 + size.height) : 50;
    }
}

#pragma mark - alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView cancelButtonIndex] != buttonIndex) {
        UITextField *messageTextField = [alertView textFieldAtIndex:0];
        
        NSString *messageStr = @"";
        if (messageTextField.text.length > 0) {
            messageStr = messageTextField.text;
        }
        [self applyJoinGroup:_groupId withGroupname:_group.groupSubject message:messageStr];
    }
}

#pragma mark - action

- (BOOL)isJoined:(EMGroup *)group
{
    if (group) {
        NSArray *groupList = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *tmpGroup in groupList) {
            if (tmpGroup.isPublic == group.isPublic && [group.groupId isEqualToString:tmpGroup.groupId]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)fetchGroupInfo
{
    [MBProgressHUD showMessage:@"正在加载。。。"];
    
    __weak ZSRPublicGroupDetailViewController *weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:_groupId includesOccupantList:NO completion:^(EMGroup *group, EMError *error) {
        weakSelf.group = group;
        [weakSelf reloadSubviewsInfo];
        [MBProgressHUD hideHUD];
    } onQueue:nil];
}

- (void)reloadSubviewsInfo
{
    __weak ZSRPublicGroupDetailViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.nameLabel.text = (weakSelf.group.groupSubject && weakSelf.group.groupSubject.length) > 0 ? weakSelf.group.groupSubject : weakSelf.group.groupId;
        if ([weakSelf isJoined:weakSelf.group]) {
            weakSelf.footerButton.enabled = NO;
            [weakSelf.footerButton setBackgroundColor:[UIColor grayColor]];
            [weakSelf.footerButton setTitle:@"已加入" forState:UIControlStateNormal | UIControlStateDisabled];
        }
        else{
            weakSelf.footerButton.enabled = YES;
            [weakSelf.footerButton setTitle:@"加入群组" forState:UIControlStateNormal];
        }
        [weakSelf.tableView reloadData];
    });
}

- (void)showMessageAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请求加入" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}

- (void)joinAction
{
    
    if (self.group.groupSetting.groupStyle == eGroupStyle_PublicJoinNeedApproval) {
        [self showMessageAlertView];
    }
    else if (self.group.groupSetting.groupStyle == eGroupStyle_PublicOpenJoin)
    {
        [self joinGroup:_groupId];
    }
}

- (void)joinGroup:(NSString *)groupId
{
    [MBProgressHUD showMessage:@"加入群组"];
    __weak ZSRPublicGroupDetailViewController *weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncJoinPublicGroup:groupId completion:^(EMGroup *group, EMError *error) {
        [MBProgressHUD hideHUD];
        if(!error)
        {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else{
            
            [MBProgressHUD showError:@"加入群组失败"];
        }
    } onQueue:nil];
}

- (void)applyJoinGroup:(NSString *)groupId withGroupname:(NSString *)groupName message:(NSString *)message
{
    [MBProgressHUD showMessage:@"申请加入群组..."];
    [[EaseMob sharedInstance].chatManager asyncApplyJoinPublicGroup:groupId withGroupname:groupName message:message completion:^(EMGroup *group, EMError *error) {
        [MBProgressHUD hideHUD];
        if (!error) {
            [MBProgressHUD showSuccess:@"申请成功"];

        }
        else{
            [MBProgressHUD showError:error.description];
        }
    } onQueue:nil];
}
@end
