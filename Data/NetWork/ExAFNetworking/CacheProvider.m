//
//  CacheProvider.m
//  exAFNetworking
//
//  Created by Wei Mao on 8/28/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "CacheProvider.h"
#import <CommonCrypto/CommonDigest.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#define DEFAULT_CACHEPROVIDER_SIZE                  30*1024*1024 //缓存默认空间：30M
#define DEFAULT_CACHEPROVIDER_FOLDER_NAME           @"cacheprovider_db"
#define DEFAULT_CACHEPROVIDER_FIELD_CACHETIME       @"cachetime"
#define DEFAULT_CACHEPROVIDER_FIELD_EXPIRETIME      @"expiretime"
#define DEFAULT_CACHEPROVIDER_FIELD_DATA            @"data"

@interface CacheProvider (){
    int curSize;
}
@end

@implementation CacheProvider


CacheProvider * _sharedCacheProvider = nil;

+(CacheProvider *)shared
{
    @synchronized(self) {
        if(_sharedCacheProvider == nil) {
            _sharedCacheProvider = [[self alloc] init];
        }
    }
    return _sharedCacheProvider;
}

-(id)init{
    if (self= [super init]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        self.path = [docDir stringByAppendingPathComponent:DEFAULT_CACHEPROVIDER_FOLDER_NAME];
        self.cacheMaxSize = DEFAULT_CACHEPROVIDER_SIZE;
    }
    return self;
}

-(void)setPath:(NSString *)path{
    _path = path;
    //判断是文件夹是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (isDir == NO || existed == NO){
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        curSize = 0;
    }else{
        curSize = [self fileSizeForDir:path];
    }
}

-(BOOL)hasKey:(NSString *)key{
    if (key.length==0) {
        return NO;
    }
    NSString *name = [self md5Encrypt:key];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self.path stringByAppendingPathComponent:name];
    if(![fileManager fileExistsAtPath:filePath]){
        NSLog(@"[CacheProvider] Cache is nil by: %@",key);
        return NO;
    }
    return YES;
}
-(BOOL)isExpiredByKey:(NSString *)key{
    if (![self hasKey:key]) {
        return NO;
    }
    NSString *name = [self md5Encrypt:key];
    NSString *filePath = [self.path stringByAppendingPathComponent:name];
    NSMutableDictionary * data = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    int currentTime = [[NSDate date] timeIntervalSince1970];
    int expireTime = [[data objectForKey:DEFAULT_CACHEPROVIDER_FIELD_EXPIRETIME] intValue];
    if (currentTime > expireTime){
        NSLog(@"[CacheProvider] Cache expired by: %@",key);
        return NO;
    }else{
        NSLog(@"[CacheProvider] Cache valide by: %@",key);
        return YES;
    }
}
-(NSString *)cacheByKey:(NSString *)key{
    if (![self hasKey:key]) {
        return nil;
    }
    NSString * name = [self md5Encrypt:key];
    NSString *filePath = [self.path stringByAppendingPathComponent:name];
    NSMutableDictionary * data = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    NSString * content = [data objectForKey:DEFAULT_CACHEPROVIDER_FIELD_DATA];
    NSLog(@"[CacheProvider] Cache hit by: %@",content);
    return content;
}
-(int)cacheTimeByKey:(NSString *)key{
    if (![self hasKey:key]) {
        return 0;
    }
    NSString * name = [self md5Encrypt:key];
    NSString *filePath = [self.path stringByAppendingPathComponent:name];
    NSMutableDictionary * data = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    int cacheTime = [[data objectForKey:DEFAULT_CACHEPROVIDER_FIELD_CACHETIME] intValue];
    return cacheTime;
}
-(BOOL)setCacheByKey:(NSString *)key value:(NSString *)value valideTime:(int)valideTime{
    if (value.length == 0 || key.length == 0) {
        return NO;
    }
    NSString * name = [self md5Encrypt:key];
    //判断是否大于缓存上限
    if (curSize > self.cacheMaxSize){
        [self clearExpiredCache];
        curSize = [self fileSizeForDir:self.path];
        if (curSize > self.cacheMaxSize){
            [self clear];
        }
    }
    NSString * filePath = [self.path stringByAppendingPathComponent:name];
    NSMutableDictionary * newDicData = [[NSMutableDictionary alloc] init];
    double currentTime = [[NSDate date] timeIntervalSince1970];
    NSNumber * cacheTime = [NSNumber numberWithInt:currentTime];
    NSNumber * expireTime = [NSNumber numberWithInt:currentTime + valideTime];
    [newDicData setObject:cacheTime forKey:DEFAULT_CACHEPROVIDER_FIELD_CACHETIME];
    [newDicData setObject:expireTime forKey:DEFAULT_CACHEPROVIDER_FIELD_EXPIRETIME];
    [newDicData setObject:value forKey:DEFAULT_CACHEPROVIDER_FIELD_DATA];
    BOOL result = [newDicData writeToFile:filePath atomically:NO];//写入文件
    if (result){
        int fsize = [self fileSizeForFile:filePath fileManager:[NSFileManager defaultManager]];
        curSize+=fsize;
        NSLog(@"[CacheProvider] Cached Success from: %@",key);
        return YES;
    }
    NSLog(@"[CacheProvider] Cached Failed from: %@",key);
    return NO;
}


- (void)clear{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self.path error:nil];
}

#pragma mark - private

- (void)clearExpiredCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *direnum = [fileManager enumeratorAtPath:self.path];
    NSMutableArray *files = [NSMutableArray new];
    NSString *filename;
    while (filename = [direnum nextObject]) {
        if ([[filename pathExtension] isEqualToString:@""]) {
            [files addObject: filename];
        }
    }
    for (NSString *filePath in files) {
        NSMutableDictionary * data = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        int currentTime = [[NSDate date] timeIntervalSince1970];
        int expireTime = [[data objectForKey:DEFAULT_CACHEPROVIDER_FIELD_EXPIRETIME] intValue];
        if (currentTime > expireTime){
            [fileManager removeItemAtPath:filePath error:nil];
        }
    }
    curSize = [self fileSizeForDir:self.path];
    NSLog(@"[CacheProvider] Expired Cached Deleted, current size: %.2fM",curSize/1024.0/1024.0);
}
- (float)fileSizeForDir:(NSString*)path//计算文件夹下文件的总大小
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float size =0;
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(int i = 0; i<[array count]; i++){
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) ){
            size+=[self fileSizeForFile:fullPath fileManager:fileManager];
        }
        else{
            [self fileSizeForDir:fullPath];
        }
    }
    return size;
}
- (float)fileSizeForFile:(NSString*)path fileManager:(NSFileManager *)fileManager//计算文件的总大小
{
    if ([fileManager fileExistsAtPath:path]){
        NSDictionary *fileAttributeDic=[fileManager attributesOfItemAtPath:path error:nil];
        return fileAttributeDic.fileSize;
    }
    return 0;
}

- (NSString *)md5Encrypt:(NSString *)input
{
	const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];

    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}
@end
