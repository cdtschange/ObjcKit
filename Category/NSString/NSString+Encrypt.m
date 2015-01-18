//
//  NSString+Encrypt.m
//  ObjcKit
//
//  Created by Wei Mao on 9/1/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "NSString+Encrypt.h"
#import "NSData+Base64Additions.h"
#import "NSData+CommonCrypto.h"
#import <CommonCrypto/CommonDigest.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation NSString (Encrypt)

#pragma mark - md5
- (NSString *)md5Encrypt
{
	const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];

    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

#pragma mark - base64
- (NSData *)base64Encrypt {
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[3];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;

    if (self == nil) {
        return [NSData data];
    }

    ixtext = 0;

    tempcstring = (const unsigned char *)[self UTF8String];

    lentext = [self length];

    theData = [NSMutableData dataWithCapacity: lentext];

    ixinbuf = 0;

    while (true) {
        if (ixtext >= lentext) {
            break;
        }

        ch = tempcstring [ixtext++];

        flignore = false;

        if ((ch >= 'A') && (ch <= 'Z')) {
            ch = ch - 'A';
        }
        else if ((ch >= 'a') && (ch <= 'z')) {
            ch = ch - 'a' + 26;
        }
        else if ((ch >= '0') && (ch <= '9')) {
            ch = ch - '0' + 52;
        }
        else if (ch == '+') {
            ch = 62;
        }
        else if (ch == '=') {
            flendtext = true;
        }
        else if (ch == '/') {
            ch = 63;
        }
        else {
            flignore = true;
        }

        if (!flignore) {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;

            if (flendtext) {
                if (ixinbuf == 0) {
                    break;
                }

                if ((ixinbuf == 1) || (ixinbuf == 2)) {
                    ctcharsinbuf = 1;
                }
                else {
                    ctcharsinbuf = 2;
                }

                ixinbuf = 3;

                flbreak = true;
            }

            inbuf [ixinbuf++] = ch;

            if (ixinbuf == 4) {
                ixinbuf = 0;

                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);

                for (i = 0; i < ctcharsinbuf; i++) {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak) {
                break;
            }
        }
    }
    
    return theData;
}

#pragma mark - aes
- (NSString *)AESEncryptWithPassword:(NSString *)password {
    NSData *encryptedData = [[self dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    NSString *base64EncodedString = [encryptedData base64StringWithLength:[encryptedData length]];
    return base64EncodedString;
}

- (NSString *)AESDecryptWithPassword:(NSString *)password {
    NSData *encryptedData = [self base64Encrypt];
    NSData *decryptedData = [encryptedData decryptedAES256DataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}
@end
