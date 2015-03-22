//
//  NetAPIData.h
//  Yumi
//
//  Created by Mao on 15/2/1.
//  Copyright (c) 2015年 Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetAPIClient.h"

@interface NetAPIData : NSObject
//Response

+ (id)jsonToObj:(id)json;
+ (void)fillJson:(id)json inObject:(id)obj;

//Request

@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
+ (instancetype)initWithClient:(NetAPIClient *)client query:(NSDictionary *)query mehod:(NSString *)method url:(NSString *)url;
- (NSURLSessionDataTask *)requestWithSuccess:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (NSURLSessionUploadTask *)uploadWithProgress:(NSProgress *)progress bodyBlock:(void (^)(id <AFMultipartFormData> formData))bodyBlock success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;


@end
