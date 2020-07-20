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

- (void)setUp
{
    [super setUp];

    [self pEpCleanUp];

    [PEPObjCAdapter setUnEncryptedSubjectEnabled:NO];

    NSError *error = nil;
    XCTAssertTrue([PEPObjCAdapter configurePassphraseForNewKeys:nil error:&error]);
    XCTAssertNil(error);
}

- (void)tearDown
{
    [self pEpCleanUp];
    [super tearDown];
}

- (void)pEpCleanUp
{
    [PEPTestUtils cleanUp];
}

- (void)testMailToMyself
{
    XCTestExpectation *expectationKeyImported = [self
                                                 expectationWithDescription:@"expectationKeyImported"];

    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

    // Our test user:
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [PEPTestUtils asyncImportBundledKey:@"6FF00E97_sec.asc"
                                session:asyncSession
                          errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        [expectationKeyImported fulfill];
    } successCallback:^{
        [expectationKeyImported fulfill];
    }];

    [self waitForExpectations:@[expectationKeyImported] timeout:PEPTestInternalSyncTimeout];

    __block PEPIdentity *identAlice = [[PEPIdentity alloc]
                                       initWithAddress:@"pep.test.alice@pep-project.org"
                                       userID:ownUserId
                                       userName:@"pEp Test Alice"
                                       isOwn:YES
                                       fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    XCTestExpectation *expectationMyself = [self expectationWithDescription:@"expectationMyself"];

    [asyncSession mySelf:identAlice
           errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        [expectationMyself fulfill];
    } successCallback:^(PEPIdentity * _Nonnull identity) {
        [expectationMyself fulfill];
        identAlice = identity;
    }];

    [self waitForExpectations:@[expectationMyself] timeout:PEPTestInternalSyncTimeout];

    NSError *error = nil;

    PEPMessage *msg = [PEPMessage new];
    msg.from = identAlice;
    msg.to = @[identAlice];
    msg.shortMessage = @"Mail to Myself";
    msg.longMessage = @"This is a text content";
    msg.direction = PEPMsgDirectionOutgoing;

    PEPSession *session = [PEPSession new];

    XCTestExpectation *expOutgoingRating = [self expectationWithDescription:@"expOutgoingRating"];
    __block NSNumber *numRating = nil;
    [self testOutgoingRatingForMessage:msg
                               session:session
                          asyncSession:asyncSession
                         errorCallback:^(NSError *error) {
        XCTFail();
        [expOutgoingRating fulfill];
    } successCallback:^(PEPRating rating) {
        numRating = [NSNumber numberWithPEPRating:rating];
        [expOutgoingRating fulfill];
    }];

    [self waitForExpectations:@[expOutgoingRating] timeout:PEPTestInternalSyncTimeout];

    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingTrustedAndAnonymized);

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
     extraKeys:nil
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

- (void)testEncryptAndAttachPrivateKeyIllegalValue
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(identMe.fingerPrint);

    NSString *fprAlice = @"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97";
    PEPIdentity *identAlice = [self
                               checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                               address:@"pep.test.alice@pep-project.org"
                               userID:@"alice_user_id"
                               fingerPrint:fprAlice
                               session: session];
    XCTAssertNotNil(identAlice);
    XCTAssertEqualObjects(identAlice.fingerPrint, fprAlice);

    NSString *shortMessage = @"whatever it may be";
    NSString *longMessage = [NSString stringWithFormat:@"%@ %@", shortMessage, shortMessage];
    PEPMessage *message = [PEPMessage new];
    message.from = identMe;
    message.to = @[identAlice];
    message.shortMessage = shortMessage;
    message.longMessage = longMessage;

    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

    XCTestExpectation *expectationEncrypted = [self
                                               expectationWithDescription:@"expectationEncrypted"];

    [asyncSession
     encryptMessage:message
     toFpr:fprAlice
     encFormat:PEPEncFormatPEP
     flags:0
     errorCallback:^(NSError * _Nonnull error) {
        [expectationEncrypted fulfill];
    } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
        XCTFail();
        [expectationEncrypted fulfill];
    }];

    [self waitForExpectations:@[expectationEncrypted] timeout:PEPTestInternalSyncTimeout];
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

- (void)testOutgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                             session:(PEPSession *)session
                        asyncSession:(PEPAsyncSession *)asyncSession
                       errorCallback:(void (^)(NSError *error))errorCallback
                     successCallback:(void (^)(PEPRating rating))successCallback;
{
    XCTestExpectation *expOutgoingRating = [self expectationWithDescription:@"expOutgoingRating"];
    __block NSNumber *ratingOriginal = nil;
    __block NSError *error = nil;
    [asyncSession outgoingRatingForMessage:theMessage
                             errorCallback:^(NSError * _Nonnull theError) {
        XCTFail();
        error = theError;
        [expOutgoingRating fulfill];
    } successCallback:^(PEPRating rating) {
        ratingOriginal = [NSNumber numberWithInt:rating];
        [expOutgoingRating fulfill];
    }];

    [self waitForExpectations:@[expOutgoingRating] timeout:PEPTestInternalSyncTimeout];

    if (error) {
        errorCallback(error);
    } else {
        NSError *errorPreview = nil;
        NSNumber *ratingPreview = [session
                                   outgoingRatingPreviewForMessage:theMessage
                                   error:&errorPreview];
        XCTAssertNil(errorPreview);
        XCTAssertNotNil(ratingPreview);
        XCTAssertEqual(ratingOriginal, ratingPreview);
        if (errorPreview) {
            errorCallback(errorPreview);
        } else {
            successCallback(ratingOriginal.pEpRating);
        }
    }
}

- (PEPIdentity *)checkImportingKeyFilePath:(NSString *)filePath address:(NSString *)address
                                    userID:(NSString *)userID
                               fingerPrint:(NSString *)fingerPrint
                                   session:(PEPSession *)session
{
    if (!session) {
        session = [PEPSession new];
    }

    BOOL success = [PEPTestUtils importBundledKey:filePath session:session];
    XCTAssertTrue(success);

    if (success) {
        // Our test user:
        PEPIdentity *identTest = [[PEPIdentity alloc]
                                  initWithAddress:address
                                  userID:userID
                                  userName:[NSString stringWithFormat:@"Some User Name %@", userID]
                                  isOwn:NO];

        NSError *error = nil;
        XCTAssertTrue([session updateIdentity:identTest error:&error]);
        XCTAssertNil(error);
        XCTAssertNotNil(identTest.fingerPrint);
        XCTAssertEqualObjects(identTest.fingerPrint, fingerPrint);

        return identTest;
    } else {
        return nil;
    }
}

@end
