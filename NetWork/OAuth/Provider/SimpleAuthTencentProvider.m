//
//  SimpleAuthTencentProvider.m
//  ObjcKit
//
//  Created by Wei Mao on 9/3/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "SimpleAuthTencentProvider.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "NSFileManager+Kit.h"

@interface SimpleAuthTencentProvider()<TencentSessionDelegate,QQApiInterfaceDelegate>

@property(nonatomic,strong)         TencentOAuth        *engine ;
@property (nonatomic, copy)         void (^authorizeBlock)(BOOL, NSError *);
@property (nonatomic, copy)         void (^requestBlock)(id, NSError *);

@end

static SimpleAuthTencentProvider *shared_ = nil;

@implementation SimpleAuthTencentProvider

+ (NSString *)type {
    return @"tencent";
}
+ (SimpleAuthTencentProvider *)shared{
    return shared_;
}
- (instancetype)initWithOptions:(NSDictionary *)options {
    if ((self = [super initWithOptions:options])) {
        NSArray *keys = [options allKeys];
        if(![keys containsObject:SimpleAuthAppKey]||
           ![keys containsObject:SimpleAuthRedirectURI])
            return nil;
        self.options = options;
        if (!self.permissions) {
            self.permissions = [NSArray arrayWithObjects:
                                kOPEN_PERMISSION_GET_USER_INFO,
                                kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                kOPEN_PERMISSION_ADD_ONE_BLOG,
                                kOPEN_PERMISSION_ADD_PIC_T,
                                kOPEN_PERMISSION_ADD_SHARE,
                                kOPEN_PERMISSION_ADD_TOPIC,
                                kOPEN_PERMISSION_CHECK_PAGE_FANS,
                                kOPEN_PERMISSION_GET_FANSLIST,
                                kOPEN_PERMISSION_GET_IDOLLIST,
                                kOPEN_PERMISSION_GET_INFO,
                                kOPEN_PERMISSION_GET_OTHER_INFO,
                                kOPEN_PERMISSION_GET_REPOST_LIST,
                                kOPEN_PERMISSION_LIST_ALBUM,
                                kOPEN_PERMISSION_UPLOAD_PIC,
                                kOPEN_PERMISSION_GET_VIP_INFO,
                                kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                                kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                                kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                                nil];
        }
        self.engine = [[TencentOAuth alloc] initWithAppId:options[SimpleAuthAppKey] andDelegate:self];
        self.engine.redirectURI = options[SimpleAuthRedirectURI];
        self.engine.openId = self.simpleAuth.uid;
        self.engine.accessToken = self.simpleAuth.accessToken;
        self.engine.expirationDate = self.simpleAuth.expirationDate;
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

    // APPKEY权限
    [self.engine authorize:self.permissions inSafari:NO];
}
-(void)unAuthorize{
    [self.engine logout:self];
    [self.simpleAuth clear];
}
-(BOOL)isAuthorized{
    if(self.engine.openId.length > 0 && self.engine.accessToken.length > 0 && self.engine.expirationDate){
        if(![self.engine isSessionValid]){
            return NO;
        }
        if(self.simpleAuth.uid.length==0){
            self.simpleAuth.uid = self.engine.openId;
            self.simpleAuth.accessToken = self.engine.accessToken;
            self.simpleAuth.expirationDate = self.engine.expirationDate;
            [self.simpleAuth save];
        }
        return YES;
    }
    return NO;
}


//sso回调方法，官方客户端完成sso授权后，回调唤起应用，应用中应调用此方法完成sso登录
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    if([url.absoluteString hasPrefix:@"tencent100343998"]){
        NSRange range = [url.absoluteString rangeOfString:@"source_scheme=mqqapi"];
        if (range.length > 0) {
            // QQ分享
            return [QQApiInterface handleOpenURL:url delegate:self];
        } else {
            // QQ登录
            return [TencentOAuth HandleOpenURL:url];
        }
    }else if([sourceApplication isEqualToString:@"com.tencent.mqq"])
    {
        return [QQApiInterface handleOpenURL:url delegate:self];
    }
    return NO;
}

-(BOOL)isInstalled
{
    return [QQApiInterface isQQInstalled];
}

- (void)skipOAuthFilesicloudBackUp
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *url = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"TCSdkConfig.plist"];
    [NSFileManager addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:url]];

    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    url = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"tencent_analysis.db"];
    [NSFileManager addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:url]];
}

#pragma mark -
#pragma mark TencentSessionDelegate
- (void)tencentDidLogin{
    NSLog(@"[OAuth:Tencent]openId=%@&accesstoken=%@&expirationDate =%@",
          self.engine.openId, self.engine.accessToken, self.engine.expirationDate);
    self.simpleAuth.uid = self.engine.openId;
    self.simpleAuth.accessToken = self.engine.accessToken;
    self.simpleAuth.expirationDate = self.engine.expirationDate;
    [self.simpleAuth save];
    if(self.authorizeBlock){
        self.authorizeBlock(YES, nil);
    }
}
- (void)tencentDidLogout{
    NSLog(@"[OAuth:Tencent]login out");
}

- (void)tencentDidNotLogin:(BOOL)cancelled{
    NSLog(@"[OAuth:Tencent]login cancel:%d",cancelled);
    if(self.authorizeBlock){
        if(cancelled){
            self.authorizeBlock(NO, nil);
        }else{
            NSError *error = [NSError errorWithDomain:@"TencentSDKErrorDomain" code:101 userInfo:@{@"error":@"tencentDidNotLogin"}];
            self.authorizeBlock(NO, error);
        }
    }
}
- (void)tencentDidNotNetWork{
    NSError *error = [NSError errorWithDomain:@"TencentSDKErrorDomain" code:101 userInfo:@{@"error":@"tencentDidNotNetWork"}];
    NSLog(@"[OAuth:SinaWeibo]login fail:%@", error);
    if(self.authorizeBlock){
        self.authorizeBlock(NO, error);
    }
}

#pragma mark - Other Interface
- (void)getUserInfoWithCompletion:(void (^)(id responseObject, NSError *error))completion{
    [self.engine getUserInfo];
}
- (void)shareToQQFriendWithText:(NSString*)text completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    QQApiTextObject* txtObj = [QQApiTextObject objectWithText:text];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}
- (void)shareToQQFriendWithTitle:(NSString*)title image:(UIImage*)image description:(NSString*)description completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    NSData *imageData = UIImageJPEGRepresentation((UIImage *)image,1.0);
    QQApiImageObject* img = [QQApiImageObject objectWithData:imageData previewImageData:imageData title:title description:description];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}
- (void)shareToQQFriendWithTitle:(NSString*)title image:(UIImage*)image description:(NSString*)description newsUrl:(NSString*)newsUrl completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    NSData *imageData = UIImageJPEGRepresentation((UIImage *)image,1.0);
    NSURL* rurl = [NSURL URLWithString:newsUrl];
    QQApiNewsObject* img = [QQApiNewsObject objectWithURL:rurl title:title description:description previewImageData:imageData];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}
- (void)shareToQQFriendWithTitle:(NSString*)title image:(UIImage*)image description:(NSString*)description audioUrl:(NSString*)audioUrl completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    NSData *imageData = UIImageJPEGRepresentation((UIImage *)image,1.0);
    NSURL* rurl = [NSURL URLWithString:audioUrl];
    QQApiAudioObject* img = [QQApiAudioObject objectWithURL:rurl title:title description:description previewImageData:imageData];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}
- (void)shareToQQFriendWithTitle:(NSString*)title image:(UIImage*)image description:(NSString*)description videoUrl:(NSString*)videoUrl completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    NSData *imageData = UIImageJPEGRepresentation((UIImage *)image,1.0);
    NSURL* rurl = [NSURL URLWithString:videoUrl];
    QQApiVideoObject* img = [QQApiVideoObject objectWithURL:rurl title:title description:description previewImageData:imageData];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}
- (void)shareToQzoneWithText:(NSString *)text title:(NSString *)title comment:(NSString *)comment url:(NSString *)url imageUrl:(NSString *)imageUrl completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    TCAddShareDic *params = [TCAddShareDic dictionary];
    params.paramTitle = title;
    params.paramComment = comment;
    params.paramSummary =  text;
    params.paramImages = imageUrl;
    params.paramUrl = url;
    [self.engine addShareWithParams:params];
}


#pragma mark -
#pragma mark TencentSessionDelegate
- (void)getUserInfoResponse:(APIResponse *)response{
    [self skipOAuthFilesicloudBackUp];
    if (response.retCode == URLREQUEST_SUCCEED) {
        NSLog(@"[OAuth:Tencent]getUserInfo success:%@",response.jsonResponse);
        if(self.requestBlock){
            self.requestBlock(response.jsonResponse, nil);
        }
    } else {
        NSLog(@"[OAuth:Tencent]getUserInfo fail:%@",response.errorMsg);
        NSError *error = [NSError errorWithDomain:response.errorMsg code:response.retCode userInfo:nil];
        if(self.requestBlock){
            self.requestBlock(nil, error);
        }
    }
}
- (void)addShareResponse:(APIResponse *)response
{
    [self skipOAuthFilesicloudBackUp];
    if (URLREQUEST_SUCCEED == response.retCode && kOpenSDKErrorSuccess == response.detailRetCode) {
        NSLog(@"[OAuth:Tencent]share qzone success:%@",response.jsonResponse);
        if(self.requestBlock){
            self.requestBlock(response.jsonResponse, nil);
        }
    } else {
        NSLog(@"[OAuth:Tencent]share qzone fail:%@",response.errorMsg);
        NSError *error = [NSError errorWithDomain:response.errorMsg code:response.retCode userInfo:nil];
        if(self.requestBlock){
            self.requestBlock(nil, error);
        }
    }
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult{
    NSString* retString = nil;
    switch (sendResult){
        case EQQAPIAPPNOTREGISTED:
            retString = @"App未注册";
            break;
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
            retString = @"发送参数错误";
            break;
        case EQQAPIQQNOTINSTALLED:
            retString = @"未安装手Q";
            break;
        case EQQAPIQQNOTSUPPORTAPI:
            retString = @"API接口不支持";
            break;
        case EQQAPISENDFAILD:
            retString = @"发送失败";
            break;
        default:
            break;
    }
    [self skipOAuthFilesicloudBackUp];
    if(retString.length>0){
        if(self.requestBlock){
            NSError *error = [NSError errorWithDomain:@"Tecent" code:sendResult userInfo:@{@"error":retString}];
            self.requestBlock(nil, error);
        }
    }
}

- (void)onReq:(QQBaseReq *)req{
}
- (void)onResp:(QQBaseResp *)resp{
    NSLog(@"[OAuth:Tencent]request response:%@", resp);
    [self skipOAuthFilesicloudBackUp];
    switch (resp.type){
        case ESENDMESSAGETOQQRESPTYPE:{//手Q应答处理分享消息的结果
            SendMessageToQQResp* sendResp = (SendMessageToQQResp*)resp;
            if([sendResp.result isEqualToString:@"0"]){
                if(self.requestBlock){
                    self.requestBlock(sendResp, nil);
                }
            }
            else{
                NSError *error = [NSError errorWithDomain:sendResp.errorDescription code:[resp.result integerValue] userInfo:nil];
                if(self.requestBlock){
                    self.requestBlock(nil, error);
                }
            }
            break;
        }
        default:
            break;
    }
}

@end
