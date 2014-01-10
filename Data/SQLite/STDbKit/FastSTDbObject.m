//
//  CusomtSTDbObject.m
//  STDbObject
//
//  Created by 俊涵 on 14-1-2.
//
//

#import "FastSTDbObject.h"
#import "FastSTDbHandle.h"
#import <objc/runtime.h>

@implementation FastSTDbObject

+ (NSString *)dbPath
{
    return [STDbHandle dbPath];
}

+ (BOOL)deleteDB
{
    NSString *path = [STDbHandle dbPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        return [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
    return YES;
}

+ (BOOL)dropTableFromDB
{
    return [FastSTDbHandle dropTableFromDB:[self class]];
}

- (BOOL)insertToDb
{
    return [FastSTDbHandle insertDbObject:self];
}

- (BOOL)updateToDbsWhere:(NSString *)where NS_DEPRECATED(10_0, 10_4, 2_0, 2_0)
{
    return [FastSTDbHandle updateDbObject:self condition:where];
}

- (BOOL)updateToDb
{
    NSString *condition = [NSString stringWithFormat:@"%@=%d", kDbId, self.id__];
    return [FastSTDbHandle updateDbObject:self condition:condition];
}

+ (BOOL)existDbObjectsWhere:(NSString *)where
{
    NSArray *objs = [FastSTDbHandle selectDbObjects:[self class] condition:where orderby:nil];
    if ([objs count] > 0) {
        return YES;
    }
    return NO;
}

+ (NSArray *)dbObjectsWhere:(NSString *)where orderby:(NSString *)orderby
{
    return [FastSTDbHandle selectDbObjects:[self class] condition:where orderby:orderby];
}

+ (NSMutableArray *)allDbObjects
{
    return [FastSTDbHandle selectDbObjects:[self class] condition:@"all" orderby:nil];
}

@end
