//
//  PEPAsyncSessionTest.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 18.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPObjCAdapterFramework.h"

#import "PEPTestUtils.h"

@interface PEPAsyncSessionTest : XCTestCase

@end

@implementation PEPAsyncSessionTest

- (void)testMailToMyself
{
    PEPSession *session = [PEPSession new];

    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    XCTAssertTrue([PEPTestUtils importBundledKey:@"6FF00E97_sec.asc" session:session]);

    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:ownUserId
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:identAlice error:&error]);
    XCTAssertNil(error);

    PEPMessage *msg = [PEPMessage new];
    msg.from = identAlice;
    msg.to = @[identAlice];
    msg.shortMessage = @"Mail to Myself";
    msg.longMessage = @"This is a text content";
    msg.direction = PEPMsgDirectionOutgoing;

    NSNumber *numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingTrustedAndAnonymized);

    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

    XCTestExpectation *expectationEncrypted = [self
                                               expectationWithDescription:@"expectationEncrypted"];

    __block PEPMessage *encryptedMessage = [PEPMessage new];

    [asyncSession encryptMessage:msg extraKeys:nil errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        [expectationEncrypted fulfill];
    } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
        [expectationEncrypted fulfill];
        encryptedMessage = destMessage;
    }];

    [self waitForExpectations:@[expectationEncrypted] timeout:PEPTestInternalSyncTimeout];

    XCTestExpectation *expectationDecrypted = [self
                                               expectationWithDescription:@"expectationDecrypted"];

    [asyncSession
     decryptMessage:encryptedMessage
     flags:0
     extraKeys:@[]
     errorCallback:^(NSError *error) {
        XCTFail();
        [expectationDecrypted fulfill];
    }
     successCallback:^(PEPMessage * srcMessage,
                       PEPMessage * dstMessage,
                       PEPStringList * keyList,
                       PEPRating rating,
                       PEPDecryptFlags flags) {
        XCTAssertNotNil(dstMessage);
        XCTAssertEqual(rating, PEPRatingTrustedAndAnonymized);
        [expectationDecrypted fulfill];
    }];

    [self waitForExpectations:@[expectationDecrypted] timeout:PEPTestInternalSyncTimeout];
}

- (void)testEncryptToSelf
{
    // Write mail to yourself ...
    PEPMessage *encMessage = [self mailWrittenToMySelf];

    // ... and assert subject is encrypted
    XCTAssertEqualObjects(encMessage.shortMessage, @"p≡p");
}

#pragma mark - Helpers

- (PEPMessage *)mailWrittenToMySelf
{
    PEPSession *session = [PEPSession new];

    // Write a e-mail to yourself ...
    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    NSString *shortMessage = @"Subject";
    NSString *longMessage = @"Oh, this is a long body text!";
    PEPMessage *mail = [PEPTestUtils mailFrom:me
                                      toIdent:me
                                 shortMessage:shortMessage
                                  longMessage:longMessage
                                     outgoing:YES];

    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

    XCTestExpectation *expectationEncrypted = [self
                                               expectationWithDescription:@"expectationEncrypted"];

    __block PEPMessage *encryptedMessage = [PEPMessage new];

    [asyncSession
     encryptMessage:mail
     forSelf:me
     extraKeys:nil
     errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        [expectationEncrypted fulfill];
    } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
        encryptedMessage = destMessage;
        [expectationEncrypted fulfill];
    }];

    [self waitForExpectations:@[expectationEncrypted] timeout:PEPTestInternalSyncTimeout];

    return encryptedMessage;
}

- (NSNumber * _Nullable)testOutgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                                             session:(PEPSession *)session
                                               error:(NSError * _Nullable * _Nullable)error
{
    NSNumber *ratingOriginal = [session outgoingRatingForMessage:theMessage error:error];
    NSNumber *ratingPreview = [session outgoingRatingPreviewForMessage:theMessage error:nil];
    XCTAssertEqual(ratingOriginal, ratingPreview);
    return ratingOriginal;
}

@end
