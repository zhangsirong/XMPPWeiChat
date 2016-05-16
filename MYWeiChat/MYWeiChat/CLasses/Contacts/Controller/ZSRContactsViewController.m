//
//  ZSRContactsViewController.m
//  
//
//  Created by hp on 16/1/21.
//
//

#import "ZSRContactsViewController.h"
#import "ZSRAddFriendViewController.h"
#import "EaseMob.h"

@interface ZSRContactsViewController ()<EMChatManagerDelegate>

/** 好友列表数据源 */
@property (nonatomic, strong) NSArray *buddyList;

@end

@implementation ZSRContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 80;
    
    
//    self.view.backgroundColor = [UIColor redColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriendAction)];
    // 添加聊天管理器的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
   
    self.buddyList =  [[EaseMob sharedInstance].chatManager buddyList];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.buddyList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // 1.定义一个cell的标识
    static NSString *ID = @"cell";
    // 2.从缓存池中取出cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    // 3.如果缓存池中没有cell
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
       
    }
    // 4.设置cell的属性...
    // 1。获取“好友”模型
    EMBuddy *buddy = self.buddyList[indexPath.row];
    
    // 2.显示头像
    cell.imageView.image = [UIImage imageNamed:@"DefaultHead"];
    
    // 3.显示名称
    cell.textLabel.text = buddy.username;
    return cell;
}

- (void)addFriendAction{
    ZSRAddFriendViewController *vc = [[ZSRAddFriendViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - chatmanger的代理
#pragma mark - 监听自动登录成功
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    if (!error) {//自动登录成功，此时buddyList就有值
        self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
        NSLog(@"=== %@",self.buddyList);
        [self.tableView reloadData];
    }
}
#pragma mark 好友添加请求同意
-(void)didAcceptedByBuddy:(NSString *)username{
    // 把新的好友显示到表格
    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    NSLog(@"好友添加请求同意 %@",buddyList);
#warning buddyList的个数，仍然是没有添加好友之前的个数，从新服务器获取
    [self loadBuddyListFromServer];
    
    
}

#pragma mark 从新服务器获取好友列表
-(void)loadBuddyListFromServer{
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        NSLog(@"从服务器获取的好友列表 %@",buddyList);
        
        // 赋值数据源
        self.buddyList = buddyList;
        
        // 刷新
        [self.tableView reloadData];
        
    } onQueue:nil];
}

#pragma mark 好友列表数据被更新
-(void)didUpdateBuddyList:(NSArray *)buddyList changedBuddies:(NSArray *)changedBuddies isAdd:(BOOL)isAdd{
    
    NSLog(@"好友列表数据被更新 %@",buddyList);
}

#pragma mark 被好友删除
- (void)didRemovedByBuddy:(NSString *)username
{
    // 刷新表格
    [self loadBuddyListFromServer];
}

#pragma mark  实现下面的方法就会出现表格的Delete按钮
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // 获取移除好友的名字
        EMBuddy *buddy = self.buddyList[indexPath.row];
        NSString *deleteUsername = buddy.username;
        
        // 删除好友
        [[EaseMob sharedInstance].chatManager removeBuddy:deleteUsername removeFromRemote:YES error:nil];
    }
}

@end
