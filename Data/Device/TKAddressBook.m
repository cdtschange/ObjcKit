//
//  TKAddressBook.m
//  Yumi
//
//  Created by Mao on 15/2/21.
//  Copyright (c) 2015年 Mao. All rights reserved.
//

#import "TKAddressBook.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@implementation TKAddressBookAddress
@end
@implementation TKAddressBookDate
@end
@implementation TKAddressBookEmail
@end
@implementation TKAddressBookIM
@end
@implementation TKAddressBookPhone
@end
@implementation TKAddressBookUrl
@end

@implementation TKAddressBook

+(NSArray *)getAllContacts{
    //新建一个通讯录类
    ABAddressBookRef addressBook =  ABAddressBookCreateWithOptions(NULL, NULL);
    //获取通讯录权限
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){dispatch_semaphore_signal(sema);});
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
    if (!results) {
        return @[];
    }
    NSMutableArray *contacts = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(results)];
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        TKAddressBook *addressBook = [TKAddressBook new];
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        //读取firstname
        addressBook.firstname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        //读取lastname
        addressBook.lastname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        //读取middlename
        addressBook.middlename = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        //读取prefix前缀
        addressBook.prefix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonPrefixProperty);
        //读取suffix后缀
        addressBook.suffix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonSuffixProperty);
        //读取nickname呢称
        addressBook.nickname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNicknameProperty);
        //读取firstname拼音音标
        addressBook.firstnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty);
        //读取lastname拼音音标
        addressBook.lastnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty);
        //读取middlename拼音音标
        addressBook.middlenamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNamePhoneticProperty);
        //读取organization公司
        addressBook.organization = (__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
        //读取jobtitle工作
        addressBook.jobtitle = (__bridge NSString*)ABRecordCopyValue(person, kABPersonJobTitleProperty);
        //读取department部门
        addressBook.department = (__bridge NSString*)ABRecordCopyValue(person, kABPersonDepartmentProperty);
        //读取birthday生日
        addressBook.birthday = (__bridge NSDate*)ABRecordCopyValue(person, kABPersonBirthdayProperty);
        //读取note备忘录
        addressBook.note = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNoteProperty);
        //第一次添加该条记录的时间
        addressBook.firstknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonCreationDateProperty);
        //最后一次修改該条记录的时间
        addressBook.lastknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonModificationDateProperty);
        
        //获取email多值
        NSMutableArray *tkEmails = [NSMutableArray new];
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        long emailcount = ABMultiValueGetCount(email);
        for (int x = 0; x < emailcount; x++)
        {
            TKAddressBookEmail *tkEmail = [TKAddressBookEmail new];
            //获取email Label
            tkEmail.emailLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, x));
            //获取email值
            tkEmail.emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, x);
            [tkEmails addObject:tkEmail];
        }
        addressBook.emails = tkEmails;
        //读取地址多值
        NSMutableArray *tkAddresses = [NSMutableArray new];
        ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
        long count = ABMultiValueGetCount(address);
        
        for(int j = 0; j < count; j++)
        {
            TKAddressBookAddress *tkAddress = [TKAddressBookAddress new];
            //获取地址Label
            tkAddress.addressLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(address, j);
            //获取該label下的地址6属性
            NSDictionary* personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(address, j);
            tkAddress.country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
            tkAddress.city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
            tkAddress.state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
            tkAddress.street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
            tkAddress.zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
            tkAddress.coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
            [tkAddresses addObject:tkAddress];
        }
        addressBook.address = tkAddresses;
        
        //获取dates多值
        NSMutableArray *tkDates = [NSMutableArray new];
        ABMultiValueRef dates = ABRecordCopyValue(person, kABPersonDateProperty);
        long datescount = ABMultiValueGetCount(dates);
        for (int y = 0; y < datescount; y++)
        {
            TKAddressBookDate *tkDate = [TKAddressBookDate new];
            //获取dates Label
            tkDate.datesLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(dates, y));
            //获取dates值
            tkDate.datesContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(dates, y);
            [tkDates addObject:tkDate];
        }
        addressBook.dates = tkDates;
        //获取kind值
        CFNumberRef recordType = ABRecordCopyValue(person, kABPersonKindProperty);
        if (recordType == kABPersonKindOrganization) {
            // it's a company
            addressBook.isCompany = YES;
        } else {
            // it's a person, resource, or room
            addressBook.isCompany = NO;
        }
        
        //获取IM多值
        NSMutableArray *tkIMs = [NSMutableArray new];
        ABMultiValueRef instantMessage = ABRecordCopyValue(person, kABPersonInstantMessageProperty);
        for (int l = 1; l < ABMultiValueGetCount(instantMessage); l++)
        {
            TKAddressBookIM *tkIM = [TKAddressBookIM new];
            //获取IM Label
            tkIM.instantMessageLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(instantMessage, l);
            //获取該label下的2属性
            NSDictionary* instantMessageContent =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(instantMessage, l);
            tkIM.instantMessageContentUserName = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
            tkIM.instantMessageContentService = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
        }
        addressBook.im = tkIMs;
        
        //读取电话多值
        NSMutableArray *tkPhones = [NSMutableArray new];
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            TKAddressBookPhone *tkPhone = [TKAddressBookPhone new];
            //获取电话Label
            tkPhone.personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
            //获取該Label下的电话值
            tkPhone.personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            [tkPhones addObject:tkPhone];
        }
        addressBook.phones = tkPhones;
        
        //获取URL多值
        NSMutableArray *tkUrls = [NSMutableArray new];
        ABMultiValueRef url = ABRecordCopyValue(person, kABPersonURLProperty);
        for (int m = 0; m < ABMultiValueGetCount(url); m++)
        {
            TKAddressBookUrl *tkUrl = [TKAddressBookUrl new];
            //获取电话Label
            tkUrl.urlLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(url, m));
            //获取該Label下的电话值
            tkUrl.urlContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(url,m);
            [tkUrls addObject:tkUrl];
        }
        addressBook.urls = tkUrls;
        
        //读取照片
        NSData *image = (__bridge NSData*)ABPersonCopyImageData(person);
        addressBook.image = [UIImage imageWithData:image];
        [contacts addObject:addressBook];
    }
    
    CFRelease(results);
    CFRelease(addressBook);
    
    return contacts;
}

@end
