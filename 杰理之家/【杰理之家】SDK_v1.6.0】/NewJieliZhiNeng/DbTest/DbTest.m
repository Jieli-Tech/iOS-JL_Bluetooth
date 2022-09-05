//
//  DbTest.m
//  DbTest
//
//  Created by EzioChan on 2022/7/7.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DhaSqlite.h"
#import <JL_BLEKit/JL_BLEKit.h>

@interface DbTest : XCTestCase

@end

@implementation DbTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    DhaFittingSql *fitSql = [DhaFittingSql new];
    fitSql.type = LeftFitter;
    fitSql.recordName = @"2022年07月07日17:56:33";
    fitSql.isFinish = YES;
    fitSql.recordDate = [NSDate new];
    fitSql.recordList = @[@(12.0),@(23.0)];
    [[DhaSqlite share] update:fitSql];
    
    
}


-(void)speexTest {
    JL_ManagerM *manager =  [[JL_ManagerM alloc] init];
    [manager.mLrcManager cmdLrcMonitorResult:^(NSString * _Nullable lrc, JL_LRCType type) {
       //TODO:
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
