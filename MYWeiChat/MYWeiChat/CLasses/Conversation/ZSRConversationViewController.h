//
//  ZSRConversationViewController.h
//  
//
//  Created by hp on 16/1/21.
//
//

#import <UIKit/UIKit.h>

@interface ZSRConversationViewController : UITableViewController
- (void)refreshDataSource;

- (void)isConnect:(BOOL)isConnect;
- (void)networkChanged:(EMConnectionState)connectionState;

@end
