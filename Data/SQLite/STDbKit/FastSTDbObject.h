//
//  THE : 对象映射数据库，对象直接继承 FastSTDbObject
//
//  Created by 俊涵 on 14-1-2.
//
//

#import "STDbKit.h"

#define STDb_DBColumnConnectionSymbol @"___"  //表的列名称分级之间的连接符号，如card_CardNum

@interface FastSTDbObject : STDbObject

/**
 *  @brief  删除对象表
 */
+ (BOOL)dropTableFromDB;

/**
 *  @brief  数据库路径
 */
+ (NSString *)dbPath;

/**
 *  @brief  删除数据库
 */
+ (BOOL)deleteDB;

/**
  Super class Method :
    @property (assign, nonatomic, readonly) NSInteger id__;
    @property (assign, nonatomic) NSDate *expireDate;
    - (BOOL)insertToDb;
    - (BOOL)updateToDbsWhere:(NSString *)where NS_DEPRECATED(10_0, 10_4, 2_0, 2_0);
    - (BOOL)updatetoDb;
    - (BOOL)removeFromDb;
    + (BOOL)existDbObjectsWhere:(NSString *)where;
    + (BOOL)removeDbObjectsWhere:(NSString *)where;
    + (NSMutableArray *)dbObjectsWhere:(NSString *)where orderby:(NSString *)orderby;
    + (NSMutableArray *)allDbObjects;
 */

@end


