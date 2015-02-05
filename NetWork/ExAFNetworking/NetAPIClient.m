//
//  NetAPIClient.m
//  Yumi
//
//  Created by Mao on 15/2/1.
//  Copyright (c) 2015年 Mao. All rights reserved.
//

#import "NetAPIClient.h"
#import "CacheProvider.h"
#import "JSONKit.h"

#define NETAPI_CACHE_TIME                  24*60*60 //默认缓存时间1天

@implementation NetAPIClient

+ (instancetype)sharedWithBaseURL:(NSString *)baseURL {
    static NetAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[[self class] alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    });
    return _sharedClient;
}
-(instancetype)initWithBaseURL:(NSURL *)url{
    if (self = [super initWithBaseURL:url]) {
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    }
    return self;
}
-(void)setCachePolicy:(NSURLRequestCachePolicy)cachePolicy{
    self.requestSerializer.cachePolicy = cachePolicy;
    _cachePolicy = cachePolicy;
}
-(NSDictionary *)fillParamsWithBaseParam:(NSDictionary *)params{
    NSMutableDictionary *mparams = [NSMutableDictionary dictionaryWithDictionary:params];
    for (NSString *key in [self.apiBaseParams allKeys]) {
        if (![mparams objectForKey:key]) {
            [mparams setObject:self.apiBaseParams[key] forKey:key];
        }
    }
    return mparams;
}

-(BOOL)shouldCacheWithUrl:(NSString *)url params:(id)parameters data:(NSString *)data{
    return YES;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure{
    parameters = [self fillParamsWithBaseParam:parameters];
    if (self.cachePolicy==NSURLRequestReturnCacheDataElseLoad||self.cachePolicy==NSURLRequestReturnCacheDataDontLoad) {
        id cacheData = [self getCacheWithUrl:URLString params:parameters];
        if (cacheData) {
            if (success) {
                success(nil, cacheData);
                return nil;
            }
        }
    }
    int cachePolicy = self.cachePolicy;
    __weak NetAPIClient *weakself = self;
    return [super dataTaskWithHTTPMethod:method URLString:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
        id cacheData = [weakself getCacheWithUrl:URLString params:parameters];
        if (cachePolicy==NSURLRequestReturnCacheDataElseLoad||cachePolicy==NSURLRequestReturnCacheDataDontLoad||cacheData) {
            NSString *fullUrl = [weakself getFullPathWithUrl:URLString params:parameters];
            CacheProvider *cp = [CacheProvider shared];
            NSString *data = [responseObject JSONString];
            if ([weakself shouldCacheWithUrl:URLString params:parameters data:data]) {
                [cp setCacheByKey:fullUrl value:data valideTime:NETAPI_CACHE_TIME];
                NSLog(@"Url data Cached success");
            }
        }
        if (success) {
            success(task, responseObject);
        }
    } failure:failure];
}

-(NSString *)getFullPathWithUrl:(NSString *)url params:(NSDictionary *)params{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString] parameters:params error:nil];
    NSString *fullUrl = [NSString stringWithFormat:@"%@", request.URL];
    return fullUrl;
}
-(id)getCacheWithUrl:(NSString *)url params:(NSDictionary *)params{
        CacheProvider *cp = [CacheProvider shared];
        NSString *fullUrl = [self getFullPathWithUrl:url params:params];
        if ([cp hasKey:fullUrl]) {
            NSString *value = [cp cacheByKey:fullUrl];
            id obj = [value objectFromJSONString];
            NSLog(@"Return Url Cached data");
            return obj;
        }
    return nil;
}

@end
