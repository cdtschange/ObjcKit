//
//  SimpleAuthProvider.h
//  SimpleAuth
//
//  Created by Caleb Davenport on 11/6/13.
//  Copyright (c) 2013-2014 Byliner, Inc. All rights reserved.
//

#import "SimpleAuth.h"

#define SimpleAuthAppKey            @"SimpleAuthAppKey"
#define SimpleAuthAppSecret         @"SimpleAuthAppSecret"
#define SimpleAuthRedirectURI       @"SimpleAuthRedirectURI"
#define SimpleAuthSSOCallbackScheme @"SimpleAuthSSOCallbackScheme"

@interface SimpleAuthProvider : NSObject

@property (nonatomic, copy) NSDictionary *options;
@property (nonatomic, strong) SimpleAuth *simpleAuth;

+ (NSString *)type;

- (instancetype)initWithOptions:(NSDictionary *)options;
- (void)authorizeWithCompletion:(void (^)(BOOL success, NSError *error))completion;
- (void)unAuthorize;

- (BOOL)isAuthorized;

@end
