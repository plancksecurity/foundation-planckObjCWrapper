//
//  PEPMessageASN1Tests.m
//  pEpCCTests
//
//  Created by Dirk Zimmermann on 26.08.21.
//

#import <XCTest/XCTest.h>

#import "PEPMessage+ASN1.h"
#import "PEPObjCTypes.h"

@interface PEPMessageASN1Tests : XCTestCase

@end

@implementation PEPMessageASN1Tests

/// Encodes and decodes a "minimal" message, that is a message with the minimum amount of data
/// needed to get encoded/decoded.
- (void)testBasicAsn1EncodeDecodeRoundTripMinimalMessageFakeFingerprint
{
    PEPIdentity *fromId = [[PEPIdentity alloc]
                           initWithAddress:@"someone1@example.com"
                           userID:@"1"
                           userName:@"Some One 1"
                           isOwn:NO];
    fromId.fingerPrint = @"0E12343434343434343434EAB3484343434343434";

    PEPIdentity *toId = [[PEPIdentity alloc]
                         initWithAddress:@"someone2@example.com"
                         userID:@"2"
                         userName:@"Some One 2"
                         isOwn:NO];
    toId.fingerPrint = @"123434343434343C3434343434343734349A34344";

    PEPMessage *msg1 = [PEPMessage new];
    msg1.from = fromId;
    msg1.to = @[toId];

    NSData *blob = [msg1 asn1Data];
    XCTAssertNotNil(blob);

    PEPMessage *msg2 = [PEPMessage messageFromAsn1Data:blob];
    XCTAssertNotNil(msg2);

    XCTAssertEqualObjects(msg1, msg2);
}

/// Encodes and decodes a "minimal" message, that is a message with the minimum amount of data
/// needed to get encoded/decoded, with fingerprint set to nil.
- (void)testBasicAsn1EncodeDecodeRoundTripMinimalMessageNilFingerprint
{
    PEPIdentity *fromId = [[PEPIdentity alloc]
                           initWithAddress:@"someone1@example.com"
                           userID:@"1"
                           userName:@"Some One 1"
                           isOwn:NO];
    fromId.fingerPrint = nil;

    PEPIdentity *toId = [[PEPIdentity alloc]
                         initWithAddress:@"someone2@example.com"
                         userID:@"2"
                         userName:@"Some One 2"
                         isOwn:NO];
    toId.fingerPrint = nil;

    PEPMessage *msg1 = [PEPMessage new];
    msg1.from = fromId;
    msg1.to = @[toId];

    NSData *blob = [msg1 asn1Data];
    XCTAssertNotNil(blob);

    PEPMessage *msg2 = [PEPMessage messageFromAsn1Data:blob];
    XCTAssertNotNil(msg2);

    XCTAssertEqualObjects(msg1, msg2);
}

/// Encodes and decodes a "minimal" message, that is a message with the minimum amount of data
/// needed to get encoded/decoded, with fingerprint set to the empty string.
- (void)testBasicAsn1EncodeDecodeRoundTripMinimalMessageEmptyFingerprint
{
    PEPIdentity *fromId = [[PEPIdentity alloc]
                           initWithAddress:@"someone1@example.com"
                           userID:@"1"
                           userName:@"Some One 1"
                           isOwn:NO];
    fromId.fingerPrint = @"";

    PEPIdentity *toId = [[PEPIdentity alloc]
                         initWithAddress:@"someone2@example.com"
                         userID:@"2"
                         userName:@"Some One 2"
                         isOwn:NO];
    toId.fingerPrint = @"";

    PEPMessage *msg1 = [PEPMessage new];
    msg1.from = fromId;
    msg1.to = @[toId];

    NSData *blob = [msg1 asn1Data];
    XCTAssertNotNil(blob);

    PEPMessage *msg2 = [PEPMessage messageFromAsn1Data:blob];
    XCTAssertNotNil(msg2);

    XCTAssertEqualObjects(msg1, msg2);
}

// TODO: Re-enable with ENGINE-970 having been fixed.
- (void)testBasicAsn1EncodeDecodeRoundTripMessageWithAttachment
{
    PEPIdentity *fromId = [[PEPIdentity alloc]
                           initWithAddress:@"someone1@example.com"
                           userID:@"1"
                           userName:@"Some One 1"
                           isOwn:NO];
    fromId.fingerPrint = @"0E12343434343434343434EAB3484343434343434";

    PEPIdentity *toId = [[PEPIdentity alloc]
                         initWithAddress:@"someone2@example.com"
                         userID:@"2"
                         userName:@"Some One 2"
                         isOwn:NO];
    toId.fingerPrint = @"123434343434343C3434343434343734349A34344";

    NSData *randomData = [self randomDataWithLength:5000];
    PEPAttachment *attachment = [[PEPAttachment alloc]
                                 initWithData:randomData];
    attachment.mimeType = @"application/pgp-keys";
    attachment.filename = @"key.asc";

    PEPMessage *msg1 = [PEPMessage new];
    msg1.from = fromId;
    msg1.to = @[toId];
    msg1.attachments = @[attachment];

    NSData *blob = [msg1 asn1Data];
    XCTAssertNotNil(blob);

    PEPMessage *msg2 = [PEPMessage messageFromAsn1Data:blob];
    XCTAssertNotNil(msg2);

    XCTAssertEqualObjects(msg1, msg2);
    XCTAssertEqual(msg1.attachments.count, msg2.attachments.count);
}

 // TODO: Engine test case. Re-enable with ENGINE-970 having been fixed, verify, and then remove.
- (void)testCaseAsnEncodeMessageAttachment
{
    XCTAssertTrue(testCaseAsnEncodeMessageAttachment());
}

#pragma mark - Private Helpers

- (NSData *)randomDataWithLength:(NSUInteger)length
{
    NSMutableData *mutableData = [NSMutableData dataWithLength:length];

    for (NSInteger i = 0; i < length; ++i) {
        ((char *) mutableData.mutableBytes)[i] = arc4random();
    }

    return [NSData dataWithData:mutableData];
}

@end
