//
//  TKAddressBook.h
//  Yumi
//
//  Created by Mao on 15/2/21.
//  Copyright (c) 2015年 Mao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKAddressBookEmail : NSObject

@property(nonatomic, copy) NSString *emailLabel;
@property(nonatomic, copy) NSString *emailContent;

@end
@interface TKAddressBookAddress : NSObject

@property(nonatomic, copy) NSString *addressLabel;
@property(nonatomic, copy) NSString *country;
@property(nonatomic, copy) NSString *city;
@property(nonatomic, copy) NSString *state;
@property(nonatomic, copy) NSString *street;
@property(nonatomic, copy) NSString *zip;
@property(nonatomic, copy) NSString *coutntrycode;

@end
@interface TKAddressBookDate : NSObject

@property(nonatomic, copy) NSString *datesLabel;
@property(nonatomic, copy) NSString *datesContent;

@end
@interface TKAddressBookIM : NSObject

@property(nonatomic, copy) NSString *instantMessageLabel;
@property(nonatomic, copy) NSString *instantMessageContentUserName;
@property(nonatomic, copy) NSString *instantMessageContentService;

@end
@interface TKAddressBookPhone : NSObject

@property(nonatomic, copy) NSString *personPhoneLabel;
@property(nonatomic, copy) NSString *personPhone;

@end
@interface TKAddressBookUrl : NSObject

@property(nonatomic, copy) NSString *urlLabel;
@property(nonatomic, copy) NSString *urlContent;

@end

@interface TKAddressBook : NSObject

@property(nonatomic, copy) NSString *firstname;
@property(nonatomic, copy) NSString *lastname;
@property(nonatomic, copy) NSString *middlename;
@property(nonatomic, copy) NSString *prefix;
@property(nonatomic, copy) NSString *suffix;
@property(nonatomic, copy) NSString *nickname;
@property(nonatomic, copy) NSString *firstnamePhonetic;
@property(nonatomic, copy) NSString *lastnamePhonetic;
@property(nonatomic, copy) NSString *middlenamePhonetic;
@property(nonatomic, copy) NSString *organization;
@property(nonatomic, copy) NSString *jobtitle;
@property(nonatomic, copy) NSString *department;
@property(nonatomic, strong) NSDate *birthday;
@property(nonatomic, copy) NSString *note;
@property(nonatomic, copy) NSString *firstknow;
@property(nonatomic, copy) NSString *lastknow;
@property(nonatomic, strong) NSArray *emails;
@property(nonatomic, strong) NSArray *address;
@property(nonatomic, strong) NSArray *dates;
@property(nonatomic, assign) BOOL isCompany;
@property(nonatomic, strong) NSArray *im;
@property(nonatomic, strong) NSArray *phones;
@property(nonatomic, strong) NSArray *urls;
@property(nonatomic, strong) UIImage *image;


+ (NSArray *)getAllContacts;

@end