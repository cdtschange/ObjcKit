//
//  NetAPIData.m
//  Yumi
//
//  Created by Mao on 15/2/1.
//  Copyright (c) 2015年 Mao. All rights reserved.
//

#import "NetAPIData.h"
#import "NetAPIClient.h"
#import <objc/runtime.h>

@interface NetAPIData()

@property(nonatomic, strong)        NetAPIClient*   apiClient;
@property(nonatomic, strong)        NSDictionary*   apiQuery;
@property(nonatomic, copy)          NSString*       apiMethod;
@property(nonatomic, copy)          NSString*       apiUrl;

@end

@implementation NetAPIData

+ (instancetype)initWithClient:(NetAPIClient *)client query:(NSDictionary *)query mehod:(NSString *)method url:(NSString *)url{
    id data = [[self class] new];
    [data setApiClient:client];
    [data setApiQuery:[NSDictionary dictionaryWithDictionary:query]];
    if (method&&method.length>0) {
        [data setApiMethod:method];
    }else{
        [data setApiMethod:@"GET"];
    }
    [data setApiUrl:url];
    return data;
}

+ (id)jsonToObj:(id)json{
    NetAPIData *data = [[self class] new];
    return data;
}

+ (void)fillJson:(id)json inObject:(id)obj{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([obj class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [json valueForKey:(NSString *)propertyName];
        if ([propertyName isEqualToString:@"descriptionstr"]) {
            propertyValue = [json valueForKey:(NSString *)@"description"];
        }
        
        const char * type = property_getAttributes(property);
        NSString * typeString = [NSString stringWithUTF8String:type];
        NSArray * attributes = [typeString componentsSeparatedByString:@","];
        NSString * typeAttribute = [attributes objectAtIndex:0];
        NSString * propertyType = [typeAttribute substringFromIndex:1];
        const char * rawPropertyType = [propertyType UTF8String];
        if (strcmp(rawPropertyType, @encode(float)) == 0) {
            //it's a float
        } else if (strcmp(rawPropertyType, @encode(int)) == 0) {
            //it's an int
        } else if (strcmp(rawPropertyType, @encode(float)) == 0) {
            //it's some sort of float
        } else if (strcmp(rawPropertyType, @encode(double)) == 0) {
            //it's some sort of double
        } else if (strcmp(rawPropertyType, @encode(BOOL)) == 0) {
            //it's some sort of bool
        } else if (strcmp(rawPropertyType, @encode(id)) == 0) {
            //it's some sort of object
        } else if ([propertyType isEqualToString:@"@\"NSString\""]) {
            //it's some sort of nsstring
        }else if ([propertyType isEqualToString:@"@\"UIImage\""]) {
            //it's some sort of nsstring
        }else{
            if ([propertyType hasPrefix:@"@\""] && [propertyType hasSuffix:@"\""]) {
                propertyType = [propertyType substringFromIndex:2];
                propertyType = [propertyType substringToIndex:propertyType.length-1];
                Class class = NSClassFromString(propertyType);
                id subObj = [class new];
                [self fillJson:propertyValue inObject:subObj];
                [obj setValue:subObj forKey:propertyName];
                continue;
            }
        }
        
        if (propertyValue){
            [obj setValue:propertyValue forKey:propertyName];
        }
    }
    free(properties);
}

- (NSURLSessionDataTask *)requestWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    Class class = [self class];
    id successBlock = ^(NSURLSessionDataTask * __unused task, id JSON) {
        id result = JSON;
        if (JSON) {
            result = [class jsonToObj:JSON];
        }
        if (success) {
            success(result);
        }
    };
    id failureBlock = ^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (failure) {
            failure(error);
        }
    };
    self.apiClient.cachePolicy = self.cachePolicy;
    if ([self.apiMethod isEqual:@"GET"]) {
        return [self.apiClient GET:self.apiUrl parameters:self.apiQuery success:successBlock failure:failureBlock];
    }else if ([self.apiMethod isEqual:@"POST"]) {
        return [self.apiClient POST:self.apiUrl parameters:self.apiQuery success:successBlock failure:failureBlock];
    }else if ([self.apiMethod isEqual:@"PUT"]) {
        return [self.apiClient PUT:self.apiUrl parameters:self.apiQuery success:successBlock failure:failureBlock];
    }else if ([self.apiMethod isEqual:@"DELETE"]) {
        return [self.apiClient DELETE:self.apiUrl parameters:self.apiQuery success:successBlock failure:failureBlock];
    }
    return nil;
}
@end
