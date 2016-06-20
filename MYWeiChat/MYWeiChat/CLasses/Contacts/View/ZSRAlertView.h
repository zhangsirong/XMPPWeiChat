//
//  ZSRAlertView.h
//  MYWeiChat
//
//  Created by hp on 6/20/16.
//  Copyright © 2016 hp. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ZSRAlertView:UIAlertView


/**
 *  弹出提示框
 *
 *  @param title             <#title description#>
 *  @param message           <#message description#>
 *  @param block             <#block description#>
 *  @param cancelButtonTitle <#cancelButtonTitle description#>
 *  @param otherButtonTitles <#otherButtonTitles description#>
 *
 *  @return <#return value description#>
 */
+ (id)showAlertWithTitle:(NSString *)title
                 message:(NSString *)message
         completionBlock:(void (^)(NSUInteger buttonIndex, ZSRAlertView *alertView))block
       cancelButtonTitle:(NSString *)cancelButtonTitle
       otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end