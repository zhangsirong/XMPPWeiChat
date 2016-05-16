//
//  ZSRInputView.m
//  MYWeiChat
//
//  Created by hp on 5/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRInputView.h"

@implementation ZSRInputView

+(instancetype)inputView{
    return [[[NSBundle mainBundle] loadNibNamed:@"ZSRInputView" owner:nil options:nil] lastObject];
}
@end
