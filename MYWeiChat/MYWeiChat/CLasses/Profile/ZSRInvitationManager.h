//
//  ZSRInvitationManager.h
//  MYWeiChat
//
//  Created by hp on 6/16/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZSRApplyEntity;
@interface ZSRInvitationManager : NSObject

+ (instancetype)sharedInstance;

-(void)addInvitation:(ZSRApplyEntity *)applyEntity loginUser:(NSString *)username;

-(void)removeInvitation:(ZSRApplyEntity *)applyEntity loginUser:(NSString *)username;

-(NSArray *)applyEmtitiesWithloginUser:(NSString *)username;

@end

@interface ZSRApplyEntity : NSObject 

@property (nonatomic, strong) NSString * applicantUsername;
@property (nonatomic, strong) NSString * applicantNick;
@property (nonatomic, strong) NSString * reason;
@property (nonatomic, strong) NSString * receiverUsername;
@property (nonatomic, strong) NSString * receiverNick;
@property (nonatomic, strong) NSNumber * style;
@property (nonatomic, strong) NSString * groupId;
@property (nonatomic, strong) NSString * groupSubject;

@end
