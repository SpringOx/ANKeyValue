//
//  ANKeyValueTests.m
//  ANKeyValueTests
//
//  Created by SpringOx on 12/24/14.
//  Copyright (c) 2014 SpringOx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ANKeyValueTable.h"

@interface ANKeyValueTests : XCTestCase

@end

@implementation ANKeyValueTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.

    [super tearDown];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

- (void)testSet {

    ANKeyValueTable *table = [ANKeyValueTable tableWithName:@"SetValueTest" version:@"0.0.1" resumable:YES];
    [self measureBlock:^{
        NSString *keyStr = [NSString stringWithFormat:@"Key-IntTest"];
        [table setInt:INT32_MIN+1 withKey:keyStr];
        NSNumber *value = [table valueWithKey:keyStr];
        NSAssert1(INT32_MIN+1==[value intValue], @"int test fail", value);
        
        keyStr = [NSString stringWithFormat:@"Key-IntegerTest"];
        [table setInteger:INT32_MAX withKey:keyStr];
        value = [table valueWithKey:keyStr];
        NSAssert1(INT32_MAX==[value integerValue], @"integer test fail", value);

        keyStr = [NSString stringWithFormat:@"Key-FloatTest"];
        [table setFloat:MAXFLOAT withKey:keyStr];
        value = [table valueWithKey:keyStr];
        NSAssert1(MAXFLOAT==[[table valueWithKey:keyStr] floatValue], @"float test fail", value);
        
        keyStr = [NSString stringWithFormat:@"Key-DoubleTest"];
        [table setDouble:MAXFLOAT+MAXFLOAT withKey:keyStr];
        value = [table valueWithKey:keyStr];
        NSAssert1(MAXFLOAT+MAXFLOAT==[[table valueWithKey:keyStr] doubleValue], @"double test fail", value);
        
        keyStr = [NSString stringWithFormat:@"Key-BoolTest"];
        [table setBool:YES withKey:keyStr];
        value = [table valueWithKey:keyStr];
        NSAssert1(YES==[[table valueWithKey:keyStr] boolValue], @"bool test fail", value);
        NSAssert1(YES==[table boolWithKey:keyStr], @"bool test fail", value);
    }];
    
    while ([table isArchiving]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:3.f]];
    }
}

- (void)testGet {

    ANKeyValueTable *preTable = [ANKeyValueTable tableWithName:@"GetValueTest" version:@"0.0.1" resumable:YES];
    if (nil == [preTable valueWithKey:@"Key-GetTest1"]) {
        int count = 0;
        while (50 > ++count) {
            NSString *keyStr = [NSString stringWithFormat:@"Key-GetTest%d", count];
            [preTable setInt:count withKey:keyStr];
        }
        [preTable synchronize];
        NSAssert(0, @"data for get test is not ready");;
    }

    [self measureBlock:^{
        ANKeyValueTable *table = [ANKeyValueTable tableWithName:@"GetValueTest" version:@"0.0.1" resumable:YES];
        int count = 0;
        while (50 > ++count) {
            NSString *keyStr = [NSString stringWithFormat:@"Key-GetTest%d", count];
            NSNumber *value = [table valueWithKey:keyStr];
            NSAssert1(count==[value intValue], @"get test fail", value);
        }
    }];
}

- (void)testClear {

    ANKeyValueTable *preTable = [ANKeyValueTable tableWithName:@"ClearValueTest" version:@"0.0.1" resumable:YES];
    if (nil == [preTable valueWithKey:@"Key-ClearTest1"]) {
        int count = 0;
        while (50 > ++count) {
            NSString *keyStr = [NSString stringWithFormat:@"Key-ClearTest%d", count];
            [preTable setInt:count withKey:keyStr];
        }
        [preTable synchronize];
    }
    
    NSAssert(nil != [preTable valueWithKey:@"Key-ClearTest1"], @"data for clear test is not ready");
    [preTable removeValueWithKey:@"Key-ClearTest1"];
    NSAssert(nil == [preTable valueWithKey:@"Key-ClearTest1"], @"clear test is not passed");
    
    int count = 1;
    while (50 > ++count) {
        NSString *keyStr = [NSString stringWithFormat:@"Key-ClearTest%d", count];
        NSAssert(nil != [preTable valueWithKey:keyStr], @"data for clear test is not ready");
    }
    [preTable clear];
    count = 1;
    while (50 > ++count) {
        NSString *keyStr = [NSString stringWithFormat:@"Key-ClearTest%d", count];
        NSAssert(nil == [preTable valueWithKey:keyStr], @"clear test is not passed");
    }
}

- (void)testCrypt {
    
    ANKeyValueTable *cTable = [ANKeyValueTable tableWithName:@"CryptContentTest" version:@"0.0.1" resumable:YES];
    NSString *c1 = @"Content-CryptTest";
    [cTable encryptContent:c1 withKey:@"Key-CryptTest"];
    NSString *c2 = [cTable decryptContentWithKey:@"Key-CryptTest"];
    NSAssert([c1 isEqualToString:c2], @"crypt test is not passed");
}

- (void)testUpdateVersion {

    ANKeyValueTable *table1 = [ANKeyValueTable tableWithName:@"UpdateVersionTest" version:@"0.0.1" resumable:NO];
    if (nil == [table1 valueWithKey:@"Key-UpdateVersion"]) {
        NSString *keyStr = [NSString stringWithFormat:@"Key-UpdateVersion"];
        [table1 setValue:[NSNumber numberWithBool:YES] withKey:keyStr];
        [table1 synchronize];
        NSAssert(0, @"data for update version test is not ready");
    }
    
    ANKeyValueTable *table2 = [ANKeyValueTable tableWithName:@"UpdateVersionTest" version:@"0.1.1" resumable:NO];
    NSAssert(nil == [table2 valueWithKey:@"Key-UpdateVersion"], @"update version test is not passed");
}

- (void)testDataBlock {
    
    ANKeyValueTable *table = [ANKeyValueTable tableWithName:@"DataBlockTest" version:@"0.0.1" resumable:YES];
    if (nil == [table valueWithKey:@"Key-DataBlockTest1"]) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"];
        NSData *testData = [NSData dataWithContentsOfFile:filePath];
        [table setValue:testData withKey:@"Key-DataBlockTest1"];
        
        UIImage *testImg = [UIImage imageWithData:testData];
        [table setValue:testImg withKey:@"Key-DataBlockTest2"];
        
        [table synchronize];
        NSAssert(0, @"data for data block test is not ready");
    }

    NSData *data = [table valueWithKey:@"Key-DataBlockTest1"];
    NSAssert1([data isKindOfClass:[NSData class]], @"data block test is not passed", data);
    UIImage *image = [table valueWithKey:@"Key-DataBlockTest2"];
    NSAssert1([image isKindOfClass:[UIImage class]], @"data block test is not passed", image);
}

- (void)testContainer {
    
    ANKeyValueTable *table = [ANKeyValueTable tableWithName:@"ContainerTest" version:@"0.0.1" resumable:YES];
    if (nil == [table valueWithKey:@"Key-ContainerSet"]) {
        NSMutableSet *set = [NSMutableSet set];
        [table setContainer:set withKey:@"Key-ContainerSet"];
        
        NSMutableArray *array = [NSMutableArray array];
        [table setContainer:array withKey:@"Key-ContainerArray"];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [table setContainer:dictionary withKey:@"Key-ContainerDictionary"];
        
        [table synchronize];
        NSAssert(0, @"data for data block test is not ready");
    }
    
    NSMutableSet *set = [table containerWithKey:@"Key-ContainerSet"];
    [set addObject:@"test"];
    
    NSMutableArray *array = [table containerWithKey:@"Key-ContainerArray"];
    [array addObject:@"test"];
    
    NSMutableDictionary *dictionary = [table containerWithKey:@"Key-ContainerDictionary"];
    [dictionary setObject:@"test" forKey:@"keyValue"];
}

@end
