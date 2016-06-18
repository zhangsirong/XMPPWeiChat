//
//  ZSRRemarkImageView.h
//  MYWeiChat
//
//  Created by hp on 6/18/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSRRemarkImageView : UIView
{
    UILabel *_remarkLabel;
    UIImageView *_imageView;
    
    NSInteger _index;
    BOOL _editing;
}

@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL editing;
@property (strong, nonatomic) NSString *remark;
@property (strong, nonatomic) UIImage *image;
@end
