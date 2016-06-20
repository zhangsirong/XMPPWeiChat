//
//  ZSRUserProfileViewController.h
//  MYWeiChat
//
//  Created by hp on 6/20/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSRUserProfileViewController : UITableViewController
@property (strong, nonatomic, readonly) NSString *username;

- (instancetype)initWithUsername:(NSString *)username;

@end
