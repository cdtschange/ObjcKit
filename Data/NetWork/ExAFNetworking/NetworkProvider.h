//
//  NetworkProvider.h
//  exAFNetworking
//
//  Created by Wei Mao on 8/27/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExAFNetworking.h"

@interface NetworkProvider : NSObject

@property(nonatomic, copy)      NSString        *baseURL;
@property(nonatomic, strong)    NSDictionary    *baseParams;

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
@end
