//
//  NSString+Type.h
//  G2R
//
//  Created by Mao on 10/13/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Type)

//判断是否为整形：

- (BOOL)isPureInt;

//判断是否为浮点形：

- (BOOL)isPureFloat;

//是否是数字、字母组合
- (BOOL)isIncludeNumAndStr;

@end
