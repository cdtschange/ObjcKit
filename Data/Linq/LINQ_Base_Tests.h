//
//  LINQ_Base_Tests.h
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 22/06/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import "LINQ.h"

#define TEST_PASS assertThatBool(YES, equalToBool(YES));
#define TEST_FAIL STFail(@"Test not implemented.");
#define TEST_NOT_IMPLEMENTED STFail(@"Test not implemented.");
