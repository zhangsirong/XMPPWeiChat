//
//  ZSRUserProfileEditViewController.m
//  MYWeiChat
//
//  Created by hp on 6/21/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRUserProfileEditViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "ZSRUserProfileManager.h"
#import "ZSREditNicknameViewController.h"
#import "UIImageView+HeadImage.h"

@interface ZSRUserProfileEditViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImageView *headImageView;
@property (strong, nonatomic) UILabel *usernameLabel;

@end

@implementation ZSRUserProfileEditViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人信息设置";
    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (UIImageView*)headImageView
{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake(20, 10, 60, 60);
        _headImageView.contentMode = UIViewContentModeScaleToFill;
    }
    ZSRUserProfileEntity *user = [[ZSRUserProfileManager sharedInstance] getCurUserProfile];
    [_headImageView imageWithUsername:user.username placeholderImage:nil];
    return _headImageView;
}

- (UILabel*)usernameLabel
{
    if (!_usernameLabel) {
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10.f, 10, 200, 20);
        ZSRUserProfileEntity *user = [[ZSRUserProfileManager sharedInstance] getCurUserProfile];
        _usernameLabel.text = user.username;
        _usernameLabel.textColor = [UIColor lightGrayColor];
    }
    return _usernameLabel;
}

#pragma mark - getter

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 0) {
        [cell.contentView addSubview:self.headImageView];
        [cell.contentView addSubview:self.usernameLabel];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"昵称";
        ZSRUserProfileEntity *entity = [[ZSRUserProfileManager sharedInstance] getCurUserProfile];
        if (entity && entity.nickname.length>0) {
            cell.detailTextLabel.text = entity.nickname;
        } else {
            cell.detailTextLabel.text = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    if (indexPath.row == 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"照相",@"选择照片", nil];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    } else if (indexPath.row == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请设置昵称" delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"确认", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView cancelButtonIndex] != buttonIndex) {
        //获取文本输入框
        UITextField *nameTextField = [alertView textFieldAtIndex:0];
        if(nameTextField.text.length > 0)
        {
            //设置推送设置
            [MBProgressHUD showMessage:@"正在保存"];
            __weak typeof(self) weakSelf = self;
            [[EaseMob sharedInstance].chatManager setApnsNickname:nameTextField.text];
            [[ZSRUserProfileManager sharedInstance] updateUserProfileInBackground:@{kPARSE_HXUSER_NICKNAME:nameTextField.text} completion:^(BOOL success, NSError *error) {
                [MBProgressHUD hideHUD];
                if (success) {
                    [weakSelf.tableView reloadData];
                } else {
                    [MBProgressHUD showError:@"保存失败"];
                }
            }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showSuccess:@"正在上传照片..."];
    __weak typeof(self) weakSelf = self;
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (orgImage) {
        [[ZSRUserProfileManager sharedInstance] uploadUserHeadImageProfileInBackground:orgImage completion:^(BOOL success, NSError *error) {
            [MBProgressHUD hideHUD];
            if (success) {
                ZSRUserProfileEntity *user = [[ZSRUserProfileManager sharedInstance] getCurUserProfile];
                [weakSelf.headImageView imageWithUsername:user.username placeholderImage:orgImage];
                [MBProgressHUD showSuccess:@"上传成功"];
            } else {
                [MBProgressHUD showError:@"上传失败，请重试..."];
            }
        }];
    } else {
        [MBProgressHUD hideHUD];

        [MBProgressHUD showError:@"上传失败"];

    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
#if TARGET_IPHONE_SIMULATOR
        [MBProgressHUD showError:@"没有摄像头"];
#elif TARGET_OS_IPHONE
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
                _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
            [self presentViewController:self.imagePicker animated:YES completion:NULL];
        } else {
            
        }
#endif
    } else if (buttonIndex == 1) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
        
    }
}
@end
