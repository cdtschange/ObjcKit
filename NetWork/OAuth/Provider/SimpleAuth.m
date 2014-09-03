//
//  SimpleAuth.m
//  ObjcKit
//
//  Created by Wei Mao on 9/3/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "SimpleAuth.h"

@implementation SimpleAuth

-(void)save{
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.uid,@"uid",
                              self.accessToken,@"accessToken",
                              self.expirationDate,@"expirationDate", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:[NSString stringWithFormat:@"SimpleAuth_%@",self.type]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)load{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *authData = [defaults objectForKey:[NSString stringWithFormat:@"SimpleAuth_%@",self.type]];
    if ([authData objectForKey:@"uid"] &&
        [authData objectForKey:@"accessToken"] &&
        [authData objectForKey:@"expirationDate"])
    {
        self.uid = authData[@"uid"];
        self.accessToken = authData[@"accessToken"];
        self.expirationDate = authData[@"expirationDate"];
    }
}
-(void)clear{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"SimpleAuth_%@",self.type]];
    self.uid = nil;
    self.accessToken = nil;
    self.expirationDate = nil;
}
@end
