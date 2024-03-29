//
//  PEPIdentityComparisonTest.m
//  PEPObjCTypeUtilsTests_macOS
//
//  Created by Martín Brude on 14/2/22.
//

#import <XCTest/XCTest.h>
#import "PEPObjCTypes.h"

@interface PEPIdentityComparisonTest : XCTestCase

@end

NSString *uppercaseAddress = @"ADDRESS";
NSString *camelcaseAddress = @"Address";
NSString *lowercaseAddress = @"address";
NSString *differentAddress = @"differentAddress";

@implementation PEPIdentityComparisonTest

- (void)testIdentityComparisonWithSameAddress {
    PEPIdentity *identity = [[PEPIdentity alloc] initWithAddress:uppercaseAddress];
    PEPIdentity *otherIdentity = [[PEPIdentity alloc] initWithAddress:uppercaseAddress];
    XCTAssertTrue([identity isEqual:otherIdentity]);
}

- (void)testIdentityComparisonWithCamelcaseAddress {
    PEPIdentity *identity = [[PEPIdentity alloc] initWithAddress:uppercaseAddress];
    PEPIdentity *otherIdentity = [[PEPIdentity alloc] initWithAddress:camelcaseAddress];
    XCTAssertTrue([identity isEqual:otherIdentity]);
}

- (void)testIdentityComparisonWithLowercaseAddress {
    PEPIdentity *identity = [[PEPIdentity alloc] initWithAddress:uppercaseAddress];
    PEPIdentity *otherIdentity = [[PEPIdentity alloc] initWithAddress:lowercaseAddress];
    XCTAssertTrue([identity isEqual:otherIdentity]);
}

- (void)testIdentityComparisonWithDifferentAddress {
    PEPIdentity *identity = [[PEPIdentity alloc] initWithAddress:uppercaseAddress];
    PEPIdentity *otherIdentity = [[PEPIdentity alloc] initWithAddress:differentAddress];
    XCTAssertFalse([identity isEqual:otherIdentity]);
}

- (void)testIdentityComparisonWithNoAddress {
    PEPIdentity *identity = [[PEPIdentity alloc] init];
    PEPIdentity *otherIdentity = [[PEPIdentity alloc] init];
    XCTAssertTrue([identity isEqual:otherIdentity]);
}

@end
