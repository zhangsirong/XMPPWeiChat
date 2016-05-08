//
//  ZSRFriendGroup.h
//  MYWeiChat
//
//  Created by hp on 5/7/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSRFriendGroup : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, assign) int online;
@property (nonatomic, assign, getter = isOpened) BOOL opened;

+ (instancetype)groupWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end
