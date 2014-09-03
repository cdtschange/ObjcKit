//
//  SimpleAuthWechatProvider.h
//  ObjcKit
//
//  Created by Wei Mao on 9/3/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "SimpleAuthProvider.h"

@interface SimpleAuthWechatProvider : SimpleAuthProvider

@property(copy, nonatomic) NSString *scope;

+ (SimpleAuthWechatProvider *)shared;
//sso回调方法，官方客户端完成sso授权后，回调唤起应用，应用中应调用此方法完成sso登录
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

- (BOOL)isInstalled;

//分享
- (void)shareWithText:(NSString *)text toAll:(BOOL)toAll completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareWithText:(NSString *)text title:(NSString *)title image:(UIImage *)image webUrl:(NSString *)webUrl toAll:(BOOL)toAll completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareWithText:(NSString *)text title:(NSString *)title image:(UIImage *)image webUrl:(NSString *)webUrl audioUrl:(NSString *)audioUrl toAll:(BOOL)toAll completion:(void (^)(id responseObject, NSError *error))completion;
- (void)payWithAppID:(NSString *)appID partnerID:(NSString *)partnerID prepayID:(NSString *)prepayID nonceStr:(NSString *)nonceStr timeStamp:(int)timeStamp package:(NSString *)package sign:(NSString *)sign completion:(void (^)(id responseObject, NSError *error))completion;

@end
