//
//  ZSRChatListCell.m
//  MYWeiChat
//
//  Created by hp on 6/15/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRChatListCell.h"
#import "UIImageView+WebCache.h"
#import "Constant.h"
@interface ZSRChatListCell (){
    UILabel *_timeLabel;
    UILabel *_unreadLabel;
    UIView *_lineView;


}
@end


@implementation ZSRChatListCell

+(instancetype)chatListCellWithTableView:(UITableView *)tableview
{
    static NSString *ID = @"chatListCell";
    ZSRChatListCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[self alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];

    }
    
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        // Initialization code
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 16)];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.backgroundColor = [UIColor clearColor];
        self.accessoryView = _timeLabel;
        
        _unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 20, 20)];
        _unreadLabel.backgroundColor = [UIColor redColor];
        _unreadLabel.textColor = [UIColor whiteColor];
        
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.font = [UIFont systemFontOfSize:11];
        _unreadLabel.layer.cornerRadius = 10;
        _unreadLabel.clipsToBounds = YES;
        [self.contentView addSubview:_unreadLabel];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bScreenWidth, 1)];
        _lineView.backgroundColor = ZSRColor(207, 210, 213);
        [self.contentView addSubview:_lineView];
        self.backgroundColor = ZSRColor(246, 246, 246);
;


    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = [UIColor redColor];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = [UIColor redColor];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(20, 5, 50, 50);

    [self.imageView sd_setImageWithURL:_imageURL placeholderImage:_placeholderImage];
    self.textLabel.text = _name;
    self.detailTextLabel.text = _detailMsg;
    _timeLabel.text = _time;
    if (_unreadCount > 0) {
        if (_unreadCount < 9) {
            _unreadLabel.font = [UIFont systemFontOfSize:13];
        }else if(_unreadCount > 9 && _unreadCount < 99){
            _unreadLabel.font = [UIFont systemFontOfSize:12];
        }else{
            _unreadLabel.font = [UIFont systemFontOfSize:10];
        }
        [_unreadLabel setHidden:NO];
        [self.contentView bringSubviewToFront:_unreadLabel];
        _unreadLabel.text = [NSString stringWithFormat:@"%ld",(long)_unreadCount];
    }else{
        [_unreadLabel setHidden:YES];
    }
    
}

-(void)setName:(NSString *)name{
    _name = name;
}

+(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
@end
