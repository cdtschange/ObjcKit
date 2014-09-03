//
//  SimpleAuth.h
//  ObjcKit
//
//  Created by Wei Mao on 9/3/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleAuth : NSObject

@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, strong) NSDate *expirationDate;

@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, assign) BOOL userKeyChain;

-(void)save;
-(void)load;
-(void)clear;
@end
