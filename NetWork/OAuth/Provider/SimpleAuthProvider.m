//
//  SimpleAuthProvider.m
//  SimpleAuth
//
//  Created by Caleb Davenport on 11/6/13.
//  Copyright (c) 2013-2014 Byliner, Inc. All rights reserved.
//

#import "SimpleAuthProvider.h"

@interface SimpleAuthProvider ()

@end

@implementation SimpleAuthProvider


#pragma mark - Public

- (SimpleAuth *)simpleAuth{
    if (_simpleAuth == nil) {
        _simpleAuth = [[SimpleAuth alloc] init];
        _simpleAuth.type = [self class].type;
    }
    return _simpleAuth;
}

+ (NSString *)type {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithOptions:(NSDictionary *)options {
    if ((self = [super init])) {
        self.options = options;
        [self.simpleAuth load];
    }
    return self;
}

- (void)authorizeWithCompletion:(void (^)(BOOL success, NSError *error))completion {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)unAuthorize{

}
- (BOOL)isAuthorized{
    return NO;
}


@end
