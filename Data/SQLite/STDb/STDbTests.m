//
//  STDbTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/27/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "STDbKit.h"

enum SexType {
    kSexTypeMale = 0,
    kSexTypeFemale = 1,
};

@interface User : STDbObject

@property (assign, nonatomic) int _id;        /** 唯一标识id */
@property (strong, nonatomic) NSString *name; /** 姓名 */
@property (assign, nonatomic) NSInteger age;  /** 年龄 */
@property (strong, nonatomic) NSNumber *sex;  /** 性别 */

@property (strong, nonatomic) NSString *phone;  /** 电话号码 */
@property (strong, nonatomic) NSString *email;  /** 邮箱 */

@property (strong, nonatomic) NSData *image;        /** 头像 */
@property (strong, nonatomic) NSDate *birthday;     /** 出生日期 */
@property (strong, nonatomic) NSDictionary *info;   /** 其他信息 */
@property (strong, nonatomic) NSArray *favs;        /** 爱好 */

@end

@implementation User

@end



@interface STDbTests : XCTestCase

@end

@implementation STDbTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSTDbObject
{
    NSArray *users = [User allDbObjects];
    // 添加默认用户
    if (![User existDbObjectsWhere:@"_id=0"]) {
        // 初始化
        User *user = [[User alloc] init];
        user._id = 0;
        user.name = @"admin";
        user.age = 26;
        user.sex = @(kSexTypeMale);

        user.phone = @"10086";
        user.email = @"863629377@qq.com";

        UIImage *image = [UIImage imageNamed:@"4"];
        user.image = UIImagePNGRepresentation(image);
        user.birthday = [NSDate date];
        user.info = @{@"name": @"xuezhang"};
        user.favs = @[@"桌球、羽毛球"];
        // 插入到数据库
        [user insertToDb];
    }
    users = [User allDbObjects];
    // 更新到数据库
    if (users.count>0) {
        User *user1 = users[0];
        user1.name = @"admin2";
        user1.age = 27;
        [user1 updatetoDb];
        // 从数据库中删除数据
        [user1 removeFromDb];
    }
}

@end
