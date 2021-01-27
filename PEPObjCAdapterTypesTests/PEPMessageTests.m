//
//  PEPMessageTests.m
//  PEPObjCAdapterTypesTests_macOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPMessageTest.h"
#import "PEPAttachmentTest.h"

@interface PEPMessageTests : XCTestCase
@property (nonatomic, strong) PEPMessageTest *message;
@property (nonatomic, strong) PEPMessageTest *unarchivedMessage;
@end

@implementation PEPMessageTests

- (void)setUp {
    [super setUp];

    self.message = [PEPMessageTest new];

    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.message
                                         requiringSecureCoding:YES
                                                         error:&error];

    XCTAssertNil(error, "Error archiving pEp message.");

    self.unarchivedMessage = [NSKeyedUnarchiver unarchivedObjectOfClass:[PEPMessageTest class]
                                                               fromData:data
                                                                  error:&error];

    XCTAssertNil(error, "Error unarchiving pEp message.");
}

- (void)testConformsSecureCodingProtocol {
    XCTAssertTrue([self.message conformsToProtocol:@protocol(NSSecureCoding)]);
}

- (void)testSupportsSecureCodingProtocol {
    XCTAssertTrue([PEPMessageTest supportsSecureCoding]);
}

- (void)testMessageMessageID {
    XCTAssertEqualObjects(self.message.messageID, self.unarchivedMessage.messageID);
}

- (void)testMessageFrom {
    XCTAssertEqualObjects(self.message.from, self.unarchivedMessage.from);
}

- (void)testMessageTo {
    XCTAssertEqualObjects(self.message.to, self.unarchivedMessage.to);
}

- (void)testMessageCC {
    XCTAssertEqualObjects(self.message.cc, self.unarchivedMessage.cc);
}

- (void)testMessageBCC {
    XCTAssertEqualObjects(self.message.bcc, self.unarchivedMessage.bcc);
}

- (void)testMessageShortMessage {
    XCTAssertEqualObjects(self.message.shortMessage, self.unarchivedMessage.shortMessage);
}

- (void)testMessageLongMessage {
    XCTAssertEqualObjects(self.message.longMessage, self.unarchivedMessage.longMessage);
}

- (void)testMessageLongMessageFormatted {
    XCTAssertEqualObjects(self.message.longMessageFormatted,
                          self.unarchivedMessage.longMessageFormatted);
}

- (void)testMessageReplyTo {
    XCTAssertEqualObjects(self.message.replyTo, self.unarchivedMessage.replyTo);
}

- (void)testMessageInReplyTo {
    XCTAssertEqualObjects(self.message.inReplyTo, self.unarchivedMessage.inReplyTo);
}

- (void)testMessageReferences {
    XCTAssertEqualObjects(self.message.references, self.unarchivedMessage.references);
}

- (void)testMessageSentDate {
    XCTAssertEqualObjects(self.message.sentDate, self.unarchivedMessage.sentDate);
}

- (void)testMessageReceivedDate {
    XCTAssertEqualObjects(self.message.receivedDate, self.unarchivedMessage.receivedDate);
}

- (void)testMessageAttachments {
    XCTAssertEqualObjects(self.message.attachments, self.unarchivedMessage.attachments);
}

- (void)testMessageOptionalFields {
    XCTAssertEqualObjects(self.message.optionalFields, self.unarchivedMessage.optionalFields);
}

- (void)testMessageKeywords {
    XCTAssertEqualObjects(self.message.keywords, self.unarchivedMessage.keywords);
}

- (void)testMessageReceivedBy {
    XCTAssertEqualObjects(self.message.receivedBy, self.unarchivedMessage.receivedBy);
}

- (void)testMessageDirection {
    XCTAssertEqual(self.message.direction, self.unarchivedMessage.direction);
}

@end
