//
//  NetAPIClient.h
//  Yumi
//
//  Created by Mao on 15/2/1.
//  Copyright (c) 2015年 Mao. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface NetAPIClient : AFHTTPSessionManager

+ (instancetype)sharedWithBaseURL:(NSString *)baseURL;

@property (nonatomic, strong)   NSDictionary    *apiBaseParams;

@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

- (BOOL)shouldCacheWithUrl:(NSString *)url params:parameters data:(NSString *)data;


@end
