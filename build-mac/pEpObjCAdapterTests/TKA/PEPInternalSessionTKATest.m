//
//  PEPInternalSessionTKATest.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 19.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPObjCAdapter.h"

#import "PEPTestUtils.h"
#import "PEPSessionProvider.h"
#import "PEPInternalSession+TKA.h"
#import "PEPTKATestDelegate.h"
#import "PEPTestUtils.h"

@interface PEPInternalSessionTKATest : XCTestCase

@end

/// @note These tests work as long as the TKA implementation is completely mocked, and _may_ work
///   (whole or partly)  even with the real engine implementation.
@implementation PEPInternalSessionTKATest

// MARK: - Setup, teardown etc.

- (void)setUp {
    [super setUp];
    [self pEpCleanUp];
}

- (void)tearDown {
    [self pEpCleanUp];
    [super tearDown];
}

// MARK: - Tests

- (void)testSimpleTKACallback {
    PEPInternalSession *session = [PEPSessionProvider session];
    XCTestExpectation *expDelegateCalled = [self expectationWithDescription:@"expDelegateCalled"];
    XCTestExpectation *expDealloced = [self expectationWithDescription:@"expDealloced"];
    PEPTKATestDelegate *delegate = [[PEPTKATestDelegate alloc]
                                    initExpKeyChangedCalled:expDelegateCalled
                                    expDealloced:expDealloced];

    NSError *error = nil;
    XCTAssertTrue([session tkaSubscribeKeychangeDelegate:delegate error:&error]);
    XCTAssertNil(error);

    // now owned by the adapter
    delegate = nil;

    PEPIdentity *me = [[PEPIdentity alloc]
                       initWithAddress:@"me@example.org"
                       userID:@"me_myself"
                       userName:@"Me Me"
                       isOwn:YES];

    PEPIdentity *other = [[PEPIdentity alloc]
                          initWithAddress:@"other@example.org"
                          userID:@"other_not_myself"
                          userName:@"Other_Other"
                          isOwn:NO];

    error = nil;
    XCTAssertTrue([session tkaRequestTempKeyMe:me partner:other error:&error]);
    XCTAssertNil(error);

    [self waitForExpectations:@[expDelegateCalled] timeout:PEPTestInternalFastTimeout];

    error = nil;
    XCTAssertTrue([session tkaSubscribeKeychangeDelegate:nil error:&error]);
    XCTAssertNil(error);

    [self waitForExpectations:@[expDealloced] timeout:PEPTestInternalFastTimeout];
}

// MARK: - Internal Helpers

- (void)pEpCleanUp {
    [PEPTestUtils cleanUp];
}

@end
