//
//  ZSRApplyViewController.m
//  MYWeiChat
//
//  Created by hp on 6/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRApplyViewController.h"
#import "ZSRApplyFriendCell.h"
#import "ZSRInvitationManager.h"

static ZSRApplyViewController *controller = nil;
@interface ZSRApplyViewController ()<ZSRApplyFriendCellDelegate>

@end

@implementation ZSRApplyViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _dataSource = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)shareController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[self alloc] initWithStyle:UITableViewStylePlain];
    });
    
    return controller;
}

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (NSString *)loginUsername
{
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    return [loginInfo objectForKey:kSDKUsername];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"新的朋友";
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ApplyFriendCell";
    ZSRApplyFriendCell *cell = (ZSRApplyFriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[ZSRApplyFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(self.dataSource.count > indexPath.row)
    {
        ZSRApplyEntity *entity = [self.dataSource objectAtIndex:indexPath.row];
        if (entity) {
            cell.indexPath = indexPath;
            ZSRApplyStyle applyStyle = [entity.style intValue];
            if (applyStyle == ZSRApplyStyleGroupInvitation) {
                cell.titleLabel.text = NSLocalizedString(@"title.groupApply", @"Group Notification");
                cell.headerImageView.image = [UIImage imageNamed:@"groupPrivateHeader"];
            }
            else if (applyStyle == ZSRApplyStyleJoinGroup)
            {
                cell.titleLabel.text = NSLocalizedString(@"title.groupApply", @"Group Notification");
                cell.headerImageView.image = [UIImage imageNamed:@"groupPrivateHeader"];
            }
            else if(applyStyle == ZSRApplyStyleFriend){
                cell.titleLabel.text = entity.applicantUsername;
                cell.headerImageView.image = [UIImage imageNamed:@"chatListCellHead"];
            }
            cell.contentLabel.text = entity.reason;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - ApplyFriendCellDelegate
- (void)applyCellAddFriendAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        [MBProgressHUD showSuccess:@"接受成功"];
        
        ZSRApplyEntity *entity = [self.dataSource objectAtIndex:indexPath.row];
        ZSRApplyStyle applyStyle = [entity.style intValue];
        EMError *error;
        
        /*if (applyStyle == ApplyStyleGroupInvitation) {
         [[EaseMob sharedInstance].chatManager acceptInvitationFromGroup:entity.groupId error:&error];
         }
         else */if (applyStyle == ZSRApplyStyleJoinGroup)
         {
             [[EaseMob sharedInstance].chatManager acceptApplyJoinGroup:entity.groupId groupname:entity.groupSubject applicant:entity.applicantUsername error:&error];
         }
         else if(applyStyle == ZSRApplyStyleFriend){
             [[EaseMob sharedInstance].chatManager acceptBuddyRequest:entity.applicantUsername error:&error];
         }
        if (!error) {
            [self.dataSource removeObject:entity];
            NSString *loginUsername = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
            [[ZSRInvitationManager sharedInstance] removeInvitation:entity loginUser:loginUsername];
            [self.tableView reloadData];
        }
        else{
            [MBProgressHUD showError:@"接受失败"];
        }
    }
}


- (void)applyCellRefuseFriendAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        [MBProgressHUD showSuccess:@"拒绝成功"];
        ZSRApplyEntity *entity = [self.dataSource objectAtIndex:indexPath.row];
        ZSRApplyStyle applyStyle = [entity.style intValue];
        EMError *error;
        
        /*if (applyStyle == ZSRApplyStyleGroupInvitation) {
            [[EaseMob sharedInstance].chatManager rejectInvitationForGroup:entity.groupId toInviter:entity.applicantUsername reason:@""];
        }
        else*/ if (applyStyle == ZSRApplyStyleJoinGroup)
        {
            [[EaseMob sharedInstance].chatManager rejectApplyJoinGroup:entity.groupId groupname:entity.groupSubject toApplicant:entity.applicantUsername reason:nil];
        }
        else if(applyStyle == ZSRApplyStyleFriend){
            [[EaseMob sharedInstance].chatManager rejectBuddyRequest:entity.applicantUsername reason:@"" error:&error];
        }
        
        if (!error) {
            [self.dataSource removeObject:entity];
            NSString *loginUsername = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
            [[ZSRInvitationManager sharedInstance] removeInvitation:entity loginUser:loginUsername];
            
            [self.tableView reloadData];
        }
        else{
            [MBProgressHUD showError:@"拒绝失败"];
        }
    }
}

#pragma mark - public

- (void)addNewApply:(NSDictionary *)dictionary
{
    if (dictionary && [dictionary count] > 0) {
        NSString *applyUsername = [dictionary objectForKey:@"username"];
        ZSRApplyStyle style = [[dictionary objectForKey:@"applyStyle"] intValue];
        
        if (applyUsername && applyUsername.length > 0) {
            for (int i = ((int)[_dataSource count] - 1); i >= 0; i--) {
                ZSRApplyEntity *oldEntity = [_dataSource objectAtIndex:i];
                ZSRApplyStyle oldStyle = [oldEntity.style intValue];
                if (oldStyle == style && [applyUsername isEqualToString:oldEntity.applicantUsername]) {
                    if(style != ZSRApplyStyleFriend)
                    {
                        NSString *newGroupid = [dictionary objectForKey:@"groupname"];
                        if (newGroupid || [newGroupid length] > 0 || [newGroupid isEqualToString:oldEntity.groupId]) {
                            break;
                        }
                    }
                    
                    oldEntity.reason = [dictionary objectForKey:@"applyMessage"];
                    [_dataSource removeObject:oldEntity];
                    [_dataSource insertObject:oldEntity atIndex:0];
                    [self.tableView reloadData];
                    
                    return;
                }
            }
            
            //new apply
            ZSRApplyEntity * newEntity= [[ZSRApplyEntity alloc] init];
            newEntity.applicantUsername = [dictionary objectForKey:@"username"];
            newEntity.style = [dictionary objectForKey:@"applyStyle"];
            newEntity.reason = [dictionary objectForKey:@"applyMessage"];
            
            NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
            NSString *loginName = [loginInfo objectForKey:kSDKUsername];
            newEntity.receiverUsername = loginName;
            
            NSString *groupId = [dictionary objectForKey:@"groupId"];
            newEntity.groupId = (groupId && groupId.length > 0) ? groupId : @"";
            
            NSString *groupSubject = [dictionary objectForKey:@"groupname"];
            newEntity.groupSubject = (groupSubject && groupSubject.length > 0) ? groupSubject : @"";
            
            NSString *loginUsername = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
            [[ZSRInvitationManager sharedInstance] addInvitation:newEntity loginUser:loginUsername];
            
            [_dataSource insertObject:newEntity atIndex:0];
            [self.tableView reloadData];
            
        }
    }
}
- (void)loadDataSourceFromLocalDB
{
    [_dataSource removeAllObjects];
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginName = [loginInfo objectForKey:kSDKUsername];
    if(loginName && [loginName length] > 0)
    {
        
        NSArray * applyArray = [[ZSRInvitationManager sharedInstance] applyEmtitiesWithloginUser:loginName];
        [self.dataSource addObjectsFromArray:applyArray];
        
        [self.tableView reloadData];
    }
}

- (void)back
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setupUntreatedApplyCount" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clear
{
    [_dataSource removeAllObjects];
    [self.tableView reloadData];
}

@end
