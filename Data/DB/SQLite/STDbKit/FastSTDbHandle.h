//
//  FastSTDbHandle.h
//  1.对象使用应直接使用 FastSTDbObject类
//
//  Created by 俊涵 on 14-1-3.
//
//

#import "STDbHandle.h"

@interface FastSTDbHandle : STDbHandle

+ (BOOL)dropTableFromDB:(Class)aClass;

@end
