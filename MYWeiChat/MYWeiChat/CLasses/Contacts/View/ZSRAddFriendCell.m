//
//  ZSRAddFriendCell.m
//  MYWeiChat
//
//  Created by hp on 6/17/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRAddFriendCell.h"

@implementation ZSRAddFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = [UIColor colorWithRed:207 / 255.0 green:210 /255.0 blue:213 / 255.0 alpha:0.7];
        [self addSubview:_bottomLineView];
        
        // Initialization code
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        _addButton.backgroundColor = ZSRColor(9, 187, 7);
        
        [_addButton setTitle:@"添加" forState:UIControlStateNormal];
        [_addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addFriendAction:) forControlEvents:UIControlEventTouchUpInside];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.accessoryView = _addButton;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(10, 8, 34, 34);
    
    CGRect rect = self.textLabel.frame;
    rect.origin.x = CGRectGetMaxX(self.imageView.frame) + 10;
    self.textLabel.frame = rect;
    
    _bottomLineView.frame = CGRectMake(0, self.contentView.frame.size.height - 1, self.frame.size.width, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setUsername:(NSString *)username
{
    _username = username;
    self.textLabel.text = _username;
}

- (void)addFriendAction:(id)sender{
    if(_delegate && _indexPath && [_delegate respondsToSelector:@selector(cellAddFriendAtIndexPath:)])
        [_delegate cellAddFriendAtIndexPath:self.indexPath];
}
@end
