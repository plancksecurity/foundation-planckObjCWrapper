//
//  PEPIdentityTests.m
//  PEPObjCAdapterTypesTests_macOS
//
//  Created by David Alarcon on 26/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPIdentityTest.h"

@interface PEPIdentityTests : XCTestCase
@property (nonatomic, strong) PEPIdentityTest  *identity;
@property (nonatomic, strong) PEPIdentityTest *unarchivedIdentity;
@end

@implementation PEPIdentityTests

- (void)setUp {
    [super setUp];

    self.identity = [PEPIdentityTest new];

    XCTAssertNotNil(self.identity, "PEPIdentity should not be nil.");

    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.identity
                                         requiringSecureCoding:YES
                                                         error:&error];

    XCTAssertNil(error, "Error archiving pEp Identity.");

    self.unarchivedIdentity = [NSKeyedUnarchiver unarchivedObjectOfClass:[PEPIdentity class]
                                                                fromData:data
                                                                   error:&error];

    XCTAssertNil(error, "Error unarchiving pEp Identity.");
}

- (void)tearDown {

    [super tearDown];
}

- (void)testConformsSecureCodingProtocol {
    XCTAssertTrue([self.identity conformsToProtocol:@protocol(NSSecureCoding)]);
}

- (void)testSupportsSecureCodingProtocol {
    XCTAssertTrue([PEPIdentity supportsSecureCoding]);
}

- (void)testIdentityAddress {
    XCTAssertEqualObjects(self.identity.address, self.unarchivedIdentity.address);
}

- (void)testIdentityUserID {
    XCTAssertEqualObjects(self.identity.userID, self.unarchivedIdentity.userID);
}

- (void)testIdentityFingerprint {
    XCTAssertEqualObjects(self.identity.fingerPrint, self.unarchivedIdentity.fingerPrint);
}

- (void)testIdentityLanguage {
    XCTAssertEqualObjects(self.identity.language, self.unarchivedIdentity.language);
}

- (void)testIdentityCommType {
    XCTAssertEqual(self.identity.commType, self.unarchivedIdentity.commType);
}

- (void)testIdentityIsOwn {
    XCTAssertEqual(self.identity.isOwn, self.unarchivedIdentity.isOwn);
}

- (void)testIdentityFlags {
    XCTAssertEqual(self.identity.flags, self.unarchivedIdentity.flags);
}

@end
