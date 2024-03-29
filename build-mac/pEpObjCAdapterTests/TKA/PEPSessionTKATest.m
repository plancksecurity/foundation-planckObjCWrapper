//
//  PEPSessionTKATest.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 19.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

@import PEPObjCAdapter;

#import "PEPTKATestDelegate.h"
#import "PEPTestUtils.h"

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

// MARK: - Tests

- (void)testSimpleTKACallback {
    PEPSession *session = [PEPSession new];
    XCTestExpectation *expDelegateCalled = [self expectationWithDescription:@"expDelegateCalled"];
    XCTestExpectation *expDealloced = [self expectationWithDescription:@"expDealloced"];
    PEPTKATestDelegate *delegate = [[PEPTKATestDelegate alloc]
                                    initExpKeyChangedCalled:expDelegateCalled
                                    expDealloced:expDealloced];

    NSError *error = nil;
    XCTAssertTrue([self tkaSubscribeSession:session keychangeDelegate:delegate error:&error]);
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
    XCTAssertTrue([self tkaRequestTempKeyWithSession:session me:me partner:other error:&error]);
    XCTAssertNil(error);

    [self waitForExpectations:@[expDelegateCalled] timeout:PEPTestInternalFastTimeout];

    XCTAssertNotNil(delegate.keyReceived);

    // NOTE: 256 bits is the expected key size currently produced by the *mock*.
    // Bound to change any time.
    XCTAssertEqual([delegate.keyReceived length], 256/8);

    // now owned by the adapter
    delegate = nil;

    error = nil;
    XCTAssertTrue([self tkaSubscribeSession:session keychangeDelegate:nil error:&error]);
    XCTAssertNil(error);

    [self waitForExpectations:@[expDealloced] timeout:PEPTestInternalFastTimeout];
}

// MARK: - Internal Helpers

- (void)pEpCleanUp {
    [PEPTestUtils cleanUp];
}

/// Synchronizes the async version from `PEPSession`.
- (BOOL)tkaSubscribeSession:(PEPSession * _Nonnull)session
          keychangeDelegate:(id<PEPTKADelegate> _Nullable)delegate
                      error:(NSError * _Nullable * _Nullable)error {
    __block NSError *errorResult = nil;
    __block BOOL success = NO;
    XCTestExpectation *expDelegateSet = [self expectationWithDescription:@"expDelegateSet"];

    [session tkaSubscribeWithKeychangeDelegate:delegate
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

    [self waitForExpectations:@[expDelegateSet] timeout:PEPTestInternalFastTimeout];

    return success;
}

/// Synchronizes the async version from `PEPSession`.
- (BOOL)tkaRequestTempKeyWithSession:(PEPSession * _Nonnull)session
                                  me:(PEPIdentity *)me partner:(PEPIdentity *)partner
                               error:(NSError * _Nullable * _Nullable)error {
    __block NSError *errorResult = nil;
    __block BOOL success = NO;
    XCTestExpectation *expDelegateSet = [self expectationWithDescription:@"expDelegateSet"];

    [session tkaRequestTempKeyForMe:me
                            partner:partner
                      errorCallback:^(NSError * _Nonnull error) {
        errorResult = error;
        success = NO;
        [expDelegateSet fulfill];
    }
                 successCallback:^{
        success = YES;
        [expDelegateSet fulfill];
    }];

    [self waitForExpectations:@[expDelegateSet] timeout:PEPTestInternalFastTimeout];

    return success;
}

@end
