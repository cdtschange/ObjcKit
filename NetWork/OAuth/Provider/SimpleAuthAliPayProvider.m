//
//  SimpleAuthAliPayProvider.m
//  ObjcKit
//
//  Created by Wei Mao on 9/3/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "SimpleAuthAliPayProvider.h"
#import "AlixPay.h"

#define PayURLScheme    @"AlixPay"

@interface SimpleAuthAliPayProvider()

@property (nonatomic, copy) void (^payBlock)(BOOL, NSError *);

@end

@implementation SimpleAuthAliPayProvider

- (void)payByAliPayWapWithUrl:(NSString *)url completion:(void (^)(NSString *))completion{
    if (completion) {
        completion(url);
    }
}

- (void)payByAliPayAppWithUrl:(NSString *)url completion:(void (^)(BOOL success, NSError *error))completion{
    self.payBlock = completion;
    //应用注册scheme,在Info.plist定义URL types,用于安全支付成功后重新唤起商户应用
    NSString *scheme = [SimpleAuthAliPayProvider stringURLSchemeWithKeyword:PayURLScheme];
    AlixPay * alixpay = [AlixPay shared];

    int ret = [alixpay pay:url applicationScheme:scheme];
    if (ret == kSPErrorAlipayClientNotInstalled) {
        NSString *message = @"请安装支付宝客户端";
        NSError *error = [NSError errorWithDomain:@"AliPayErrorDomain" code:kSPErrorAlipayClientNotInstalled userInfo:@{@"error":message}];
        if (self.payBlock) {
            self.payBlock(NO, error);
        }
    } else if (ret == kSPErrorSignError) {
        NSString *message = @"签名错误";
        NSError *error = [NSError errorWithDomain:@"AliPayErrorDomain" code:kSPErrorSignError userInfo:@{@"error":message}];
        if (self.payBlock) {
            self.payBlock(NO, error);
        }
    } else {// OK
        if (self.payBlock) {
            self.payBlock(YES, nil);
        }
    }
}


#pragma mark - URLScheme From Plist
+ (NSString *)stringURLSchemeWithKeyword:(NSString *)keyworkd
{
    NSArray *ary = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    for (NSDictionary *dic in ary) {
        NSString *urlName = [dic objectForKey:@"CFBundleURLName"];
        if ([urlName isEqualToString:keyworkd]) {
            NSArray *schemes = [dic objectForKey:@"CFBundleURLSchemes"];
            for (NSString *scheme in schemes) {
                if (scheme.length > 0) {
                    return scheme;
                }
            }
        }
    }
    return @"";
}
@end
