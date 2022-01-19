//
//  PEPSessionTKATest.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 19.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPTestUtils.h"
#import "PEPTKATestDelegate.h"
#import "PEPSession.h"

@interface PEPSessionTKATest : XCTestCase

@end

@implementation PEPSessionTKATest

- (void)setUp {
    [super setUp];
    [self pEpCleanUp];
}

- (void)tearDown {
    [self pEpCleanUp];
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

// MARK: - Internal Helpers

- (void)pEpCleanUp {
    [PEPTestUtils cleanUp];
}

/// Synchronizes the async version in `PEPSession`.
- (BOOL)tkaSubscribeSession:(PEPSession * _Nonnull)session
          keychangeDelegate:(id<PEPTKADelegate> _Nullable)delegate
                      error:(NSError * _Nullable * _Nullable)error {
    __block NSError *errorResult = nil;
    __block BOOL success = NO;
    XCTestExpectation *expDelegateSet = [self expectationWithDescription:@"expDelegateSet"];

    [session tkaSubscribeKeychangeDelegate:delegate
                             errorCallback:^(NSError * _Nonnull error) {
        errorResult = error;
        success = NO;
        [expDelegateSet fulfill];
    }
                           successCallback:^{
        success = YES;
        [expDelegateSet fulfill];
    }];

    if (error) {
        *error = errorResult;
    }
    return success;
}

@end
