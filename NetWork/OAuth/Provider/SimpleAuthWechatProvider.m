//
//  SimpleAuthWechatProvider.m
//  ObjcKit
//
//  Created by Wei Mao on 9/3/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "SimpleAuthWechatProvider.h"
#import "WXApi.h"

@interface SimpleAuthWechatProvider()<WXApiDelegate>

@property (nonatomic, copy)         void (^authorizeBlock)(BOOL, NSError *);
@property (nonatomic, copy)         void (^requestBlock)(id, NSError *);

@end

static SimpleAuthWechatProvider *shared_ = nil;

@implementation SimpleAuthWechatProvider

+ (NSString *)type {
    return @"wechat";
}
+ (SimpleAuthWechatProvider *)shared{
    return shared_;
}
- (instancetype)initWithOptions:(NSDictionary *)options {
    if ((self = [super init])) {
        NSArray *keys = [options allKeys];
        if(![keys containsObject:SimpleAuthAppKey])
            return nil;
        self.options = options;
        if (self.scope.length==0) {
            self.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
        }
        [WXApi registerApp:options[SimpleAuthAppKey]];
        shared_ = self;
    }
    return self;
}

- (void)authorizeWithCompletion:(void (^)(BOOL, NSError *))completion{
    if([self isAuthorized]){
        if(completion){
            completion(YES,nil);
            return;
        }
    }
    self.authorizeBlock = completion;
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = self.scope;
    req.state = @"simple_auth_kit";
    [WXApi sendReq:req];
}
-(void)unAuthorize{
    [self.simpleAuth clear];
}
-(BOOL)isAuthorized{
    return YES;
}


//sso回调方法，官方客户端完成sso授权后，回调唤起应用，应用中应调用此方法完成sso登录
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication{
    return [WXApi handleOpenURL:url delegate:self];
}

-(BOOL)isInstalled{
    return [WXApi isWXAppInstalled];
}

#pragma mark - Other Interface
- (void)shareWithText:(NSString *)text toAll:(BOOL)toAll completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = YES;
    req.text  = text;
    req.scene = toAll?WXSceneTimeline:WXSceneSession;
    [WXApi sendReq:req];
}
- (void)shareWithText:(NSString *)text title:(NSString *)title image:(UIImage *)image webUrl:(NSString *)webUrl toAll:(BOOL)toAll completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title       = title;
    message.description = text;
    [message setThumbImage:image];

    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl      = webUrl;
    message.mediaObject = ext;

    // 发送消息
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText   = NO;
    req.message = message;
    req.scene = toAll?WXSceneTimeline:WXSceneSession;
    [WXApi sendReq:req];
}
- (void)shareWithText:(NSString *)text title:(NSString *)title image:(UIImage *)image webUrl:(NSString *)webUrl audioUrl:(NSString *)audioUrl toAll:(BOOL)toAll completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title       = title;
    message.description = text;
    [message setThumbImage:image];

    WXMusicObject *ext = [WXMusicObject object];
    ext.musicUrl = webUrl;
    ext.musicDataUrl = audioUrl;
    message.mediaObject = ext;

    // 发送消息
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText   = NO;
    req.message = message;
    req.scene = toAll?WXSceneTimeline:WXSceneSession;
    [WXApi sendReq:req];
}
- (void)payWithAppID:(NSString *)appID partnerID:(NSString *)partnerID prepayID:(NSString *)prepayID nonceStr:(NSString *)nonceStr timeStamp:(int)timeStamp package:(NSString *)package sign:(NSString *)sign completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    PayReq *req = [[PayReq alloc] init];
    req.openID = appID;
    req.partnerId = partnerID;
    req.prepayId = prepayID;
    req.nonceStr = nonceStr;
    req.timeStamp = timeStamp;
    req.package = package;
    req.sign = sign;
    [WXApi safeSendReq:req];
}

#pragma mark- WXApiDelegate
- (void)onReq:(BaseReq *)req{
}
- (void)onResp:(BaseResp *)resp{
    if ([resp isKindOfClass:[SendAuthResp class]]) { // 微信登陆
//        SendAuthResp *sar = (SendAuthResp *)resp;
        if (resp.errCode == WXSuccess) {
            NSLog(@"[OAuth:Wechat]login success");
            if(self.authorizeBlock){
                self.authorizeBlock(YES, nil);
            }
        }else{
            NSLog(@"[OAuth:Wechat]login fail");
            if(self.authorizeBlock){
                NSError *error = [NSError errorWithDomain:@"WeiChatSDKErrorDomain" code:resp.errCode userInfo:@{@"error":resp.errStr?resp.errStr:@""}];
                self.authorizeBlock(NO, error);
            }
        }
    } else {
        if (resp.errCode == WXSuccess) {
            NSLog(@"[OAuth:Wechat]request success");
            if(self.requestBlock){
                self.requestBlock(resp, nil);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"WeiChatSDKErrorDomain" code:resp.errCode userInfo:@{@"error":resp.errStr?resp.errStr:@""}];
            NSLog(@"[OAuth:Wechat]request fail:%@",error);
            if(self.authorizeBlock){
                self.authorizeBlock(NO, error);
            }
        }
    }
}

@end
