//
//  SimpleAuthSinaWeiboProvider.m
//  ObjcKit
//
//  Created by Wei Mao on 9/3/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "SimpleAuthSinaWeiboProvider.h"
#import "WeiboSDK.h"
#import "JSONKit.h"

@interface SimpleAuthSinaWeiboProvider()<WeiboSDKDelegate, WBHttpRequestDelegate>

@property (nonatomic, copy, readonly)   NSString*           baseURL;
@property (nonatomic, copy)             NSString*           redirectURI;
@property (nonatomic, copy)             void (^authorizeBlock)(BOOL, NSError *);
@property (nonatomic, copy)             void (^requestBlock)(id, NSError *);

@end


static SimpleAuthSinaWeiboProvider *shared_ = nil;

@implementation SimpleAuthSinaWeiboProvider

+ (NSString *)type {
    return @"sinaweibo";
}
+ (SimpleAuthSinaWeiboProvider *)shared{
    return shared_;
}
-(NSString *)baseURL{
    return @"https://api.weibo.com/2/";
}

- (instancetype)initWithOptions:(NSDictionary *)options {
    if ((self = [super initWithOptions:options])) {
        NSArray *keys = [options allKeys];
        if(![keys containsObject:SimpleAuthAppKey]||
           ![keys containsObject:SimpleAuthRedirectURI])
            return nil;
        self.options = options;
        [WeiboSDK registerApp:options[SimpleAuthAppKey]];
        self.redirectURI = options[SimpleAuthRedirectURI];
        self.scope = @"all";
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
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = self.redirectURI;
    request.scope = self.scope;
    [WeiboSDK sendRequest:request];
}
-(void)unAuthorize{
    [WeiboSDK logOutWithToken:self.simpleAuth.accessToken delegate:self withTag:@""];
    [self.simpleAuth clear];
}
-(BOOL)isAuthorized{
    if(self.simpleAuth.uid.length > 0 && self.simpleAuth.accessToken.length > 0 && self.simpleAuth.expirationDate){
        NSDate *now = [NSDate date];
        if([now compare:self.simpleAuth.expirationDate] == NSOrderedDescending){
            return NO;
        }
        return YES;
    }
    return NO;
}

//sso回调方法，官方客户端完成sso授权后，回调唤起应用，应用中应调用此方法完成sso登录
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    if ([sourceApplication isEqualToString:@"com.sina.weibo"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    return NO;
}

-(BOOL)isInstalled
{
    return [WeiboSDK isWeiboAppInstalled];
}

#pragma mark -
#pragma mark SinaWeiboDelegate
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]){
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            NSLog(@"[OAuth:SinaWeibo]request success");
            if(self.requestBlock){
                self.requestBlock(response, nil);
            }
        }else{
            NSError *error = [NSError errorWithDomain:@"SinaWeibo" code:response.statusCode userInfo:response.userInfo];
            NSLog(@"[OAuth:SinaWeibo]request failed:%@",error);
            if(self.requestBlock){
                self.requestBlock(nil, error);
            }
        }
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class]){
        WBAuthorizeResponse *authResponse = (WBAuthorizeResponse *)response;
        NSLog(@"[OAuth:SinaWeibo]userID=%@&accesstoken=%@&expirationDate =%@",
              authResponse.userID, authResponse.accessToken, authResponse.expirationDate);
        if (authResponse.accessToken.length>0) {
            self.simpleAuth.uid = authResponse.userID;
            self.simpleAuth.accessToken = authResponse.accessToken;
            self.simpleAuth.expirationDate = authResponse.expirationDate;
            [self.simpleAuth save];
            if(self.authorizeBlock){
                self.authorizeBlock(YES, nil);
            }
        }else{
            NSError *error = [NSError errorWithDomain:@"SinaWeibo" code:response.statusCode userInfo:response.userInfo];
            NSLog(@"[OAuth:SinaWeibo]login fail:%@", error);
            if(self.authorizeBlock){
                self.authorizeBlock(NO, error);
            }
        }
    }
}

#pragma mark -
#pragma mark SinaWeiboRequestDelegate
- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result{
    id json = [result objectFromJSONString];
    if (json[@"error_code"]) {
        NSError *error = [NSError errorWithDomain:@"SinaWeibo" code:[json[@"error_code"] intValue] userInfo:json];
        NSLog(@"[OAuth:SinaWeibo]request failed:%@",error);
        if(self.requestBlock){
            self.requestBlock(nil, error);
        }
    }else{
        NSLog(@"[OAuth:SinaWeibo]request success");
        if(self.requestBlock){
            self.requestBlock(json, nil);
        }
    }
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error;{
    NSLog(@"[OAuth:SinaWeibo]request failed:%@",error);
    if(self.requestBlock){
        self.requestBlock(nil, error);
    }
}

#pragma mark - Other Interface
- (void)getUserInfoWithCompletion:(void (^)(id responseObject, NSError *error))completion{
    [self getUserInfoByUID:self.simpleAuth.uid completion:completion];
}
- (void)getUserInfoByUID:(NSString*)uid completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:uid, @"uid", nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"users/show.json"] httpMethod:@"GET" params:params delegate:self withTag:nil];
}
- (void)getUserInfoByName:(NSString *)name completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"screen_name", nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"users/show.json"] httpMethod:@"GET" params:params delegate:self withTag:nil];
}
-(void)getUserCountsByUIDs:(NSString *)uids completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:uids, @"uids", nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"users/counts.json"] httpMethod:@"GET" params:params delegate:self withTag:nil];
}

//微博
- (void)shareWithText:(NSString *)text completion:(void (^)(id responseObject, NSError *error))completion{
    if ([WeiboSDK isWeiboAppInstalled]){
        self.requestBlock = completion;
        WBMessageObject *message = [WBMessageObject message];
        message.text = text;
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
        [WeiboSDK sendRequest:request];
    }else{
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:text, @"status",nil];
        [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"statuses/update.json"] httpMethod:@"POST" params:params delegate:self withTag:nil];
    }
}
- (void)shareWithText:(NSString *)text imageUrl:(NSString *)imageUrl completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    WBMessageObject *message = [WBMessageObject message];
    message.text = text;
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:text, @"status", imageUrl, @"url",nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"statuses/upload_url_text.json"] httpMethod:@"POST" params:params delegate:self withTag:nil];
}
- (void)shareWithText:(NSString *)text image:(UIImage *)image completion:(void (^)(id responseObject, NSError *error))completion{
    if ([WeiboSDK isWeiboAppInstalled]){
        self.requestBlock = completion;
        WBMessageObject *message = [WBMessageObject message];
        message.text = text;
        WBImageObject *imageObj = [WBImageObject object];
        imageObj.imageData = UIImagePNGRepresentation(image);
        message.imageObject = imageObj;
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
        [WeiboSDK sendRequest:request];
    }else{
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:text, @"status",UIImagePNGRepresentation(image), @"pic", nil];
        [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"statuses/upload.json"] httpMethod:@"POST" params:params delegate:self withTag:nil];
    }
}
-(void)shareWithText:(NSString *)text title:(NSString *)title description:(NSString *)description image:(UIImage *)image webUrl:(NSString *)webUrl completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    WBMessageObject *message = [WBMessageObject message];
    message.text = text;
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = [NSString stringWithFormat:@"%d", (int)[NSDate date].timeIntervalSince1970];
    webpage.title = title;
    webpage.description = description;
    webpage.thumbnailData = UIImagePNGRepresentation(image);
    webpage.webpageUrl = webUrl;
    message.mediaObject = webpage;
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
}
-(void)shareWithText:(NSString *)text title:(NSString *)title description:(NSString *)description image:(UIImage *)image musicUrl:(NSString *)musicUrl musicStreamUrl:(NSString *)musicStreamUrl musicLowBandUrl:(NSString *)musicLowBandUrl musicLowBandStreamUrl:(NSString *)musicLowBandStreamUrl completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    WBMessageObject *message = [WBMessageObject message];
    message.text = text;
    WBMusicObject *webpage = [WBMusicObject object];
    webpage.objectID = [NSString stringWithFormat:@"%d", (int)[NSDate date].timeIntervalSince1970];
    webpage.title = title;
    webpage.description = description;
    webpage.thumbnailData = UIImagePNGRepresentation(image);
    webpage.musicUrl = musicUrl;
    webpage.musicStreamUrl = musicStreamUrl;
    webpage.musicLowBandUrl = musicLowBandUrl;
    webpage.musicLowBandStreamUrl = musicLowBandStreamUrl;
    message.mediaObject = webpage;
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
}
-(void)shareWithText:(NSString *)text title:(NSString *)title description:(NSString *)description image:(UIImage *)image videoUrl:(NSString *)videoUrl videoStreamUrl:(NSString *)videoStreamUrl videoLowBandUrl:(NSString *)videoLowBandUrl videoLowBandStreamUrl:(NSString *)videoLowBandStreamUrl completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    WBMessageObject *message = [WBMessageObject message];
    message.text = text;
    WBVideoObject *webpage = [WBVideoObject object];
    webpage.objectID = [NSString stringWithFormat:@"%d", (int)[NSDate date].timeIntervalSince1970];
    webpage.title = title;
    webpage.description = description;
    webpage.thumbnailData = UIImagePNGRepresentation(image);
    webpage.videoUrl = videoUrl;
    webpage.videoStreamUrl = videoStreamUrl;
    webpage.videoLowBandUrl = videoLowBandUrl;
    webpage.videoLowBandStreamUrl = videoLowBandStreamUrl;
    message.mediaObject = webpage;
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
}
-(void)getPublicStatusesWithCount:(int)count completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",count], @"count",nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"statuses/public_timeline.json"] httpMethod:@"GET" params:params delegate:self withTag:nil];
}
-(void)getFriendsStatusesWithCount:(int)count page:(int)page completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",count], @"count",[NSString stringWithFormat:@"%d",page], @"page",nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"statuses/friends_timeline.json"] httpMethod:@"GET" params:params delegate:self withTag:nil];
}
-(void)getStatusByID:(long long)statusID completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lld",statusID], @"id",nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"statuses/show.json"] httpMethod:@"GET" params:params delegate:self withTag:nil];
}
-(void)delStatusByID:(long long)statusID completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lld",statusID], @"id",nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"statuses/destroy.json"] httpMethod:@"POST" params:params delegate:self withTag:nil];
}

//评论
-(void)getCommentsByStatusID:(long long)statusID count:(int)count page:(int)page completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lld",statusID], @"id",[NSString stringWithFormat:@"%d",count], @"count",[NSString stringWithFormat:@"%d",page], @"page",nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"comments/show.json"] httpMethod:@"GET" params:params delegate:self withTag:nil];
}
-(void)getMyCommentsWithCount:(int)count page:(int)page completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",count], @"count",[NSString stringWithFormat:@"%d",page], @"page",nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"comments/by_me.json"] httpMethod:@"GET" params:params delegate:self withTag:nil];
}
-(void)getCommentsToMeWithCount:(int)count page:(int)page completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",count], @"count",[NSString stringWithFormat:@"%d",page], @"page",nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"comments/to_me.json"] httpMethod:@"GET" params:params delegate:self withTag:nil];
}
-(void)getCommentsMetionMeWithCount:(int)count page:(int)page completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",count], @"count",[NSString stringWithFormat:@"%d",page], @"page",nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"comments/mentions.json"] httpMethod:@"GET" params:params delegate:self withTag:nil];
}
-(void)commentWithStatusID:(long long)statusID text:(NSString *)text completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lld",statusID], @"id",text, @"comment",nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"comments/create.json"] httpMethod:@"POST" params:params delegate:self withTag:nil];
}
-(void)delCommentByID:(long long)commentID completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lld",commentID], @"cid",nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"comments/destroy.json"] httpMethod:@"POST" params:params delegate:self withTag:nil];
}
-(void)replyCommentByStatusID:(long long)statusID commentID:(long long)commentID text:(NSString *)text completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lld",statusID], @"id",[NSString stringWithFormat:@"%lld",commentID], @"cid",text, @"comment",nil];
    [WBHttpRequest requestWithAccessToken:self.simpleAuth.accessToken url:[self.baseURL stringByAppendingString:@"comments/destroy.json"] httpMethod:@"POST" params:params delegate:self withTag:nil];
}


@end
