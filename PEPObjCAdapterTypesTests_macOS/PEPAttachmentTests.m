//
//  PEPAttachmentTests.m
//  PEPObjCAdapterTypesTests_macOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPAttachmentTest.h"

@interface PEPAttachmentTests : XCTestCase
@property (nonatomic, strong) PEPAttachmentTest *attachment;
@property (nonatomic, strong) PEPAttachmentTest *unarchivedAttachment;
@end

@implementation PEPAttachmentTests

- (void)setUp {
    [super setUp];

    self.attachment = [PEPAttachmentTest new];


    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.attachment
                                         requiringSecureCoding:YES
                                                         error:&error];

    XCTAssertNil(error, "Error archiving pEp attachment.");

    self.unarchivedAttachment = [NSKeyedUnarchiver unarchivedObjectOfClass:[PEPAttachmentTest class]
                                                                  fromData:data
                                                                     error:&error];

    XCTAssertNil(error, "Error unarchiving pEp attachment.");
}

- (void)tearDown {

    [super tearDown];
}

- (void)testConformsSecureCodingProtocol {
    XCTAssertTrue([self.attachment conformsToProtocol:@protocol(NSSecureCoding)]);
}

- (void)testSupportsSecureCodingProtocol {
    XCTAssertTrue([PEPAttachmentTest supportsSecureCoding]);
}

- (void)testAttachmentData {
    XCTAssertEqualObjects(self.attachment.data, self.unarchivedAttachment.data);
}

- (void)testAttachmentSize {
    XCTAssertEqual(self.attachment.size, self.unarchivedAttachment.size);
}

- (void)testAttachmentMimeType {
    XCTAssertEqualObjects(self.attachment.mimeType, self.unarchivedAttachment.mimeType);
}

- (void)testAttachmentFilename {
    XCTAssertEqualObjects(self.attachment.filename, self.unarchivedAttachment.filename);
}

- (void)testAttachmentContentDisposition {
    XCTAssertEqual(self.attachment.contentDisposition, self.unarchivedAttachment.contentDisposition);
}

@end
