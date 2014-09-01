//
//  NetworkProvider.h
//  exAFNetworking
//
//  Created by Wei Mao on 8/27/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AFHTTPClient.h"
#import "ExAFHttpRequest.h"
#import "ExAFXMLRequest.h"
#import "ExAFJSONRequest.h"

@interface NetworkProvider : NSObject

// 发起网络请求
// 结束网络请求
// 网络请求失败
typedef enum NetworkProviderStatus {
    NetworkProviderStatusBegin          =               1,  // 网络开始请求
    NetworkProviderStatusEnd            =               2,  // 网络结束请求
    NetworkProviderStatusFailed         =               3,  // 网络失败
}NetworkProviderStatus;

@property (nonatomic, assign)   AFNetworkReachabilityStatus reachabilityStatus;
@property (nonatomic, copy)     void (^reachbilityBlock)(AFNetworkReachabilityStatus status);
@property (nonatomic, copy)     void (^statusBlock)(NetworkProviderStatus status, NSError *error);
@property (nonatomic, copy)     NSString        *baseURL;
@property (nonatomic, strong)   NSDictionary    *baseParams;

-(void)requestWithPath:(NSString *)path params:(NSDictionary *)params method:(ExAFNetworkHttpMethod)method
               success:(void (^)(id responseObject))success
               failure:(void (^)(NSError *error))failure;
-(void)requestXMLWithPath:(NSString *)path params:(NSDictionary *)params method:(ExAFNetworkHttpMethod)method
                   success:(void (^)(id responseObject))success
                  failure:(void (^)(NSError *error))failure;
-(void)requestJSONWithPath:(NSString *)path params:(NSDictionary *)params method:(ExAFNetworkHttpMethod)method
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure;

-(NSString *)getFullURLWithPath:(NSString *)path params:(NSDictionary *)params method:(ExAFNetworkHttpMethod)method;

+(void)clearCookies;

@end


@protocol NetworkProviderProtocal <NSObject>

-(void)requestWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;
-(void)setCompletionBlockWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;
-(void)requestData;

@end
