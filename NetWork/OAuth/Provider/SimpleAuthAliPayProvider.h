//
//  SimpleAuthAliPayProvider.h
//  ObjcKit
//
//  Created by Wei Mao on 9/3/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "SimpleAuthProvider.h"

@interface SimpleAuthAliPayProvider : SimpleAuthProvider

- (void)payByAliPayWapWithUrl:(NSString *)url completion:(void (^)(NSString* redirectUrl))completion;
- (void)payByAliPayAppWithUrl:(NSString *)url completion:(void (^)(BOOL success, NSError *error))completion;
@end
