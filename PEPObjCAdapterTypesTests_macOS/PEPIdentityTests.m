//
//  PEPIdentityTests.m
//  PEPObjCAdapterTypesTests_macOS
//
//  Created by David Alarcon on 26/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPIdentityMock.h"

@interface PEPIdentityTests : XCTestCase
@property (nonatomic, strong) PEPIdentityMock  *identity;
@property (nonatomic, strong) PEPIdentityMock *unarchivedIdentity;
@end

@implementation PEPIdentityTests

- (void)setUp {
    [super setUp];

    self.identity = [PEPIdentityMock new];

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

@end
