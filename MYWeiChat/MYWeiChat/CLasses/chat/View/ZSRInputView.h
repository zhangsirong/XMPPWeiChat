//
//  ZSRInputView.h
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSRInputView : UIView
@property (weak, nonatomic) IBOutlet UITextView *textView;
+(instancetype)inputView;
@end
