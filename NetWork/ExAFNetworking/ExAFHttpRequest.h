//
//  ExAFHttpClient.h
//  exAFNetworking
//
//  Created by Wei Mao on 8/27/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef enum {
    ExAFNetworkHttpMethodGet            = 0,
    ExAFNetworkHttpMethodPost           = 1,
    ExAFNetworkHttpMethodPut            = 2,
    ExAFNetworkHttpMethodDelete         = 3,
} ExAFNetworkHttpMethod;

@interface ExAFHttpRequest : NSObject


@property (readwrite, nonatomic, strong) AFHTTPClient   *client;
@property (nonatomic, copy)     NSString                *baseURL;
@property (nonatomic, strong)   NSDictionary            *header;
@property (nonatomic, strong)   NSMutableArray          *cookies;
@property (nonatomic, assign)   NSTimeInterval          timeout;

-(void)requestWithMethod:(ExAFNetworkHttpMethod) httpMethod path:(NSString *)path param:(NSDictionary *)param
                 success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                 failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure;

-(void)willRequest:(NSMutableURLRequest *)request;
-(void)didGetResponse:(NSHTTPURLResponse *)response;

-(NSString *)enumExAFNetworkHttpMethodToString:(ExAFNetworkHttpMethod)method;

+(void)clearCookies;
@end
