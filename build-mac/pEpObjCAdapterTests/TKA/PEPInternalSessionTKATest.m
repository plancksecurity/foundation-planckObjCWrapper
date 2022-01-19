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

@interface PEPInternalSessionTKATest : XCTestCase

@end

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
    PEPTKATestDelegate *delegate = [[PEPTKATestDelegate alloc]
                                    initExpectationKeyChangedCalled:expDelegateCalled];
    NSError *error = nil;
    XCTAssertTrue([session tkaSubscribeKeychangeDelegate:delegate error:&error]);
    XCTAssertNil(error);

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

    [self waitForExpectations:@[expDelegateCalled] timeout:0];
}

// MARK: - Internal Helpers

- (void)pEpCleanUp {
    [PEPTestUtils cleanUp];
}

@end
