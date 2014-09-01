//
//  NSString+Utilities.h
//  SourceKitDemo
//
//  Created by Wei Mao on 1/8/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Valid)
//验证是否是中国的手机号码格式
- (BOOL)validFormatChinaMobile;
//验证是否是电子邮箱格式
- (BOOL)validFormatEmail;
//验证是否是数字格式
- (BOOL)validFormatNumber;
@end
