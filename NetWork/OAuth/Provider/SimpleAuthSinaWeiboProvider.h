//
//  SimpleAuthSinaWeiboProvider.h
//  ObjcKit
//
//  Created by Wei Mao on 9/3/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "SimpleAuthProvider.h"

@interface SimpleAuthSinaWeiboProvider : SimpleAuthProvider

+ (SimpleAuthSinaWeiboProvider *)shared;
//sso回调方法，官方客户端完成sso授权后，回调唤起应用，应用中应调用此方法完成sso登录
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

//获取用户信息
- (void)getUserInfoWithCompletion:(void (^)(id responseObject, NSError *error))completion;
- (void)getUserInfoByUID:(NSString*)uid completion:(void (^)(id responseObject, NSError *error))completion;
- (void)getUserInfoByName:(NSString *)name completion:(void (^)(id responseObject, NSError *error))completion;
//发送一条微博
- (void)shareWithText:(NSString *)text completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareWithText:(NSString *)text imageUrl:(NSString *)imageUrl completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareWithText:(NSString *)text image:(UIImage *)image completion:(void (^)(id responseObject, NSError *error))completion;
@end
