//
//  ZSRFriendGroup.m
//  MYWeiChat
//
//  Created by hp on 5/7/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRFriendGroup.h"
#import "ZSRFriend.h"
@implementation ZSRFriendGroup

+ (instancetype)groupWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        NSMutableArray *friendArray = [NSMutableArray array];
        for (NSDictionary *dict in self.friends) {
            ZSRFriend *friend = [ZSRFriend friendWithDict:dict];
            [friendArray addObject:friend];
            
        }
        self.friends = friendArray;
    }
    return self;
}
@end
