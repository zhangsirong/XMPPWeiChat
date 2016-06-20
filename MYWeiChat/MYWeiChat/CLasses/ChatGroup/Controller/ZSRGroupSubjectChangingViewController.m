//
//  ZSRGroupSubjectChangingViewController.m
//  MYWeiChat
//
//  Created by hp on 6/20/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRGroupSubjectChangingViewController.h"

@interface ZSRGroupSubjectChangingViewController () <UITextFieldDelegate>
{
    EMGroup         *_group;
    UITextField     *_subjectField;
}

@end

@implementation ZSRGroupSubjectChangingViewController
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}


- (instancetype)initWithGroup:(EMGroup *)group
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _group = group;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"修改群名称";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    
    CGRect frame = CGRectMake(20, 20, self.view.frame.size.width - 40, 40);
    _subjectField = [[UITextField alloc] initWithFrame:frame];
    _subjectField.layer.cornerRadius = 5.0;
    _subjectField.layer.borderWidth = 1.0;
    _subjectField.placeholder = @"请输入群名称";
    _subjectField.text = _group.groupSubject;
    frame.origin = CGPointMake(frame.size.width - 5.0, 0.0);
    frame.size = CGSizeMake(5.0, 40.0);
    UIView *holder = [[UIView alloc] initWithFrame:frame];
    _subjectField.rightView = holder;
    _subjectField.rightViewMode = UITextFieldViewModeAlways;
    frame.origin = CGPointMake(0.0, 0.0);
    holder = [[UIView alloc] initWithFrame:frame];
    _subjectField.leftView = holder;
    _subjectField.leftViewMode = UITextFieldViewModeAlways;
    _subjectField.delegate = self;
    [self.view addSubview:_subjectField];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - action
- (void)back
{
    if ([_subjectField isFirstResponder])
    {
        [_subjectField resignFirstResponder];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save:(id)sender
{
    [self saveSubject];
    [self back];
}

- (void)saveSubject
{
    [[EaseMob sharedInstance].chatManager asyncChangeGroupSubject:_subjectField.text forGroup:_group.groupId];
}

@end
