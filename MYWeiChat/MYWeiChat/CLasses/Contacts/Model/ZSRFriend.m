//
//  ZSRFriend.m
//  MYWeiChat
//
//  Created by hp on 5/7/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "ZSRFriend.h"

@implementation ZSRFriend
+ (instancetype)friendWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end
