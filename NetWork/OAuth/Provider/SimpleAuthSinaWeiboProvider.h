//
//  SimpleAuthSinaWeiboProvider.h
//  ObjcKit
//
//  Created by Wei Mao on 9/3/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "SimpleAuthProvider.h"

@interface SimpleAuthSinaWeiboProvider : SimpleAuthProvider

@property (nonatomic, copy)         NSString*           scope;

+ (SimpleAuthSinaWeiboProvider *)shared;
//sso回调方法，官方客户端完成sso授权后，回调唤起应用，应用中应调用此方法完成sso登录
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;
- (BOOL)isInstalled;

//用户信息
- (void)getUserInfoWithCompletion:(void (^)(id responseObject, NSError *error))completion;
- (void)getUserInfoByUID:(NSString*)uid completion:(void (^)(id responseObject, NSError *error))completion;
- (void)getUserInfoByName:(NSString *)name completion:(void (^)(id responseObject, NSError *error))completion;
- (void)getUserCountsByUIDs:(NSString *)uids completion:(void (^)(id responseObject, NSError *error))completion;

//微博
//发送一条微博
- (void)shareWithText:(NSString *)text completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareWithText:(NSString *)text imageUrl:(NSString *)imageUrl completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareWithText:(NSString *)text image:(UIImage *)image completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareWithText:(NSString *)text title:(NSString *)title description:(NSString *)description image:(UIImage *)image webUrl:(NSString *)webUrl completion:(void (^)(id responseObject, NSError *error))completion;
-(void)shareWithText:(NSString *)text title:(NSString *)title description:(NSString *)description image:(UIImage *)image musicUrl:(NSString *)musicUrl musicStreamUrl:(NSString *)musicStreamUrl musicLowBandUrl:(NSString *)musicLowBandUrl musicLowBandStreamUrl:(NSString *)musicLowBandStreamUrl completion:(void (^)(id, NSError *))completion;
-(void)shareWithText:(NSString *)text title:(NSString *)title description:(NSString *)description image:(UIImage *)image videoUrl:(NSString *)videoUrl videoStreamUrl:(NSString *)videoStreamUrl videoLowBandUrl:(NSString *)videoLowBandUrl videoLowBandStreamUrl:(NSString *)videoLowBandStreamUrl completion:(void (^)(id, NSError *))completion;
//获取微博
- (void)getPublicStatusesWithCount:(int)count completion:(void (^)(id responseObject, NSError *error))completion;
- (void)getFriendsStatusesWithCount:(int)count page:(int)page completion:(void (^)(id responseObject, NSError *error))completion;
- (void)getStatusByID:(long long)statusID completion:(void (^)(id responseObject, NSError *error))completion;
//删除微博
- (void)delStatusByID:(long long)statusID completion:(void (^)(id responseObject, NSError *error))completion;

//评论
- (void)getCommentsByStatusID:(long long)statusID count:(int)count page:(int)page completion:(void (^)(id responseObject, NSError *error))completion;
- (void)getMyCommentsWithCount:(int)count page:(int)page completion:(void (^)(id responseObject, NSError *error))completion;
- (void)getCommentsToMeWithCount:(int)count page:(int)page completion:(void (^)(id responseObject, NSError *error))completion;
- (void)getCommentsMetionMeWithCount:(int)count page:(int)page completion:(void (^)(id responseObject, NSError *error))completion;
- (void)commentWithStatusID:(long long)statusID text:(NSString *)text completion:(void (^)(id responseObject, NSError *error))completion;
- (void)delCommentByID:(long long)commentID completion:(void (^)(id responseObject, NSError *error))completion;
- (void)replyCommentByStatusID:(long long)statusID commentID:(long long)commentID text:(NSString *)text completion:(void (^)(id responseObject, NSError *error))completion;
@end
