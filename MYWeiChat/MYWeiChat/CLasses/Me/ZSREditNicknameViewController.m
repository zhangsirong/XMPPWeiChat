//
//  ZSREditNicknameViewController.m
//  MYWeiChat
//
//  Created by hp on 6/21/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSREditNicknameViewController.h"
#import "ZSRAlertView.h"

#define kTextFieldWidth 290.0
#define kTextFieldHeight 40.0
#define kButtonHeight 40.0

@interface ZSREditNicknameViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *nickTextField;

@property (strong, nonatomic) UIButton *saveButton;

@property (strong, nonatomic) UILabel *tipLabel;

@end

@implementation ZSREditNicknameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑昵称";
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self setupTextField];
    [self setupButton];
    [self setupLabel];
    
    [self setupForDismissKeyboard];
}


- (void)setupTextField
{
    _nickTextField = [[UITextField alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds)-kTextFieldWidth)/2, 20.0, kTextFieldWidth, kTextFieldHeight)];
    _nickTextField.layer.cornerRadius = 5.0;
    _nickTextField.placeholder = @"请输入昵称";
    _nickTextField.font = [UIFont systemFontOfSize:15];
    _nickTextField.backgroundColor = [UIColor whiteColor];
    _nickTextField.returnKeyType = UIReturnKeyDone;
    _nickTextField.delegate = self;
    _nickTextField.enablesReturnKeyAutomatically = YES;
    _nickTextField.layer.borderWidth = 0.5;
    _nickTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_nickTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _nickTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"nickname"];
    [[EaseMob sharedInstance].chatManager setApnsNickname:_nickTextField.text];
    [self.view addSubview:_nickTextField];
}

- (void) textFieldDidChange:(id) sender {
    UITextField *_field = (UITextField *)sender;
    if (_field.text.length >0) {
        _tipLabel.textColor = [UIColor redColor];
    } else {
        _tipLabel.textColor = [UIColor lightGrayColor];
    }
}

- (void)setupButton
{
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveButton.frame = CGRectMake((CGRectGetWidth(self.view.bounds)-kTextFieldWidth)/2, CGRectGetMaxY(_nickTextField.frame) + 10.0, kTextFieldWidth, kButtonHeight);
    [_saveButton setBackgroundColor:ZSRColor(75, 213, 97)];
    [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(doSave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveButton];
}

- (void)setupLabel
{
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds)-kTextFieldWidth)/2, CGRectGetMaxY(_saveButton.frame) + 10.0, kTextFieldWidth, 60)];
    _tipLabel.textAlignment = NSTextAlignmentLeft;
    _tipLabel.font = [UIFont systemFontOfSize:14];
    _tipLabel.text = @"";
    CGFloat height = 0;
    NSDictionary *attributes = @{NSFontAttributeName :[UIFont systemFontOfSize:14.0f]};
    CGRect rect = [_tipLabel.text boundingRectWithSize:CGSizeMake(kTextFieldWidth, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:attributes
                                               context:nil];
    height = CGRectGetHeight(rect);
    CGRect frame = _tipLabel.frame;
    frame.size.height = height;
    _tipLabel.frame = frame;
    _tipLabel.numberOfLines = height/14;
    _tipLabel.textColor = [UIColor lightGrayColor];
    [self.view addSubview:_tipLabel];
}

- (void)doSave:(id)sender
{
    if(_nickTextField.text.length > 0)
    {
        //设置推送设置
        [[EaseMob sharedInstance].chatManager setApnsNickname:_nickTextField.text];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.nickTextField.text forKey:@"nickname"];
        [defaults synchronize];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [ZSRAlertView showAlertWithTitle:@"提示"
                                message:@"昵称不可以是空的"
                        completionBlock:nil
                      cancelButtonTitle:@"知道了"
                      otherButtonTitles:nil];
    }
}

- (void)setupForDismissKeyboard {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer *singleTapGR =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAnywhereToDismissKeyboard:)];
    
    __weak UIViewController *weakSelf = self;
    
    NSOperationQueue *mainQuene =[NSOperationQueue mainQueue];
    [nc addObserverForName:UIKeyboardWillShowNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [weakSelf.view addGestureRecognizer:singleTapGR];
                }];
    [nc addObserverForName:UIKeyboardWillHideNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [weakSelf.view removeGestureRecognizer:singleTapGR];
                }];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
}
@end
