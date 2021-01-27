//
//  PEPAttachment_SecureCodingTest.m
//  PEPObjCAdapterTypesTests_iOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPTypesTestUtil.h"
#import "PEPAttachment+SecureCoding.h"
#import "NSObject+Extension.h"

@interface PEPAttachment_SecureCodingTest : XCTestCase
@end

@implementation PEPAttachment_SecureCodingTest

- (void)testConformsSecureCodingProtocol {
    PEPAttachment *testee = [PEPAttachment new];
    XCTAssertTrue([testee conformsToProtocol:@protocol(NSSecureCoding)]);
}

- (void)testSupportsSecureCodingProtocol {
    XCTAssertTrue([PEPAttachment supportsSecureCoding]);
}

- (void)testAttachmentData {
    PEPAttachment *testee = [PEPTypesTestUtil pEpAttachmentWithAllFieldsFilled];
    PEPAttachment *unarchivedTestee = [self archiveAndUnarchiveAttachment:testee];

    XCTAssertEqualObjects(testee.data, unarchivedTestee.data);
}

- (void)testAttachmentSize {
    PEPAttachment *testee = [PEPTypesTestUtil pEpAttachmentWithAllFieldsFilled];
    PEPAttachment *unarchivedTestee = [self archiveAndUnarchiveAttachment:testee];

    XCTAssertEqual(testee.size, unarchivedTestee.size);
}

- (void)testAttachmentMimeType {
    PEPAttachment *testee = [PEPTypesTestUtil pEpAttachmentWithAllFieldsFilled];
    PEPAttachment *unarchivedTestee = [self archiveAndUnarchiveAttachment:testee];

    XCTAssertEqualObjects(testee.mimeType, unarchivedTestee.mimeType);
}

- (void)testAttachmentFilename {
    PEPAttachment *testee = [PEPTypesTestUtil pEpAttachmentWithAllFieldsFilled];
    PEPAttachment *unarchivedTestee = [self archiveAndUnarchiveAttachment:testee];

    XCTAssertEqualObjects(testee.filename, unarchivedTestee.filename);
}

- (void)testAttachmentContentDisposition {
    PEPAttachment *testee = [PEPTypesTestUtil pEpAttachmentWithAllFieldsFilled];
    PEPAttachment *unarchivedTestee = [self archiveAndUnarchiveAttachment:testee];

    XCTAssertEqual(testee.contentDisposition, unarchivedTestee.contentDisposition);
}

// MARK: - Helper

- (PEPAttachment *)archiveAndUnarchiveAttachment:(PEPAttachment *)attachment {
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:attachment
                                         requiringSecureCoding:YES
                                                         error:&error];
    XCTAssertNotNil(data, "Error archiving pEp attachment.");

    PEPAttachment *unarchivedAttachment = [NSKeyedUnarchiver unarchivedObjectOfClass:[PEPAttachment class]
                                                                            fromData:data
                                                                               error:&error];
    XCTAssertNotNil(unarchivedAttachment, "Error unarchiving pEp attachment.");

    return unarchivedAttachment;
}

@end

@implementation PEPAttachment (Equalable)

/**
 The keys that should be used to decide `isEqual`.
 */
static NSArray *s_keys;

- (BOOL)isEqualToPEPAttachment:(PEPAttachment * _Nonnull)attachment {
    return [self isEqualToObject:attachment basedOnKeys:s_keys];
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }

    return [self isEqualToPEPAttachment:object];
}

@end
