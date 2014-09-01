//
//  NSString+Encrypt.h
//  ObjcKit
//
//  Created by Wei Mao on 9/1/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encrypt)

- (NSString *)md5Encrypt;

- (NSData *)base64Encrypt;

- (NSString *)AESEncryptWithPassword:(NSString *)password;
- (NSString *)AESDecryptWithPassword:(NSString *)password;

@end
