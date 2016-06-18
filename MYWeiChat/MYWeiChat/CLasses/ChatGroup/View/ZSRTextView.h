//
//  ZSRTextView.h
//  MYWeiChat
//
//  Created by hp on 6/18/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSRTextView : UITextView
{
    UIColor *_contentColor;
    BOOL _editing;
}

@property(strong, nonatomic) NSString *placeholder;
@property(strong, nonatomic) UIColor *placeholderColor;

@end
