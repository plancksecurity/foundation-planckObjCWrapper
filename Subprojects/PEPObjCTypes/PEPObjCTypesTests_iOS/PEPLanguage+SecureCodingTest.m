//
//  PEPLanguage+SecureCodingTest.m
//  PEPObjCTypesTests_iOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPTypesTestUtil.h"
#import "PEPLanguage.h"

@interface PEPLanguage_SecureCodingTest : XCTestCase
@end

@implementation PEPLanguage_SecureCodingTest

- (void)testConformsSecureCodingProtocol {
    PEPLanguage *testee = [PEPLanguage new];

    XCTAssertTrue([testee conformsToProtocol:@protocol(NSSecureCoding)]);
}

- (void)testSupportsSecureCodingProtocol {
    XCTAssertTrue([PEPLanguage supportsSecureCoding]);
}

- (void)testLanguageCode {
    PEPLanguage *testee = [PEPTypesTestUtil pEpLanguageWithAllFieldsFilled];
    PEPLanguage *unarchivedTestee = [self archiveAndUnarchiveLanguage:testee];

    XCTAssertEqualObjects(testee.code, unarchivedTestee.code);
}

- (void)testLanguageName {
    PEPLanguage *testee = [PEPTypesTestUtil pEpLanguageWithAllFieldsFilled];
    PEPLanguage *unarchivedTestee = [self archiveAndUnarchiveLanguage:testee];

    XCTAssertEqualObjects(testee.name, unarchivedTestee.name);
}

- (void)testLanguageSentence {
    PEPLanguage *testee = [PEPTypesTestUtil pEpLanguageWithAllFieldsFilled];
    PEPLanguage *unarchivedTestee = [self archiveAndUnarchiveLanguage:testee];

    XCTAssertEqualObjects(testee.sentence, unarchivedTestee.sentence);
}

// MARK: - Helper

- (PEPLanguage *)archiveAndUnarchiveLanguage:(PEPLanguage *)language {
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:language
                                         requiringSecureCoding:YES
                                                         error:&error];
    XCTAssertNotNil(data, "Error archiving pEp language.");

    PEPLanguage *unarchivedLanguage = [NSKeyedUnarchiver unarchivedObjectOfClass:[PEPLanguage class]
                                                                        fromData:data
                                                                           error:&error];
    XCTAssertNotNil(unarchivedLanguage, "Error unarchiving pEp language.");

    return unarchivedLanguage;
}

@end
