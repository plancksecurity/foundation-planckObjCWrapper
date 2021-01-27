//
//  PEPIdentityTests.m
//  PEPObjCAdapterTypesTests_macOS
//
//  Created by David Alarcon on 26/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPIdentity+SecureCoding.h"

@interface PEPIdentityTests : XCTestCase

@end

@implementation PEPIdentityTests

- (void)testConformsSecureCodingProtocol {
    PEPIdentity *testee = [PEPIdentity new];
    XCTAssertTrue([testee conformsToProtocol:@protocol(NSSecureCoding)]);
}

- (void)testSupportsSecureCodingProtocol {
    XCTAssertTrue([PEPIdentity supportsSecureCoding]);
}

- (void)testIdentityAddress {
    PEPIdentity *testee = [self identityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqualObjects(testee.address, unarchivedTestee.address);
}

- (void)testIdentityUserID {
    PEPIdentity *testee = [self identityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqualObjects(testee.userID, unarchivedTestee.userID);
}

- (void)testIdentityFingerprint {
    PEPIdentity *testee = [self identityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqualObjects(testee.fingerPrint, unarchivedTestee.fingerPrint);
}

- (void)testIdentityLanguage {
    PEPIdentity *testee = [self identityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqualObjects(testee.language, unarchivedTestee.language);
}

- (void)testIdentityCommType {
    PEPIdentity *testee = [self identityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqual(testee.commType, unarchivedTestee.commType);
}

- (void)testIdentityIsOwn {
    PEPIdentity *testee = [self identityWithAllFieldsFilled];
    PEPIdentity *unarchivedTestee = [self archiveAndUnarchiveIdentity:testee];

    XCTAssertEqual(testee.isOwn, unarchivedTestee.isOwn);
}

- (void)testIdentityFlags {
    PEPIdentity *testee = [self identityWithAllFieldsFilled];
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

- (PEPIdentity *)identityWithAllFieldsFilled {
    PEPIdentity *identity = [PEPIdentity new];

    identity.address = @"test@host.com";
    identity.userID = @"pEp_own_userId";
    identity.fingerPrint = @"184C1DE2D4AB98A2A8BB7F23B0EC5F483B62E19D";
    identity.language = @"cat";
    identity.commType = PEPCommTypePEP;
    identity.isOwn = YES;
    identity.flags = PEPIdentityFlagsNotForSync;

    return identity;
}

@end
