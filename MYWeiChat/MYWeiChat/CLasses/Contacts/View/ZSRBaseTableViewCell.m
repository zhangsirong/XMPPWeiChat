//
//  ZSRContactsCell.m
//  MYWeiChat
//
//  Created by hp on 6/15/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRBaseTableViewCell.h"

@implementation ZSRBaseTableViewCell

+(instancetype)contactCellWithTableView:(UITableView *)tableview
{
    static NSString *ID = @"contactCell";
    return [ZSRBaseTableViewCell contactCellWithTableView:tableview reuseIdentifier:ID];
}

+(instancetype)contactCellWithTableView:(UITableView *)tableview reuseIdentifier:(NSString *)ID
{
    ZSRBaseTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = ZSRColor(207, 210, 213);
        [self.contentView addSubview:_bottomLineView];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
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
    
    _bottomLineView.frame = CGRectMake(0, self.contentView.frame.size.height - 1, self.contentView.frame.size.width, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setUsername:(NSString *)username
{
    _username = username;
    self.textLabel.text = _username;
//    self.imageView.image = [UIImage imageNamed:@"Jobs"];
}

@end
