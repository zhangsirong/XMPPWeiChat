//
//  ZSRContactsViewController.m
//  
//
//  Created by hp on 16/1/21.
//
//

#import "ZSRContactsViewController.h"
#import "ZSRFriendGroup.h"
#import "ZSRFriend.h"
#import "ZSRFriendCell.h"
#import "ZSRHeaderView.h"

@interface ZSRContactsViewController () <ZSRHeaderViewDelegate>
@property (nonatomic, strong) NSArray *groups;
@end

@implementation ZSRContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.tableView.rowHeight = 50;
    self.tableView.sectionHeaderHeight = 44;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSArray *)groups
{
    if (_groups == nil) {
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"friends.plist" ofType:nil]];
        
        NSMutableArray *groupArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            ZSRFriendGroup *group = [ZSRFriendGroup groupWithDict:dict];
            [groupArray addObject:group];
        }
        
        _groups = groupArray;
    }
    return _groups;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return self.groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    ZSRFriendGroup *group = self.groups[section];
    return (group.isOpened ? group.friends.count : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZSRFriendCell *cell = [ZSRFriendCell cellWithTableView:tableView];
    
    ZSRFriendGroup *group = self.groups[indexPath.section];
    cell.friendData = group.friends[indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ZSRHeaderView *header = [ZSRHeaderView headerViewWithTableView:tableView];
    header.delegate = self;
    
    header.group = self.groups[section];
    
    return header;
}

#pragma mark - headerView的代理方法

- (void)headerViewDidClickedNameView:(ZSRHeaderView *)headerView
{
    [self.tableView reloadData];
}
@end
