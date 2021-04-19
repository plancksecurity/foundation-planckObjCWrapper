//
//  PEPGroup+SecureCodingTest.m
//  PEPObjCAdapterTypesTests_iOS
//
//  Created by Dirk Zimmermann on 19.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPTypesTestUtil.h"
#import "PEPGroup.h"
#import "PEPGroup+SecureCoding.h"
#import "XCTestCase+Archive.h"

@interface PEPGroup_SecureCodingTest : XCTestCase

@end

@implementation PEPGroup_SecureCodingTest

- (void)testConformsSecureCodingProtocol
{
    PEPGroup *testee = [PEPGroup new];

    XCTAssertTrue([testee conformsToProtocol:@protocol(NSSecureCoding)]);
}

- (void)testSupportsSecureCodingProtocol
{
    XCTAssertTrue([PEPGroup supportsSecureCoding]);
}

- (void)testArchiveUnarchive
{
    PEPGroup *testee = [PEPTypesTestUtil pEpGroupWithAllFieldsFilled];
    PEPGroup *unarchivedTestee = (PEPGroup *) [self archiveAndUnarchiveObject:testee
                                                                      ofClass:[PEPGroup class]];

    XCTAssertEqualObjects(testee, unarchivedTestee);
}

@end
