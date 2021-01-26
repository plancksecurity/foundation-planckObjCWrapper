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
@property (nonatomic, strong) PEPIdentity *identity;
@end

@implementation PEPIdentityTests

- (void)setUp {
    [super setUp];

    self.identity = [[PEPIdentity alloc] initWithAddress:@"test@host.com"];
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

@end
