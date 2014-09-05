//
//  SimpleAuthTencentProvider.h
//  ObjcKit
//
//  Created by Wei Mao on 9/3/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "SimpleAuthProvider.h"

@interface SimpleAuthTencentProvider : SimpleAuthProvider

@property(nonatomic, strong) NSArray *permissions;

+ (SimpleAuthTencentProvider *)shared;
//sso回调方法，官方客户端完成sso授权后，回调唤起应用，应用中应调用此方法完成sso登录
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

- (BOOL)isInstalled;

//获取用户信息
- (void)getUserInfoWithCompletion:(void (^)(id responseObject, NSError *error))completion;
//分享
- (void)shareToQQFriendWithText:(NSString*)text completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareToQQFriendWithTitle:(NSString*)title image:(UIImage*)image description:(NSString*)description completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareToQQFriendWithTitle:(NSString*)title image:(UIImage*)image description:(NSString*)description newsUrl:(NSString*)newsUrl completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareToQQFriendWithTitle:(NSString*)title image:(UIImage*)image description:(NSString*)description audioUrl:(NSString*)audioUrl completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareToQQFriendWithTitle:(NSString*)title image:(UIImage*)image description:(NSString*)description videoUrl:(NSString*)videoUrl completion:(void (^)(id responseObject, NSError *error))completion;
@end
