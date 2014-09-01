//
//  NetworkProvider.m
//  exAFNetworking
//
//  Created by Wei Mao on 8/27/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "NetworkProvider.h"
#define REACHABILITY_URL @"http://www.baidu.com"

@interface NetworkProvider()

@property(nonatomic, strong)    ExAFHttpRequest     *request;
@property(nonatomic, strong)    NSMutableArray      *requestArray;

@end

@implementation NetworkProvider

-(id)init{
    if (self = [super init]) {
        self.requestArray = [NSMutableArray new];
        self.request = [[ExAFHttpRequest alloc] init];
        self.request.baseURL = REACHABILITY_URL;
        __weak NetworkProvider *weakself = self;
        [self.request.client setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            weakself.reachabilityStatus = status;
            if(weakself.reachbilityBlock){
                weakself.reachbilityBlock(status);
            }
        }];
    }
    return self;
}
-(void)setRequest:(ExAFHttpRequest *)request{
    [self.requestArray addObject:request];
    _request = request;
}

-(void)requestWithPath:(NSString *)path params:(NSDictionary *)params method:(ExAFNetworkHttpMethod)method success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    self.request = [[ExAFHttpRequest alloc] init];
    [self exRequest:self.request path:path params:params method:method success:success failure:failure];
}
-(void)requestXMLWithPath:(NSString *)path params:(NSDictionary *)params method:(ExAFNetworkHttpMethod)method success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    self.request = [[ExAFXMLRequest alloc] init];
    [self exRequest:self.request path:path params:params method:method success:success failure:failure];
}
-(void)requestJSONWithPath:(NSString *)path params:(NSDictionary *)params method:(ExAFNetworkHttpMethod)method success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    self.request = [[ExAFJSONRequest alloc] init];
    [self exRequest:self.request path:path params:params method:method success:success failure:failure];
}

-(void)exRequest:(ExAFHttpRequest *)request path:(NSString *)path params:(NSDictionary *)params method:(ExAFNetworkHttpMethod)method success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    request.baseURL = self.baseURL;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.baseParams];
    for (NSString *key in params) {
        [dict setObject:params[key] forKey:key];
    }
    if (self.statusBlock) {
        self.statusBlock(NetworkProviderStatusBegin,nil);
    }
    __weak NetworkProvider *weakself = self;
    [request requestWithMethod:method path:path param:dict success:^(NSHTTPURLResponse *response, id responseObject) {
        if (success) {
            success(responseObject);
        }
        if (weakself.statusBlock) {
            weakself.statusBlock(NetworkProviderStatusEnd,nil);
        }
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        if (failure) {
            failure(error);
        }
        if (weakself.statusBlock) {
            weakself.statusBlock(NetworkProviderStatusFailed,error);
        }
    }];
}

-(NSString *)getFullURLWithPath:(NSString *)path params:(NSDictionary *)params method:(ExAFNetworkHttpMethod)method{
    ExAFHttpRequest *request = [[ExAFHttpRequest alloc] init];
    request.baseURL = self.baseURL;
    NSString *methodStr = [request enumExAFNetworkHttpMethodToString:method];
    NSString *pathEncode = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [request.client requestWithMethod:methodStr path:pathEncode parameters:params];
    return [NSString stringWithFormat:@"%@", req.URL];
}

+(void)clearCookies{
    [ExAFHttpRequest clearCookies];
}

@end
