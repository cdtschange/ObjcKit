//
//  FastSTDbTests.m
//  FastSTDbTests
//
//  Created by 俊涵 on 14-1-8.
//  Copyright (c) 2014年 俊涵. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FastSTDbKit.h"

@interface Money : NSObject

@property (nonatomic, strong) NSString *name;

@end
@implementation Money

@end

@interface Card : FastSTDbObject

@property (nonatomic, strong) NSNumber *cardNum;
@property (nonatomic, assign) NSInteger cardLevel;
@property (nonatomic, strong) Money *money;

@end
@implementation Card

@end

@interface User : FastSTDbObject

@property (assign, nonatomic) int _id;        /** 唯一标识id */
@property (copy, nonatomic) NSString *name; /** 姓名 */
@property (assign, nonatomic) NSInteger age;  /** 年龄 */
@property (strong, nonatomic) NSNumber *sex;  /** 性别 */

@property (strong, nonatomic) NSString *phone;  /** 电话号码 */
@property (strong, nonatomic) NSString *email;  /** 邮箱 */

@property (strong, nonatomic) NSData *image;        /** 头像 */
@property (strong, nonatomic) NSDate *birthday;     /** 出生日期 */
@property (strong, nonatomic) NSDictionary *info;   /** 其他信息 */
@property (strong, nonatomic) NSArray *favs;        /** 爱好 */

@property (strong, nonatomic) Card *card;   /** 会员卡 */

@end
@implementation User

@end


@interface FastSTDbTests : XCTestCase

@end

@implementation FastSTDbTests

- (void)setUp
{
    [super setUp];
    [User dropTableFromDB];
}

- (void)tearDown
{
    [super tearDown];
    [User dropTableFromDB];
}

- (void)testFastSTDb
{
    User *user = [[User alloc] init];
    user.age = 22;
    user.name = @"user1";
    user.card = [[Card alloc] init];
    user.card.cardLevel = 6;
    user.card.cardNum = [NSNumber numberWithInteger:3];
    user.card.money = [Money new];
    user.card.money.name = @"name1";

    [user insertToDb];
    NSArray *array = [User allDbObjects];
    XCTAssertEqual(1, (int)array.count);
    User *userdb = array[0];
    XCTAssertEqual(user.age, userdb.age);
    XCTAssertTrue([userdb.name isEqualToString:user.name]);
    XCTAssertEqual(user.card.cardLevel, userdb.card.cardLevel);
    XCTAssertEqual(user.card.cardNum.intValue, userdb.card.cardNum.intValue);
    XCTAssertTrue([userdb.card.money.name isEqualToString:user.card.money.name]);

    NSString *condition = [NSString stringWithFormat:@"age=%d",user.age];
    array = [User dbObjectsWhere:condition orderby:nil];
    XCTAssertEqual(1, (int)array.count);
    userdb = array[0];
    userdb.card.cardLevel = 2;
    userdb.card.cardNum = [NSNumber numberWithInt:90];
    userdb.card.money.name = @"name2";
    [userdb updateToDb];

    array = [User dbObjectsWhere:condition orderby:nil];
    XCTAssertEqual(1, (int)array.count);
    userdb = array[0];
    XCTAssertEqual(2, (int)userdb.card.cardLevel);
    XCTAssertEqual(90, (int)userdb.card.cardNum.intValue);
    XCTAssertTrue([userdb.card.money.name isEqualToString:@"name2"]);

    [userdb removeFromDb];
    array = [User allDbObjects];
    XCTAssertEqual(0, (int)array.count);
    [user insertToDb];
    array = [User allDbObjects];
    XCTAssertEqual(1, (int)array.count);
    [User dropTableFromDB];
    array = [User allDbObjects];
    XCTAssertEqual(0, (int)array.count);
}

@end
