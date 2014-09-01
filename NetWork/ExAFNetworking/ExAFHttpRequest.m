//
//  ExAFHttpClient.m
//  exAFNetworking
//
//  Created by Wei Mao on 8/27/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "ExAFHttpRequest.h"

#define SESSION_COOKIES_KEY @"exAFNetwork_sessionCookies"

@interface ExAFHttpRequest()

@end

@implementation ExAFHttpRequest

-(AFHTTPClient *)client{
    if (!_client) {
        NSString *urlEncode = [self.baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:urlEncode]];
    }
    return _client;
}
-(void)setBaseURL:(NSString *)baseURL{
    if (![_baseURL isEqualToString:baseURL]) {
        NSString *urlEncode = [baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:urlEncode]];
    }
    _baseURL = baseURL;
}

-(void)setHeader:(NSDictionary *)header{
    _header = header;
    NSArray *keys = [header allKeys];
    for (NSString *key in keys) {
        [self.client setDefaultHeader:key value:[header objectForKey:key]];
    }
}
-(NSTimeInterval)timeout{
    if (_timeout<=5) {
        return 60;
    }
    return _timeout;
}

-(void)willRequest:(NSMutableURLRequest *)request{
    NSLog(@"%@",request.URL);
    NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:SESSION_COOKIES_KEY];
    if([cookiesData length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        [request setAllHTTPHeaderFields:cookieHeaders];
    }
}
-(void)didGetResponse:(NSHTTPURLResponse *)response{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:response.URL];
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: cookies];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: SESSION_COOKIES_KEY];
    [defaults synchronize];
}

-(void)requestWithMethod:(ExAFNetworkHttpMethod)httpMethod path:(NSString *)path param:(NSDictionary *)param success:(void (^)(NSHTTPURLResponse *, id))success failure:(void (^)(NSHTTPURLResponse *, NSError *))failure{
    NSString *methodStr = [self enumExAFNetworkHttpMethodToString:httpMethod];
    NSString *pathEncode = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [self.client requestWithMethod:methodStr path:pathEncode parameters:param];
    request.timeoutInterval = self.timeout;
    [self willRequest:request];
    __weak ExAFHttpRequest *weakself = self;
    AFHTTPRequestOperation *operation = [self.client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success){
            [weakself didGetResponse:operation.response];
            success(operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation.response, error);
        }
    }];
    [operation start];
}

-(NSString *)enumExAFNetworkHttpMethodToString:(ExAFNetworkHttpMethod)method{
    NSString *methodStr;
    switch (method) {
        case ExAFNetworkHttpMethodGet:      methodStr = @"GET";     break;
        case ExAFNetworkHttpMethodPost:     methodStr = @"POST";    break;
        case ExAFNetworkHttpMethodPut:      methodStr = @"PUT";     break;
        case ExAFNetworkHttpMethodDelete:   methodStr = @"DELETE";  break;
        default:                            methodStr = @"GET";     break;
    }
    return methodStr;
}

+(void)clearCookies{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey: SESSION_COOKIES_KEY];
    [defaults synchronize];
}
@end
