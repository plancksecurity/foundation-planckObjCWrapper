//
//  PEPMessage+SecureCodingTest.m
//  PEPObjCTypesTests_iOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPMessage+SecureCoding.h"

#import "PEPTypesTestUtil.h"
#import "PEPIdentity.h"
#import "PEPAttachment.h"
#import "NSObject+Equality.h"

@interface PEPMessage_SecureCodingTest : XCTestCase
@end

@implementation PEPMessage_SecureCodingTest

- (void)testConformsSecureCodingProtocol {
    PEPMessage *testee = [PEPMessage new];

    XCTAssertTrue([testee conformsToProtocol:@protocol(NSSecureCoding)]);
}

- (void)testSupportsSecureCodingProtocol {
    XCTAssertTrue([PEPMessage supportsSecureCoding]);
}

- (void)testMessageMessageID {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.messageID, unarchivedTestee.messageID);
}

- (void)testMessageFrom {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.from, unarchivedTestee.from);
}

- (void)testMessageTo {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.to, unarchivedTestee.to);
}

- (void)testMessageCC {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.cc, unarchivedTestee.cc);
}

- (void)testMessageBCC {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.bcc, unarchivedTestee.bcc);
}

- (void)testMessageShortMessage {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.shortMessage, unarchivedTestee.shortMessage);
}

- (void)testMessageLongMessage {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.longMessage, unarchivedTestee.longMessage);
}

- (void)testMessageLongMessageFormatted {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.longMessageFormatted, unarchivedTestee.longMessageFormatted);
}

- (void)testMessageReplyTo {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.replyTo, unarchivedTestee.replyTo);
}

- (void)testMessageInReplyTo {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.inReplyTo, unarchivedTestee.inReplyTo);
}

- (void)testMessageReferences {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.references, unarchivedTestee.references);
}

- (void)testMessageSentDate {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.sentDate, unarchivedTestee.sentDate);
}

- (void)testMessageReceivedDate {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.receivedDate, unarchivedTestee.receivedDate);
}

- (void)testMessageAttachments {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.attachments, unarchivedTestee.attachments);
}

- (void)testMessageOptionalFields {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.optionalFields, unarchivedTestee.optionalFields);
}

- (void)testMessageKeywords {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.keywords, unarchivedTestee.keywords);
}

- (void)testMessageReceivedBy {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqualObjects(testee.receivedBy, unarchivedTestee.receivedBy);
}

- (void)testMessageDirection {
    PEPMessage *testee = [PEPTypesTestUtil pEpMessageWithAllFieldsFilled];
    PEPMessage *unarchivedTestee = [self archiveAndUnarchiveMessage:testee];

    XCTAssertEqual(testee.direction, unarchivedTestee.direction);
}

// MARK: - Helper

- (PEPMessage *)archiveAndUnarchiveMessage:(PEPMessage *)message {
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message
                                         requiringSecureCoding:YES
                                                         error:&error];
    XCTAssertNotNil(data, "Error archiving pEp message.");

    PEPMessage *unarchivedMessage = [NSKeyedUnarchiver unarchivedObjectOfClass:[PEPMessage class]
                                                                         fromData:data
                                                                            error:&error];
    XCTAssertNotNil(unarchivedMessage, "Error unarchiving pEp message.");

    return unarchivedMessage;
}

@end

@implementation PEPAttachment (Equatable)

- (BOOL)isEqualToPEPAttachment:(PEPAttachment * _Nonnull)attachment {
    NSArray *s_keys = @[@"data", @"size", @"mimeType", @"filename", @"contentDisposition"];

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
