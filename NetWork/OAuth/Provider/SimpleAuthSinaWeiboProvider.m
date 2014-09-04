//
//  SimpleAuthSinaWeiboProvider.m
//  ObjcKit
//
//  Created by Wei Mao on 9/3/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "SimpleAuthSinaWeiboProvider.h"
#import "SinaWeibo.h"
#import "SinaWeiboRequest.h"

@interface SimpleAuthSinaWeiboProvider()<SinaWeiboDelegate, SinaWeiboRequestDelegate>

@property (nonatomic, strong)       SinaWeibo           *engine;
@property (nonatomic, copy)         void (^authorizeBlock)(BOOL, NSError *);
@property (nonatomic, copy)         void (^requestBlock)(id, NSError *);

@end


static SimpleAuthSinaWeiboProvider *shared_ = nil;

@implementation SimpleAuthSinaWeiboProvider

+ (NSString *)type {
    return @"sinaweibo";
}
+ (SimpleAuthSinaWeiboProvider *)shared{
    return shared_;
}

- (instancetype)initWithOptions:(NSDictionary *)options {
    if ((self = [super init])) {
        NSArray *keys = [options allKeys];
        if(![keys containsObject:SimpleAuthAppKey]||
           ![keys containsObject:SimpleAuthAppSecret]||
           ![keys containsObject:SimpleAuthRedirectURI]||
           ![keys containsObject:SimpleAuthSSOCallbackScheme])
            return nil;
        self.options = options;
        self.engine = [[SinaWeibo alloc] initWithAppKey:options[SimpleAuthAppKey]
                                              appSecret:options[SimpleAuthAppSecret]
                                         appRedirectURI:options[SimpleAuthRedirectURI]
                                      ssoCallbackScheme:options[SimpleAuthSSOCallbackScheme]
                                            andDelegate:self];
        self.engine.delegate = self;
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
    [self.engine logIn];
}
-(void)unAuthorize{
    [self.engine logOut];
    [self.simpleAuth clear];
}
-(BOOL)isAuthorized{
    if([self.engine isLoggedIn]){
        if([self.engine isAuthorizeExpired]){
            return NO;
        }
        if(self.simpleAuth.uid.length==0){
            self.simpleAuth.uid = self.engine.userID;
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
    if ([sourceApplication isEqualToString:@"com.sina.weibo"]) {
        return [self.engine handleOpenURL:url];
    }
    return NO;
}

#pragma mark -
#pragma mark SinaWeiboDelegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo{
    NSLog(@"[OAuth:SinaWeibo]userID=%@&accesstoken=%@&expirationDate =%@",
          sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate);
    self.simpleAuth.uid = self.engine.userID;
    self.simpleAuth.accessToken = self.engine.accessToken;
    self.simpleAuth.expirationDate = self.engine.expirationDate;
    [self.simpleAuth save];
    if(self.authorizeBlock){
        self.authorizeBlock(YES, nil);
    }
}
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo{
    NSLog(@"[OAuth:SinaWeibo]login out");
}
- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo{
    NSLog(@"[OAuth:SinaWeibo]login cancel");
    if(self.authorizeBlock){
        self.authorizeBlock(NO, nil);
    }
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error{
    NSLog(@"[OAuth:SinaWeibo]login fail:%@", error);
    if(self.authorizeBlock){
        self.authorizeBlock(NO, error);
    }
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error{
    NSLog(@"[OAuth:SinaWeibo]login fail with access token expired:%@", error);
    if(self.authorizeBlock){
        self.authorizeBlock(NO, error);
    }
}

#pragma mark -
#pragma mark SinaWeiboRequestDelegate
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"[OAuth:SinaWeibo]request failed:%@",error);
    if(self.requestBlock){
        self.requestBlock(nil, error);
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"statuses/update.json"]){
        if ([result objectForKey:@"error_code"]){
            NSLog(@"[OAuth:SinaWeibo]request failed:%@",result);
            if(self.requestBlock){
                NSError *error = [NSError errorWithDomain:@"SinaWeibo" code:[result[@"error_code"] intValue] userInfo:result];
                self.requestBlock(nil, error);
            }
        }
        else{
            NSLog(@"[OAuth:SinaWeibo]request success:%@", result);
            if(self.requestBlock){
                self.requestBlock(result, nil);
            }
        }
        return;
    }
    NSLog(@"[OAuth:SinaWeibo]request success:%@", result);
    if(self.requestBlock){
        self.requestBlock(result, nil);
    }
}

#pragma mark - Other Interface
- (void)getUserInfoWithCompletion:(void (^)(id responseObject, NSError *error))completion{
    [self getUserInfoByUID:self.engine.userID completion:completion];
}
- (void)getUserInfoByUID:(NSString*)uid completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:uid, @"uid", nil];
    [self.engine requestWithURL:@"users/show.json" params:params httpMethod:@"GET" delegate:self];
}
- (void)getUserInfoByName:(NSString *)name completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"screen_name", nil];
    [self.engine requestWithURL:@"users/show.json" params:params httpMethod:@"GET" delegate:self];
}
-(void)getUserCountsByUIDs:(NSString *)uids completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:uids, @"uids", nil];
    [self.engine requestWithURL:@"users/counts.json" params:params httpMethod:@"GET" delegate:self];
}

//微博
- (void)shareWithText:(NSString *)text completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:text, @"status", nil];
    [self.engine requestWithURL:@"users/update.json" params:params httpMethod:@"POST" delegate:self];
}
- (void)shareWithText:(NSString *)text imageUrl:(NSString *)imageUrl completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:text, @"status", imageUrl, @"url",nil];
    [self.engine requestWithURL:@"statuses/upload_url_text.json" params:params httpMethod:@"POST" delegate:self];
}
- (void)shareWithText:(NSString *)text image:(UIImage *)image completion:(void (^)(id responseObject, NSError *error))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:text, @"status", image, @"pic",nil];
    [self.engine requestWithURL:@"statuses/upload.json" params:params httpMethod:@"POST" delegate:self];
}
-(void)getPublicStatusesWithCount:(int)count completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(count), @"count",nil];
    [self.engine requestWithURL:@"statuses/public_timeline.json" params:params httpMethod:@"GET" delegate:self];
}
-(void)getFriendsStatusesWithCount:(int)count page:(int)page completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(count), @"count",@(page), @"page",nil];
    [self.engine requestWithURL:@"statuses/friends_timeline.json" params:params httpMethod:@"GET" delegate:self];
}
-(void)getStatusByID:(int)statusID completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(statusID), @"id",nil];
    [self.engine requestWithURL:@"statuses/show.json" params:params httpMethod:@"GET" delegate:self];
}
-(void)delStatusByID:(int)statusID completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(statusID), @"id",nil];
    [self.engine requestWithURL:@"statuses/destroy.json" params:params httpMethod:@"POST" delegate:self];
}

//评论
-(void)getCommentsByStatusID:(int)statusID count:(int)count page:(int)page completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(statusID), @"id",@(count), @"count",@(page), @"page",nil];
    [self.engine requestWithURL:@"comments/show.json" params:params httpMethod:@"GET" delegate:self];
}
-(void)getMyCommentsWithCount:(int)count page:(int)page completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(count), @"count",@(page), @"page",nil];
    [self.engine requestWithURL:@"comments/by_me.json" params:params httpMethod:@"GET" delegate:self];
}
-(void)getCommentsToMeWithCount:(int)count page:(int)page completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(count), @"count",@(page), @"page",nil];
    [self.engine requestWithURL:@"comments/to_me.json" params:params httpMethod:@"GET" delegate:self];
}
-(void)getCommentsMetionMeWithCount:(int)count page:(int)page completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(count), @"count",@(page), @"page",nil];
    [self.engine requestWithURL:@"comments/mentions.json" params:params httpMethod:@"GET" delegate:self];
}
-(void)commentWithStatusID:(int)statusID text:(NSString *)text completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(statusID), @"id",text, @"comment",nil];
    [self.engine requestWithURL:@"comments/create.json" params:params httpMethod:@"POST" delegate:self];
}
-(void)delCommentByID:(int)commentID completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(commentID), @"cid",nil];
    [self.engine requestWithURL:@"comments/destroy.json" params:params httpMethod:@"POST" delegate:self];
}
-(void)replyCommentByStatusID:(int)statusID commentID:(int)commentID text:(NSString *)text completion:(void (^)(id, NSError *))completion{
    self.requestBlock = completion;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(statusID), @"id",@(commentID), @"cid",text, @"comment",nil];
    [self.engine requestWithURL:@"comments/destroy.json" params:params httpMethod:@"POST" delegate:self];
}


@end
