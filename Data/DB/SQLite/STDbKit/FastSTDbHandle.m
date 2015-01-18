//
//  FastSTDbHandle.m
//  STDbObject
//
//  Created by 俊涵 on 14-1-3.
//
//

#import "FastSTDbHandle.h"

#import <objc/runtime.h>
#import "FastSTDbObject.h"

@interface FastSTDbHandle()

@end

@implementation FastSTDbHandle

+ (NSString *)dbPath
{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [NSString stringWithFormat:@"%@/%@", document, DBName];
    return path;
}

+ (BOOL)dropTableFromDB:(Class)aClass
{
    if (![FastSTDbHandle isOpened]) {
        [FastSTDbHandle openDb];
    }
    if ([FastSTDbHandle sqlite_tableExist:aClass]) {
        NSString *sql = [NSString stringWithFormat:@"drop table %@", NSStringFromClass(aClass)];
        char *errmsg = 0;
        FastSTDbHandle *db = [FastSTDbHandle shareDb];
        if (![FastSTDbHandle isOpened]) {
            [FastSTDbHandle openDb];
        }
        sqlite3 *sqlite3DB = db.sqlite3DB;
        int ret = sqlite3_exec(sqlite3DB,[sql UTF8String],NULL,NULL,&errmsg);
        if(ret != SQLITE_OK){
            fprintf(stderr,"drop table fail: %s\n",errmsg);
            sqlite3_free(errmsg);
            [FastSTDbHandle closeDb];
            return NO;
        } else {
            sqlite3_free(errmsg);
            [FastSTDbHandle closeDb];
            return YES;
        }
    }
    return YES;
}

+ (void)createDbTable:(Class)aClass
{
    if (![FastSTDbHandle isOpened]) {
        [FastSTDbHandle openDb];
    }
    if ([FastSTDbHandle sqlite_tableExist:aClass]) {
        STDBLog(@"数据库表%@已存在!", NSStringFromClass(aClass));
        return;
    }
    if (![FastSTDbHandle isOpened]) {
        [FastSTDbHandle openDb];
    }
    NSMutableString *sql = [NSMutableString stringWithCapacity:0];
    [sql appendString:@"create table "];
    [sql appendString:NSStringFromClass(aClass)];
    [sql appendString:@"("];

    NSMutableArray *propertyArr = [NSMutableArray arrayWithCapacity:0];
    [FastSTDbHandle class:aClass getPropertyNameList:propertyArr preName:nil];
    NSString *propertyStr = [propertyArr componentsJoinedByString:@","];

    [sql appendString:propertyStr];
    [sql appendString:@");"];

    char *errmsg = 0;
    FastSTDbHandle *db = [FastSTDbHandle shareDb];
    sqlite3 *sqlite3DB = db.sqlite3DB;
    int ret = sqlite3_exec(sqlite3DB,[sql UTF8String],NULL,NULL,&errmsg);
    if(ret != SQLITE_OK){
        fprintf(stderr,"create table fail: %s\n",errmsg);
    }
    sqlite3_free(errmsg);
    [STDbHandle closeDb];
}

+ (BOOL)insertDbObject:(STDbObject *)obj
{
    if (![FastSTDbHandle isOpened]) {
        [FastSTDbHandle openDb];
    }
    NSString *tableName = NSStringFromClass(obj.class);
    if (![FastSTDbHandle sqlite_tableExist:obj.class]) {
        [FastSTDbHandle createDbTable:obj.class];
    }
    if (![FastSTDbHandle isOpened]) {
        [FastSTDbHandle openDb];
    }
    NSMutableArray *propertyArr = [NSMutableArray arrayWithCapacity:0];
    propertyArr = [NSMutableArray arrayWithArray:[self sqlite_columns:obj.class]];

    NSInteger argNum = [propertyArr count];
    NSMutableString *sql_NSString = [[NSMutableString alloc] initWithFormat:@"insert into %@ values(?)", tableName];
    NSRange range = [sql_NSString rangeOfString:@"?"];
    for (int i = 0; i < argNum - 1; i++) {
        [sql_NSString insertString:@",?" atIndex:range.location + 1];
    }

    sqlite3_stmt *stmt = NULL;
    FastSTDbHandle *db = [FastSTDbHandle shareDb];
    sqlite3 *sqlite3DB = db.sqlite3DB;

    const char *errmsg = NULL;
    int result = sqlite3_prepare_v2(sqlite3DB, [sql_NSString UTF8String], -1, &stmt, &errmsg);
    if (result == SQLITE_OK) {
        for (int i = 1; i <= argNum; i++) {
            NSString * key = propertyArr[i - 1][@"title"];
            if ([key isEqualToString:kDbId]) {
                continue;
            }
            NSString *column_type_string = propertyArr[i - 1][@"type"];
            
            NSArray *names = [key componentsSeparatedByString:STDb_DBColumnConnectionSymbol];
            objc_property_t property_t = class_getProperty(obj.class, [key UTF8String]);
            if (names.count > 1) {
                NSString *valueKey = @"";
                for (int k = 0; k <= names.count - 2; k++) {
                    NSString *propertyName = names[k];
                    if (valueKey.length > 1) {
                        valueKey = [valueKey stringByAppendingString:@"."];
                    }
                    valueKey = [valueKey stringByAppendingString:propertyName];
                }
                NSObject *property = [obj valueForKeyPath:valueKey];
                NSString *lastPropertyName = names.lastObject;
                property_t = class_getProperty(property.class, [lastPropertyName UTF8String]);
            }

            NSString *changeKey = [key stringByReplacingOccurrencesOfString:STDb_DBColumnConnectionSymbol withString:@"."];
            id value = [obj valueForKeyPath:changeKey];

            if ([column_type_string isEqualToString:@"blob"]) {
                if (!value || value == [NSNull null] || [value isEqual:@""]) {
                    sqlite3_bind_null(stmt, i);
                } else {
                    NSData *data = [NSData dataWithData:value];
                    int len = (int)[data length];
                    const void *bytes = [data bytes];
                    sqlite3_bind_blob(stmt, i, bytes, len, NULL);
                }

            } else if ([column_type_string isEqualToString:@"text"]) {
                if (!value || value == [NSNull null] || [value isEqual:@""]) {
                    sqlite3_bind_null(stmt, i);
                } else {
                    value = [self valueForDbObjc_property_t:property_t dbValue:value];
                    NSString *column_value = [NSString stringWithFormat:@"%@", value];
                    sqlite3_bind_text(stmt, i, [column_value UTF8String], -1, SQLITE_STATIC);
                }

            } else if ([column_type_string isEqualToString:@"real"]) {
                if (!value || value == [NSNull null] || [value isEqual:@""]) {
                    sqlite3_bind_null(stmt, i);
                } else {
                    id column_value = value;
                    sqlite3_bind_double(stmt, i, [column_value doubleValue]);
                }
            }
            else if ([column_type_string isEqualToString:@"integer"]) {
                if (!value || value == [NSNull null] || [value isEqual:@""]) {
                    sqlite3_bind_null(stmt, i);
                } else {
                    id column_value = value;
                    sqlite3_bind_int(stmt, i, [column_value intValue]);
                }
            }
        }
        int rc = sqlite3_step(stmt);

        if ((rc != SQLITE_DONE) && (rc != SQLITE_ROW)) {
            fprintf(stderr,"insert dbObject fail: %s\n",errmsg);
            sqlite3_finalize(stmt);
            stmt = NULL;
            [STDbHandle closeDb];

            return NO;
        }
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
    [STDbHandle closeDb];

    return YES;
}

+ (Class)getComplexPropertyClassFromObject:(NSObject *)obj propertyName:(NSString *)name
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(obj.class, &count);

    // 拿到属性里 是 @ 的
    for (int j = 0; j < count; j++) {
        objc_property_t property_t = properties[j];

        NSString * propertyName = [[NSString alloc]initWithCString:property_getName(property_t) encoding:NSUTF8StringEncoding];
        if ([propertyName isEqualToString:name]) {
            char * propertyType = property_copyAttributeValue(property_t, "T");
            NSString *cls;
            switch (propertyType[0]) {
                case '@':
                    cls = [NSString stringWithUTF8String:propertyType];
                    cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
                    cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    if ([NSClassFromString(cls) isSubclassOfClass:[NSString class]]) {
                        break;
                    }
                    if ([NSClassFromString(cls) isSubclassOfClass:[NSNumber class]]) {
                        break;
                    }
                    if ([NSClassFromString(cls) isSubclassOfClass:[NSDictionary class]]) {
                        break;
                    }
                    if ([NSClassFromString(cls) isSubclassOfClass:[NSArray class]]) {
                        break;
                    }
                    if ([NSClassFromString(cls) isSubclassOfClass:[NSDate class]]) {
                        break;
                    }
                    if ([NSClassFromString(cls) isSubclassOfClass:[NSValue class]]) {
                        break;
                    }
                    // 自定义NSObject需要设置
                    if ([NSClassFromString(cls) isSubclassOfClass:[NSObject class]]) {
                        return NSClassFromString(cls);
                    }
                    break;
                default:
                    break;
            }
            break;
        }
    }
    return nil;
}

+ (NSMutableArray *)selectDbObjects:(Class)aClass condition:(NSString *)condition orderby:(NSString *)orderby
{
    if (![FastSTDbHandle isOpened]) {
        [FastSTDbHandle openDb];
    }

    [self cleanExpireDbObject:aClass];

    sqlite3_stmt *stmt = NULL;
    NSMutableArray *array = nil;
    NSMutableString *selectstring = nil;
    NSString *tableName = NSStringFromClass(aClass);

    selectstring = [[NSMutableString alloc] initWithFormat:@"select %@ from %@", @"*", tableName];
    if (condition != nil || [condition length] != 0) {
        if (![[condition lowercaseString] isEqualToString:@"all"]) {
            [selectstring appendFormat:@" where %@", condition];
        }
    }
    if (orderby != nil || [orderby length] != 0) {
        if (![[orderby lowercaseString] isEqualToString:@"no"]) {
            [selectstring appendFormat:@" order by %@", orderby];
        }
    }

    FastSTDbHandle *db = [FastSTDbHandle shareDb];
    sqlite3 *sqlite3DB = db.sqlite3DB;

    if (sqlite3_prepare_v2(sqlite3DB, [selectstring UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
        int column_count = sqlite3_column_count(stmt);
        while (sqlite3_step(stmt) == SQLITE_ROW) {

            FastSTDbObject *obj = [[NSClassFromString(tableName) alloc] init];

            for (int i = 0; i < column_count; i++) {
                const char *column_name = sqlite3_column_name(stmt, i);
                const char * column_decltype = sqlite3_column_decltype(stmt, i);

                id column_value = nil;
                NSData *column_data = nil;

                // 将obj里面所有是nil的对象都初始化出来
                NSString *columnNameStr = [NSString stringWithUTF8String:column_name];
                NSArray *names = [columnNameStr componentsSeparatedByString:STDb_DBColumnConnectionSymbol];
                if (names.count > 1) {
                    NSString *propertyName;
                    id propertyObj = obj;
                    for (int k = 0; k < names.count - 1; k++) {
                        propertyName = names[k];
                        Class propertyClass = [FastSTDbHandle getComplexPropertyClassFromObject:propertyObj propertyName:propertyName];
                        if (propertyClass && ![propertyObj valueForKey:propertyName]) {
                            id value = [[propertyClass alloc] init];
                            [propertyObj setValue:value forKey:propertyName];
                        }
                        propertyObj = [propertyObj valueForKey:propertyName];
                    }
                }

                /* 得到正确的 property*/
                objc_property_t property_t = class_getProperty(obj.class, column_name);
                if (names.count > 1) {
                    NSString *valueKey = @"";
                    for (int k = 0; k <= names.count - 2; k++) {
                        NSString *propertyName = names[k];
                        if (valueKey.length > 1) {
                            valueKey = [valueKey stringByAppendingString:@"."];
                        }
                        valueKey = [valueKey stringByAppendingString:propertyName];
                    }
                    NSObject *property = [obj valueForKeyPath:valueKey];
                    NSString *lastPropertyName = names.lastObject;
                    property_t = class_getProperty(property.class, [lastPropertyName UTF8String]);
                }

                NSString *obj_column_decltype = [[NSString stringWithUTF8String:column_decltype] lowercaseString];
                columnNameStr = [columnNameStr stringByReplacingOccurrencesOfString:STDb_DBColumnConnectionSymbol withString:@"."];
                if ([obj_column_decltype isEqualToString:@"text"]) {
                    const unsigned char *value = sqlite3_column_text(stmt, i);
                    if (value != NULL) {
                        column_value = [NSString stringWithUTF8String: (const char *)value];
                        id objValue = [self valueForObjc_property_t:property_t dbValue:column_value];
                        [obj setValue:objValue forKeyPath:columnNameStr];
                    }
                } else if ([obj_column_decltype isEqualToString:@"integer"]) {
                    int value = sqlite3_column_int(stmt, i);
                    if (&value != NULL) {
                        column_value = [NSNumber numberWithInt: value];

                        id objValue = [self valueForObjc_property_t:property_t dbValue:column_value];
                        [obj setValue:objValue forKeyPath:columnNameStr];
                    }
                } else if ([obj_column_decltype isEqualToString:@"real"]) {
                    double value = sqlite3_column_double(stmt, i);
                    if (&value != NULL) {
                        column_value = [NSNumber numberWithDouble:value];
                        id objValue = [self valueForObjc_property_t:property_t dbValue:column_value];
                        [obj setValue:objValue forKeyPath:columnNameStr];
                    }
                } else if ([obj_column_decltype isEqualToString:@"blob"]) {
                    const void *databyte = sqlite3_column_blob(stmt, i);
                    if (databyte != NULL) {
                        int dataLenth = sqlite3_column_bytes(stmt, i);
                        column_data = [NSData dataWithBytes:databyte length:dataLenth];
                        id objValue = [self valueForObjc_property_t:property_t dbValue:column_data];
                        [obj setValue:objValue forKeyPath:columnNameStr];
                    }
                } else {
                    const unsigned char *value = sqlite3_column_text(stmt, i);
                    if (value != NULL) {
                        column_value = [NSString stringWithUTF8String: (const char *)value];
                        id objValue = [self valueForObjc_property_t:property_t dbValue:column_value];
                        [obj setValue:objValue forKeyPath:columnNameStr];
                    }
                }
            }
            if (array == nil) {
                array = [[NSMutableArray alloc] initWithObjects:obj, nil];
            } else {
                [array addObject:obj];
            }
        }
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
    [STDbHandle closeDb];

    return array;
}

+ (BOOL)updateDbObject:(STDbObject *)obj condition:(NSString *)condition
{
    if (![FastSTDbHandle isOpened]) {
        [FastSTDbHandle openDb];
    }
    NSMutableArray *propertyArr = [NSMutableArray arrayWithArray:[self sqlite_columns:obj.class]];
    NSInteger argNum = propertyArr.count;

    sqlite3_stmt *stmt = NULL;
    NSString *tableName = NSStringFromClass(obj.class);
    NSMutableArray *bindStrArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *updatePropertyTypeArr = [NSMutableArray arrayWithCapacity:0];
    sqlite3 *sqlite3DB = [[FastSTDbHandle shareDb] sqlite3DB];

    for (int i = 1; i <= argNum; i++) {
        NSString * columnNameStr = propertyArr[i - 1][@"title"];
        if ([columnNameStr isEqualToString:kDbId]) {
            continue;
        }
        NSString *propertyPath = [columnNameStr stringByReplacingOccurrencesOfString:STDb_DBColumnConnectionSymbol withString:@"."];
        id value = [obj valueForKeyPath:propertyPath];
        if (value && (NSNull *)value != [NSNull null]) {
            NSString *bindStr = [NSString stringWithFormat:@"%@=?", columnNameStr];
            [bindStrArr addObject:bindStr];
            [updatePropertyTypeArr addObject:propertyArr[i - 1]];
        }
    }

    NSString *newValueStr = [bindStrArr componentsJoinedByString:@","];
    NSMutableString *updateStr = [NSMutableString stringWithFormat:@"update %@ set %@ where %@", tableName, newValueStr, condition];

    const char *errmsg = NULL;
    int result = sqlite3_prepare_v2(sqlite3DB, [updateStr UTF8String], -1, &stmt, &errmsg);
    if (result == SQLITE_OK) {
        for (int i = 1; i < updatePropertyTypeArr.count+1; i++) {

            NSString * key = updatePropertyTypeArr[i-1][@"title"];
            NSString *column_type_string = updatePropertyTypeArr[i-1][@"type"];

            NSString *changeKey = [key stringByReplacingOccurrencesOfString:STDb_DBColumnConnectionSymbol withString:@"."];
            id value = [obj valueForKeyPath:changeKey];

            // 拿到正确的property
            NSArray *names = [key componentsSeparatedByString:STDb_DBColumnConnectionSymbol];
            objc_property_t property_t = class_getProperty(obj.class, [key UTF8String]);
            if (names.count > 1) {
                NSString *valueKey = @"";
                for (int k = 0; k <= names.count - 2; k++) {
                    NSString *propertyName = names[k];
                    if (valueKey.length > 1) {
                        valueKey = [valueKey stringByAppendingString:@"."];
                    }
                    valueKey = [valueKey stringByAppendingString:propertyName];
                }
                NSObject *property = [obj valueForKeyPath:valueKey];
                NSString *lastPropertyName = names.lastObject;
                property_t = class_getProperty(property.class, [lastPropertyName UTF8String]);
            }

            if ([column_type_string isEqualToString:@"blob"]) {
                if (!value || value == [NSNull null] || [value isEqual:@""]) {
                    sqlite3_bind_null(stmt, i);
                } else {
                    NSData *data = [NSData dataWithData:value];
                    int len = (int)[data length];
                    const void *bytes = [data bytes];
                    sqlite3_bind_blob(stmt, i, bytes, len, NULL);
                }
            } else if ([column_type_string isEqualToString:@"text"]) {
                if (!value || value == [NSNull null] || [value isEqual:@""]) {
                    sqlite3_bind_null(stmt, i);
                } else {
                    value = [self valueForDbObjc_property_t:property_t dbValue:value];
                    NSString *column_value = [NSString stringWithFormat:@"%@", value];
                    sqlite3_bind_text(stmt, i, [column_value UTF8String], -1, SQLITE_STATIC);
                }
            } else if ([column_type_string isEqualToString:@"real"]) {
                if (!value || value == [NSNull null] || [value isEqual:@""]) {
                    sqlite3_bind_null(stmt, i);
                } else {
                    id column_value = value;
                    sqlite3_bind_double(stmt, i, [column_value doubleValue]);
                }
            }
            else if ([column_type_string isEqualToString:@"integer"]) {
                if (!value || value == [NSNull null] || [value isEqual:@""]) {
                    sqlite3_bind_null(stmt, i);
                } else {
                    id column_value = value;
                    sqlite3_bind_int(stmt, i, [column_value intValue]);
                }
            }
        }
        int rc = sqlite3_step(stmt);
        if ((rc != SQLITE_DONE) && (rc != SQLITE_ROW)) {
            fprintf(stderr,"update dbObject fail: %s\n",errmsg);
            sqlite3_finalize(stmt);
            stmt = NULL;
            [STDbHandle closeDb];
            return NO;
        }
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
    [STDbHandle closeDb];
    return YES;
}

#pragma mark - other method

+ (Class)subClassOfPropertySTDbObject:(objc_property_t)property
{
    char * type = property_copyAttributeValue(property, "T");
    switch(type[0]) {
        case 'f' : //float
        case 'd' : //double
        {
            return nil;
        }
            break;
        case 'c':   // char
        case 's' : //short
        case 'i':   // int
        case 'l':   // long
        {
            return nil;
        }
            break;
        case '*':   // char *
            break;
        case '@' : //ObjC object
        {
            NSString *cls = [NSString stringWithUTF8String:type];
            cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
            cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];

            if ([NSClassFromString(cls) isSubclassOfClass:[NSString class]]) {
                return nil;
            }

            if ([NSClassFromString(cls) isSubclassOfClass:[NSNumber class]]) {
                return nil;
            }

            if ([NSClassFromString(cls) isSubclassOfClass:[NSDictionary class]]) {
                return nil;
            }

            if ([NSClassFromString(cls) isSubclassOfClass:[NSArray class]]) {
                return nil;
            }

            if ([NSClassFromString(cls) isSubclassOfClass:[NSDate class]]) {
                return nil;
            }

            if ([NSClassFromString(cls) isSubclassOfClass:[NSData class]]) {
                return nil;
            }

            if ([NSClassFromString(cls) isSubclassOfClass:[NSObject class]]) {
                return NSClassFromString(cls);
            }
        }
            break;
    }
    return nil;
}

+ (void)class:(Class)aClass getPropertyNameList:(NSMutableArray *)proName preName:(NSString *)preName
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(aClass, &count);

    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];

        NSString * key = [[NSString alloc]initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if (preName && ![preName isEqualToString:@""]) {
            key = [preName stringByAppendingFormat:@"%@", key];
        }

        NSString *type;
        Class theClass = [FastSTDbHandle subClassOfPropertySTDbObject:property];
        if (theClass) {
            NSString *newPreName = [key stringByAppendingString:STDb_DBColumnConnectionSymbol];
            [FastSTDbHandle class:theClass getPropertyNameList:proName preName:newPreName];
        } else {
            type = [FastSTDbHandle dbTypeConvertFromObjc_property_t:property];
            NSString *proStr;
            if ([key isEqualToString:kDbId]) {
                proStr = [NSString stringWithFormat:@"%@ %@ primary key", kDbId, DBInt];
            } else {
                proStr = [NSString stringWithFormat:@"%@ %@", key, type];
            }
            [proName addObject:proStr];
        }
    }

    if (aClass == [STDbObject class]) {
        return;
    }
    if ([aClass superclass] == [NSObject class]) {
        return;
    }
    // 这的目的是 取到父类的属性并 拼好名字，如果是基本类型是不用的。
    [FastSTDbHandle class:[aClass superclass] getPropertyNameList:proName preName:preName];
}

@end
