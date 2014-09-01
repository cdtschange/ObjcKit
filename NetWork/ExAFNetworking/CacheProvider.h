//
//  CacheProvider.h
//  exAFNetworking
//
//  Created by Wei Mao on 8/28/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheProvider : NSObject

@property (nonatomic, copy)     NSString    *path;
@property (nonatomic, assign)   float       cacheMaxSize;//Byte

+ (CacheProvider *)shared;

- (BOOL)hasKey:(NSString *)key;
- (BOOL)isExpiredByKey:(NSString *)key;
- (NSString *)cacheByKey:(NSString *)key;
- (int)cacheTimeByKey:(NSString *)key;
- (BOOL)setCacheByKey:(NSString *)key value:(NSString *)value valideTime:(int)valideTime;
- (void)clear;
@end
