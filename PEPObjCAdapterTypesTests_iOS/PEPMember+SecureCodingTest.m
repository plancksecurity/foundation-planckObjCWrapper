//
//  PEPMember+SecureCodingTest.m
//  PEPObjCAdapterTypesTests_iOS
//
//  Created by Dirk Zimmermann on 16.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPTypesTestUtil.h"
#import "PEPMember.h"
#import "PEPMember+SecureCoding.h"
#import "XCTestCase+Archive.h"

@interface PEPMember_SecureCodingTest : XCTestCase

@end

@implementation PEPMember_SecureCodingTest

- (void)testConformsSecureCodingProtocol
{
    PEPMember *testee = [PEPMember new];

    XCTAssertTrue([testee conformsToProtocol:@protocol(NSSecureCoding)]);
}

- (void)testSupportsSecureCodingProtocol
{
    XCTAssertTrue([PEPMember supportsSecureCoding]);
}

- (void)testArchiveUnarchive
{
    PEPMember *testee = [PEPTypesTestUtil pEpMemberWithAllFieldsFilled];
    PEPMember *unarchivedTestee = (PEPMember *) [self archiveAndUnarchiveObject:testee
                                                                        ofClass:[PEPMember class]];

    XCTAssertEqualObjects(testee, unarchivedTestee);
}

@end
