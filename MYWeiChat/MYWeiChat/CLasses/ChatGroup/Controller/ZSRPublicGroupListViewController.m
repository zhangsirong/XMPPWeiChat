//
//  ZSRPublicGroupListViewController.m
//  MYWeiChat
//
//  Created by hp on 6/17/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRPublicGroupListViewController.h"
#import "ZSRPublicGroupDetailViewController.h"
#import "ZSRBaseTableViewCell.h"


@interface GettingMoreFooterView : UIView
@property (strong, nonatomic) UIActivityIndicatorView *activity;
@property (strong, nonatomic) UILabel *label;
@end


#define FetchPublicGroupsPageSize   50

@interface ZSRPublicGroupListViewController ()

@property (strong, nonatomic) NSMutableArray *dataSource;

//@property (strong, nonatomic) GettingMoreFooterView *footerView;
@property (nonatomic, strong) NSString *cursor;
@property (nonatomic) BOOL isGettingMore;
@end

@implementation ZSRPublicGroupListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    self.title = @"公开群";
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];

    [self reloadDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //由于可能有大量公有群在退出页面时需要释放，所以把释放操作放到其它线程避免卡UI
    NSMutableArray *publicGroups = [self.dataSource mutableCopy];
    [self.dataSource removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [publicGroups removeAllObjects];
    });
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";
    ZSRBaseTableViewCell *cell = (ZSRBaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ZSRBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    EMGroup *group = [self.dataSource objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"groupPublicHeader"];
    if (group.groupSubject && group.groupSubject.length > 0) {
        cell.textLabel.text = group.groupSubject;
    }
    else {
        cell.textLabel.text = group.groupId;
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
    
    EMGroup *group = [self.dataSource objectAtIndex:indexPath.row];
    ZSRPublicGroupDetailViewController *detailController = [[ZSRPublicGroupDetailViewController alloc] initWithGroupId:group.groupId];
    detailController.title = group.groupSubject;
    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark - data
- (void)reloadDataSource
{

    _cursor = nil;
    __weak typeof(self) weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncFetchPublicGroupsFromServerWithCursor:_cursor pageSize:FetchPublicGroupsPageSize andCompletion:^(EMCursorResult *result, EMError *error){
        if (weakSelf)
        {
            ZSRPublicGroupListViewController *strongSelf = weakSelf;
            if (!error)
            {
                NSMutableArray *oldGroups = [self.dataSource mutableCopy];
                [self.dataSource removeAllObjects];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [oldGroups removeAllObjects];
                });
                [strongSelf.dataSource addObjectsFromArray:result.list];
                [strongSelf.tableView reloadData];
                strongSelf.cursor = result.cursor;
            }
        }
    }];
}

@end