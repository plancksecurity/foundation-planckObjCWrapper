//
//  PEPIdentity+SecureCodingTest.m
//  pEpObjCAdapter
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPTypesTestUtil.h"
#import "PEPIdentity+SecureCoding.h"

@interface PEPIdentity_SecureCodingTest : XCTestCase
@end

@implementation PEPIdentity_SecureCodingTest

- (void)testConformsSecureCodingProtocol {
    PEPIdentity *testee = [PEPIdentity new];

    XCTAssertTrue([testee conformsToProtocol:@protocol(NSSecureCoding)]);
}

- (void)testSupportsSecureCodingProtocol {
    XCTAssertTrue([PEPIdentity supportsSecureCoding]);
}

- (void)testIdentityAddress {
    PEPIdentity *testee = [PEPTypesTestUtil pEpIdentityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqualObjects(testee.address, unarchivedTestee.address);
}

- (void)testIdentityUserID {
    PEPIdentity *testee = [PEPTypesTestUtil pEpIdentityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqualObjects(testee.userID, unarchivedTestee.userID);
}

- (void)testIdentityFingerprint {
    PEPIdentity *testee = [PEPTypesTestUtil pEpIdentityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqualObjects(testee.fingerPrint, unarchivedTestee.fingerPrint);
}

- (void)testIdentityLanguage {
    PEPIdentity *testee = [PEPTypesTestUtil pEpIdentityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqualObjects(testee.language, unarchivedTestee.language);
}

- (void)testIdentityCommType {
    PEPIdentity *testee = [PEPTypesTestUtil pEpIdentityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqual(testee.commType, unarchivedTestee.commType);
}

- (void)testIdentityIsOwn {
    PEPIdentity *testee = [PEPTypesTestUtil pEpIdentityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqual(testee.isOwn, unarchivedTestee.isOwn);
}

- (void)testIdentityFlags {
    PEPIdentity *testee = [PEPTypesTestUtil pEpIdentityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqual(testee.flags, unarchivedTestee.flags);
}

// MARK: - Helper

- (PEPIdentity *)archiveAndUnarchiveIdentity:(PEPIdentity *)identity {
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:identity
                                         requiringSecureCoding:YES
                                                         error:&error];
    XCTAssertNotNil(data, "Error archiving pEp identity.");

    PEPIdentity *unarchivedIdentity = [NSKeyedUnarchiver unarchivedObjectOfClass:[PEPIdentity class]
                                                                fromData:data
                                                                   error:&error];
    XCTAssertNotNil(unarchivedIdentity, "Error unarchiving pEp identity.");

    return unarchivedIdentity;
}

@end
