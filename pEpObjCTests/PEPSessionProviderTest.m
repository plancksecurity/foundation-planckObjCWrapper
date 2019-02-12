//
//  PEPSessionProviderTest.m
//  pEpObjCAdapterTests
//
//  Created by Andreas Buff on 17.01.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPSession.h"
#import "PEPInternalSession.h"
#import "PEPSessionProvider.h"

@interface PEPSessionProviderTest : XCTestCase

@end

@implementation PEPSessionProviderTest

- (void)tearDown
{
    [PEPSession cleanup];
}

- (void)testSeperatedSessionPerThread {
    // Get main session
    PEPInternalSession *sessionMain = [PEPSessionProvider session];
    __block PEPInternalSession *sessionBackground = nil;
    XCTestExpectation *exp = [self expectationWithDescription:@"background session created"];

    // Get background session
    dispatch_queue_t backgroundQueue = dispatch_queue_create("PEPSessionProviderTest.peptest1", 0);
    dispatch_async(backgroundQueue, ^{
        sessionBackground = [PEPSessionProvider session];
        [exp fulfill];
    });

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        if (error) { XCTFail(@"timeout: %@", error); }
    }];
    XCTAssertNotNil(sessionMain);
    XCTAssertNotNil(sessionBackground);

    // Make sure we have seperated sessions
    XCTAssertNotEqual(sessionBackground, sessionMain,
                      @"We should have seperated sessions, one per thread");
}

- (void)testMainSessionDoesNotChange {
    // Get main session
    PEPInternalSession *sessionMain = [PEPSessionProvider session];
    __block PEPInternalSession *sessionBackground = nil;
    XCTestExpectation *exp = [self expectationWithDescription:@"background session created"];

    // Get background session
    dispatch_queue_t backgroundQueue = dispatch_queue_create("PEPSessionProviderTest.peptest1", 0);
    dispatch_async(backgroundQueue, ^{
        sessionBackground = [PEPSessionProvider session];
        [exp fulfill];
    });

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        if (error) { XCTFail(@"timeout: %@", error); }
    }];
    // Get main session again
    PEPInternalSession *sessionMain2 = [PEPSessionProvider session];
    XCTAssertNotNil(sessionMain);
    XCTAssertNotNil(sessionMain2);
    XCTAssertNotNil(sessionBackground);
    XCTAssertEqual(sessionMain, sessionMain2, @"The main session stayed the same (was kept \
                   alive, was not recreated)");
}

- (void)testNewMainSessionAfterCleanup {
    // Get main session
    PEPInternalSession *sessionMain = [PEPSessionProvider session];
    __block PEPInternalSession *sessionBackground = nil;
    XCTestExpectation *exp = [self expectationWithDescription:@"background session created"];

    // Get background session
    dispatch_queue_t backgroundQueue = dispatch_queue_create("PEPSessionProviderTest.peptest1", 0);
    dispatch_async(backgroundQueue, ^{
        sessionBackground = [PEPSessionProvider session];
        [exp fulfill];
    });

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        if (error) { XCTFail(@"timeout: %@", error); }
    }];
    // Get main session again
    PEPInternalSession *sessionMain2 = [PEPSessionProvider session];
    XCTAssertNotNil(sessionMain);
    XCTAssertNotNil(sessionMain2);
    XCTAssertNotNil(sessionBackground);
    XCTAssertEqual(sessionMain, sessionMain2, @"The main session stayed the same (was kept \
                   alive, was not recreated)");
    [PEPSession cleanup];
    PEPInternalSession *sessionMainAfterCleanup = [PEPSessionProvider session];
    XCTAssertNotNil(sessionMainAfterCleanup);
    XCTAssertNotEqual(sessionMainAfterCleanup, sessionMain,
                      @"We got a new main session after cleanup");
}

@end

