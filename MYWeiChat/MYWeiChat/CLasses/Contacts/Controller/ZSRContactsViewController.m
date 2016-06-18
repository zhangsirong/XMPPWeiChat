 //
//  ZSRContactsViewController.m
//  
//
//  Created by hp on 16/1/21.
//
//

#import "ZSRContactsViewController.h"
#import "ZSRAddFriendViewController.h"
#import "ZSRChatViewController.h"
#import "ZSRBaseTableViewCell.h"
#import "EaseMob.h"
#import "MJRefresh.h"
#import "ChineseToPinyin.h"
#import "ZSRUserProfileManager.h"
#import "ZSRApplyViewController.h"
#import "ZSRGroupListViewController.h"

@interface ZSRContactsViewController ()<UITableViewDataSource, UITableViewDelegate,EMChatManagerDelegate,UISearchBarDelegate>

/** 好友列表数据源 */
@property (strong, nonatomic) NSMutableArray *contactsSource;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *sectionTitles;
@property (strong, nonatomic) UILabel *unapplyCountLabel;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ZSRGroupListViewController *groupController;


@end

@implementation ZSRContactsViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
        _contactsSource = [NSMutableArray array];
        _sectionTitles = [NSMutableArray array];
        [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.tableView.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height - 49);
    [self.view addSubview:self.tableView];
    
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
        });
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriendAction)];

    [self reloadDataSource];

    //加载用户好友个人信息
    [[ZSRUserProfileManager sharedInstance] loadUserProfileInBackgroundWithBuddy:self.contactsSource saveToLoacal:YES completion:NULL];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadApplyView];

}


- (UITableView *)tableView
{
    if (_tableView == nil)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _tableView;
}

- (UILabel *)unapplyCountLabel
{
    if (_unapplyCountLabel == nil) {
        _unapplyCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 5, 20, 20)];
        _unapplyCountLabel.textAlignment = NSTextAlignmentCenter;
        _unapplyCountLabel.font = [UIFont systemFontOfSize:11];
        _unapplyCountLabel.backgroundColor = [UIColor redColor];
        _unapplyCountLabel.textColor = [UIColor whiteColor];
        _unapplyCountLabel.layer.cornerRadius = _unapplyCountLabel.frame.size.height / 2;
        _unapplyCountLabel.hidden = NO;
        _unapplyCountLabel.clipsToBounds = YES;
    }
    return _unapplyCountLabel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.dataSource count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 ) {
        return 2;
    }
    return [[self.dataSource objectAtIndex:(section - 1)] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZSRBaseTableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [ZSRBaseTableViewCell contactCellWithTableView:tableView reuseIdentifier:@"FriendCell"];
        cell.imageView.image = [UIImage imageNamed:@"newFriends"];
        cell.textLabel.text = @"新的朋友";
        [cell addSubview:self.unapplyCountLabel];

    }else{
        cell = [ZSRBaseTableViewCell contactCellWithTableView:tableView];
        cell.indexPath = indexPath;
        if (indexPath.section == 0 && indexPath.row == 1) {
            cell.imageView.image = [UIImage imageNamed:@"groupPrivateHeader"];
            cell.username = @"群组";
        }
        else{
            EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@"chatListCellHead.png"];
            cell.username = buddy.username;
        }
    }
    
    return cell;
}

//实现下面的方法就会出现表格的Delete按钮
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // 获取移除好友的名字
        EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
        NSString *deleteUsername = buddy.username;
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        if ([deleteUsername isEqualToString:[loginInfo objectForKey:kSDKUsername]]) {
            [self showAlertMessage:@"不能删除自己"];
            return;
        }
        // 删除好友
        [[EaseMob sharedInstance].chatManager removeBuddy:deleteUsername removeFromRemote:YES error:nil];
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.navigationController pushViewController:[ZSRApplyViewController shareController] animated:YES];
        }
        else if (indexPath.row == 1)
        {
            if (_groupController == nil) {
                _groupController = [[ZSRGroupListViewController alloc] initWithStyle:UITableViewStylePlain];
            }
            else{
                [_groupController reloadDataSource];
            }
            [self.navigationController pushViewController:_groupController animated:YES];
        }

    }else{
        //获取好友
        EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
        ZSRChatViewController *vc = [[ZSRChatViewController alloc] init];
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        if ([buddy.username isEqualToString:[loginInfo objectForKey:kSDKUsername]]) {
            [self showAlertMessage:@"不能和自己聊天"];
            return;
        }
        vc.buddy = buddy;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 || [[self.dataSource objectAtIndex:(section - 1)] count] == 0)
    {
        return nil;
    }
    
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:ZSRColor(220, 220, 220)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:[self.sectionTitles objectAtIndex:(section - 1)]];
    [contentView addSubview:label];
    return contentView;
}




- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || [[self.dataSource objectAtIndex:(section - 1)] count] == 0)
    {
        return 0;
    }
    else{
        return 22;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray * existTitles = [NSMutableArray array];
    for (int i = 0; i < [self.sectionTitles count]; i++) {
        [existTitles addObject:[self.sectionTitles objectAtIndex:i]];
    }
    [existTitles insertObject:@"↑" atIndex:0];
    return existTitles;
}

- (void)addFriendAction{
    ZSRAddFriendViewController *vc = [[ZSRAddFriendViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - chatmanger的代理
// 监听自动登录成功
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    if (!error) {//自动登录成功，此时buddyList就有值
        NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
        NSLog(@"=== %@",buddyList);
        [self.tableView reloadData];
    }
}



#pragma mark - 好友代理方法

//接收好友的添加请求
-(void)didReceiveBuddyRequest:(NSString *)username message:(NSString *)message{
    if (!username) {
        return;
    }
    if (!message) {
        message = [NSString stringWithFormat:NSLocalizedString(@"friend.somebodyAddWithName", @"%@ add you as a friend"), username];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":username, @"username":username, @"applyMessage":message, @"applyStyle":[NSNumber numberWithInteger:ZSRApplyStyleFriend]}];
    [[ZSRApplyViewController shareController] addNewApply:dic];
    [self reloadApplyView];
}
//好友请求被同意
-(void)didAcceptedByBuddy:(NSString *)username{
    
    // 提醒用户，好友请求被同意
    NSString *message = [NSString stringWithFormat:@"%@ 同意了你的好友请求",username];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友添加消息" message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
    [self reloadDataSource];

    
}

//好友请求被拒绝
-(void)didRejectedByBuddy:(NSString *)username{
    // 提醒用户，好友请求被同意
    NSString *message = [NSString stringWithFormat:@"%@ 拒绝了你的好友请求",username];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友添加消息" message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
    
}

//好友列表数据被更新
-(void)didUpdateBuddyList:(NSArray *)buddyList changedBuddies:(NSArray *)changedBuddies isAdd:(BOOL)isAdd{
    
    NSLog(@"好友列表数据被更新 %@",buddyList);
    [self reloadDataSource];
}

//被好友删除
- (void)didRemovedByBuddy:(NSString *)username
{
    // 刷新表格
    [self reloadDataSource];
}



#pragma mark - private
- (void)showAlertMessage:(NSString *)message {
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertViewController addAction:action];
    [alertViewController addAction:cancelAction];
    [self presentViewController:alertViewController animated:YES completion:nil];
}


- (NSMutableArray *)sortDataArray:(NSArray *)dataArray
{
    //建立索引的核心
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    
    [self.sectionTitles removeAllObjects];
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    //返回27，是a－z和＃
    NSInteger highSection = [self.sectionTitles count];
    //tableView 会被分成27个section
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i <= highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    //名字分section
    for (EMBuddy *buddy in dataArray) {
//        getUserName是实现中文拼音检索的核心，见NameIndex类
        NSString *firstLetter = [ChineseToPinyin pinyinFromChineseString:[[ZSRUserProfileManager sharedInstance] getNickNameWithUsername:buddy.username]];
        NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:buddy];
    }
    
    //section内数组排序
    for (int i = 0; i < [sortedArray count]; i++) {

        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(EMBuddy *obj1, EMBuddy *obj2) {
            return [obj1.username caseInsensitiveCompare:obj2.username];
        }];

        [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    
    return sortedArray;
}


- (void)reloadDataSource
{
    [self.dataSource removeAllObjects];
    [self.contactsSource removeAllObjects];
    
    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    NSArray *blockList = [[EaseMob sharedInstance].chatManager blockedList];
    for (EMBuddy *buddy in buddyList) {
        if (![blockList containsObject:buddy.username]) {
            [self.contactsSource addObject:buddy];
        }
    }
    
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    if (loginUsername && loginUsername.length > 0) {
        EMBuddy *loginBuddy = [EMBuddy buddyWithUsername:loginUsername];
        [self.contactsSource addObject:loginBuddy];
    }
    
    [self.dataSource addObjectsFromArray:[self sortDataArray:self.contactsSource]];
    
    [_tableView reloadData];
}


#pragma mark - action

- (void)reloadApplyView
{
    NSInteger count = [[[ZSRApplyViewController shareController] dataSource] count];
   
    if (count == 0) {
        self.unapplyCountLabel.hidden = YES;
        self.navigationController.tabBarItem.badgeValue = nil;

    }
    else
    {
        NSString *tmpStr = [NSString stringWithFormat:@"%i", (int)count];
        CGRect rect = [tmpStr boundingRectWithSize:CGSizeMake(50, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
        CGRect unapplyRect = self.unapplyCountLabel.frame;
        unapplyRect.size.width = rect.size.width > 20 ? rect.size.width : 20;
        self.unapplyCountLabel.text = tmpStr;
        self.unapplyCountLabel.frame = unapplyRect;
        self.unapplyCountLabel.hidden = NO;
        [self.tableView reloadData];
        self.navigationController.tabBarItem.badgeValue  = [NSString stringWithFormat:@"%ld",count];
    }
}

@end
