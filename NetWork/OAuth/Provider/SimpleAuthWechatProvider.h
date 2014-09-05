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
- (void)shareWithText:(NSString *)text imageUrl:(NSString *)imageUrl toAll:(BOOL)toAll completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareWithText:(NSString *)text image:(UIImage *)image toAll:(BOOL)toAll completion:(void (^)(id responseObject, NSError *error))completion;
- (void)shareWithText:(NSString *)text title:(NSString *)title description:(NSString *)description image:(UIImage *)image webUrl:(NSString *)webUrl toAll:(BOOL)toAll completion:(void (^)(id responseObject, NSError *error))completion;
-(void)shareWithText:(NSString *)text title:(NSString *)title description:(NSString *)description image:(UIImage *)image musicUrl:(NSString *)musicUrl musicStreamUrl:(NSString *)musicStreamUrl musicLowBandUrl:(NSString *)musicLowBandUrl musicLowBandStreamUrl:(NSString *)musicLowBandStreamUrl toAll:(BOOL)toAll completion:(void (^)(id, NSError *))completion;
-(void)shareWithText:(NSString *)text title:(NSString *)title description:(NSString *)description image:(UIImage *)image videoUrl:(NSString *)videoUrl videoLowBandUrl:(NSString *)videoLowBandUrl toAll:(BOOL)toAll completion:(void (^)(id, NSError *))completion;

//支付
- (void)payWithAppID:(NSString *)appID partnerID:(NSString *)partnerID prepayID:(NSString *)prepayID nonceStr:(NSString *)nonceStr timeStamp:(int)timeStamp package:(NSString *)package sign:(NSString *)sign completion:(void (^)(id responseObject, NSError *error))completion;

@end
