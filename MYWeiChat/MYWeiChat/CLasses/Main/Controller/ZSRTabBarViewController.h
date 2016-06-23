//
//  ZSRTabBarViewController.h
//  
//
//  Created by hp on 16/1/21.
//
//

#import <UIKit/UIKit.h>

@interface ZSRTabBarViewController : UITabBarController
{
    EMConnectionState _connectionState;
}

- (void)jumpToChatList;

- (void)setupUntreatedApplyCount;

- (void)networkChanged:(EMConnectionState)connectionState;

- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

@end
