//
//  ZSRContactSelectionViewController.h
//  MYWeiChat
//
//  Created by hp on 6/18/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRChooseViewController.h"

@interface ZSRContactSelectionViewController : ZSRChooseViewController
//已有选中的成员username，在该页面，这些成员不能被取消选择
- (instancetype)initWithBlockSelectedUsernames:(NSArray *)blockUsernames;

@end
