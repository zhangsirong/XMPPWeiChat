//
//  ZSRContactView.h
//  MYWeiChat
//
//  Created by hp on 6/20/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRRemarkImageView.h"

@interface ZSRContactView : ZSRRemarkImageView
{
    UIButton *_deleteButton;
}

@property (copy) void (^deleteContact)(NSInteger index);

@end
