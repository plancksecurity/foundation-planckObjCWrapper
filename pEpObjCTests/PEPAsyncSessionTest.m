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
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

    // Our test user:
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    XCTAssertTrue([self importBundledKey:@"6FF00E97_sec.asc" asyncSession:asyncSession]);

    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:ownUserId
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    NSError *error = nil;

    XCTestExpectation *expMyself = [self expectationWithDescription:@"expMyself"];
    __block PEPIdentity *identAliceMyselfed = nil;
    [asyncSession mySelf:identAlice
           errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        [expMyself fulfill];
    } successCallback:^(PEPIdentity * _Nonnull identity) {
        identAliceMyselfed = identity;
        [expMyself fulfill];
    }];
    [self waitForExpectations:@[expMyself] timeout:PEPTestInternalSyncTimeout];
    XCTAssertNotNil(identAliceMyselfed);

    PEPMessage *msg = [PEPMessage new];
    msg.from = identAlice;
    msg.to = @[identAlice];
    msg.shortMessage = @"Mail to Myself";
    msg.longMessage = @"This is a text content";
    msg.direction = PEPMsgDirectionOutgoing;

    NSNumber *numRating = [self
                           testOutgoingRatingForMessage:msg
                           asyncSession:asyncSession
                           error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingTrustedAndAnonymized);

    for (NSNumber *boolNumWithEncFormat in @[@YES, @NO]) {
        XCTestExpectation *expectationEnc = [self expectationWithDescription:@"expectationEnc"];
        __block PEPMessage *encryptedMessage = [PEPMessage new];
        if (boolNumWithEncFormat.boolValue) {
            [asyncSession
             encryptMessage:msg
             extraKeys:nil
             encFormat:PEPEncFormatPEP
             errorCallback:^(NSError * _Nonnull error) {
                XCTFail();
                [expectationEnc fulfill];
            } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
                [expectationEnc fulfill];
                encryptedMessage = destMessage;
            }];
            [self waitForExpectations:@[expectationEnc] timeout:PEPTestInternalSyncTimeout];
        } else {
            [asyncSession encryptMessage:msg extraKeys:nil errorCallback:^(NSError * _Nonnull error) {
                XCTFail();
                [expectationEnc fulfill];
            } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
                [expectationEnc fulfill];
                encryptedMessage = destMessage;
            }];
            [self waitForExpectations:@[expectationEnc] timeout:PEPTestInternalSyncTimeout];
        }

        XCTestExpectation *expectationDec = [self expectationWithDescription:@"expectationDec"];
        [asyncSession
         decryptMessage:encryptedMessage
         flags:0
         extraKeys:nil
         errorCallback:^(NSError *error) {
            XCTFail();
            [expectationDec fulfill];
        }
         successCallback:^(PEPMessage * srcMessage,
                           PEPMessage * dstMessage,
                           PEPStringList * keyList,
                           PEPRating rating,
                           PEPDecryptFlags flags) {
            XCTAssertNotNil(dstMessage);
            XCTAssertEqual(rating, PEPRatingTrustedAndAnonymized);
            [expectationDec fulfill];
        }];
        [self waitForExpectations:@[expectationDec] timeout:PEPTestInternalSyncTimeout];
    }
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
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

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
                               fingerPrint:fprAlice];
    XCTAssertNotNil(identAlice);
    XCTAssertEqualObjects(identAlice.fingerPrint, fprAlice);

    NSString *shortMessage = @"whatever it may be";
    NSString *longMessage = [NSString stringWithFormat:@"%@ %@", shortMessage, shortMessage];
    PEPMessage *message = [PEPMessage new];
    message.from = identMe;
    message.to = @[identAlice];
    message.shortMessage = shortMessage;
    message.longMessage = longMessage;

    XCTestExpectation *expectationEnc = [self expectationWithDescription:@"expectationEnc"];

    [asyncSession
     encryptMessage:message
     toFpr:fprAlice
     encFormat:PEPEncFormatPEP
     flags:0
     errorCallback:^(NSError * _Nonnull error) {
        [expectationEnc fulfill];
    } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
        XCTFail();
        [expectationEnc fulfill];
    }];

    [self waitForExpectations:@[expectationEnc] timeout:PEPTestInternalSyncTimeout];
}

- (void)testRatingForIdentity
{
    /*
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

    PEPIdentity *me = [self
                       checkMySelfImportingKeyFilePath:@"6FF00E97_sec.asc"
                       address:@"pep.test.alice@pep-project.org"
                       userID:@"Alice_User_ID"
                       fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                       session:session];
    XCTAssertEqual([self ratingForIdentity:me], PEPRatingTrustedAndAnonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice], PEPRatingReliable);
     */
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

    XCTestExpectation *expectationEnc = [self expectationWithDescription:@"expectationEnc"];

    __block PEPMessage *encryptedMessage = [PEPMessage new];

    [asyncSession
     encryptMessage:mail
     forSelf:me
     extraKeys:nil
     errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        [expectationEnc fulfill];
    } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
        encryptedMessage = destMessage;
        [expectationEnc fulfill];
    }];

    [self waitForExpectations:@[expectationEnc] timeout:PEPTestInternalSyncTimeout];

    return encryptedMessage;
}

- (NSNumber * _Nullable)testOutgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                                        asyncSession:(PEPAsyncSession *)asyncSession
                                               error:(NSError * _Nullable * _Nullable)error
{
    __block NSError *theError = nil;
    __block NSNumber *ratingOriginal = nil;
    XCTestExpectation *expOutgoingRating = [self expectationWithDescription:@"expOutgoingRating"];
    [asyncSession outgoingRatingForMessage:theMessage
                             errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        theError = error;
        [expOutgoingRating fulfill];
    } successCallback:^(PEPRating rating) {
        [expOutgoingRating fulfill];
        ratingOriginal = [NSNumber numberWithPEPRating:rating];
    }];
    [self waitForExpectations:@[expOutgoingRating] timeout:PEPTestInternalSyncTimeout];

    if (theError) {
        *error = theError;
        return nil;
    }

    NSNumber *ratingPreview = [[PEPSession new]
                               outgoingRatingPreviewForMessage:theMessage
                               error:error];
    XCTAssertEqual(ratingOriginal, ratingPreview);

    return ratingOriginal;
}

- (PEPIdentity *)checkImportingKeyFilePath:(NSString *)filePath address:(NSString *)address
                                    userID:(NSString *)userID
                               fingerPrint:(NSString *)fingerPrint
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

    BOOL success = [self importBundledKey:filePath asyncSession:asyncSession];
    XCTAssertTrue(success);

    if (success) {
        // Our test user:
        PEPIdentity *identTest = [[PEPIdentity alloc]
                                  initWithAddress:address
                                  userID:userID
                                  userName:[NSString stringWithFormat:@"Some User Name %@", userID]
                                  isOwn:NO];

        XCTestExpectation *expUpdateIdent = [self expectationWithDescription:@"expUpdateIdent"];
        __block PEPIdentity *identTestUpdated = nil;
        [asyncSession updateIdentity:identTest
                       errorCallback:^(NSError * _Nonnull error) {
            XCTFail();
            [expUpdateIdent fulfill];
        } successCallback:^(PEPIdentity * _Nonnull identity) {
            identTestUpdated = identity;
            [expUpdateIdent fulfill];
        }];
        [self waitForExpectations:@[expUpdateIdent] timeout:PEPTestInternalSyncTimeout];

        XCTAssertNotNil(identTestUpdated);
        XCTAssertNotNil(identTestUpdated.fingerPrint);
        XCTAssertEqualObjects(identTestUpdated.fingerPrint, fingerPrint);

        return identTestUpdated;
    } else {
        return nil;
    }
}

- (BOOL)importBundledKey:(NSString *)item asyncSession:(PEPAsyncSession *)asyncSession
{
    if (!asyncSession) {
        asyncSession = [PEPAsyncSession new];
    }

    NSString *txtFileContents = [PEPTestUtils loadStringFromFileName:item];
    if (!txtFileContents) {
        XCTFail();
    }

    __block BOOL success = YES;

    XCTestExpectation *expImport = [self expectationWithDescription:@"expImport"];
    [asyncSession importKey:txtFileContents
              errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        success = NO;
        [expImport fulfill];
    } successCallback:^(NSArray<PEPIdentity *> * _Nonnull identities) {
        [expImport fulfill];
        success = YES;
    }];

    [self waitForExpectations:@[expImport] timeout:PEPTestInternalSyncTimeout];

    return success;
}

- (PEPRating)ratingForIdentity:(PEPIdentity *)identity
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

    __block PEPRating resultingRating = PEPRatingB0rken;

    XCTestExpectation *expRated = [self expectationWithDescription:@"expRated"];
    [asyncSession ratingForIdentity:identity
                      errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        [expRated fulfill];
    } successCallback:^(PEPRating rating) {
        [expRated fulfill];
    }];
    [self waitForExpectations:@[expRated] timeout:PEPTestInternalSyncTimeout];

    return resultingRating;
}

- (PEPIdentity * _Nullable)checkMySelfImportingKeyFilePath:(NSString *)filePath
                                                   address:(NSString *)address
                                                    userID:(NSString *)userID
                                               fingerPrint:(NSString *)fingerPrint
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

    XCTAssertTrue([self importBundledKey:filePath asyncSession:asyncSession]);

    // Our test user:
    PEPIdentity *identTest = [[PEPIdentity alloc]
                              initWithAddress:address
                              userID:userID
                              userName:[NSString stringWithFormat:@"Some User Name %@", userID]
                              isOwn:YES
                              fingerPrint: fingerPrint];

    __block BOOL success = NO;
    XCTestExpectation *expSetOwnKey = [self expectationWithDescription:@"expSetOwnKey"];
    [asyncSession setOwnKey:identTest
                fingerprint:fingerPrint
              errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        success = NO;
        [expSetOwnKey fulfill];
    } successCallback:^{
        success = YES;
        [expSetOwnKey fulfill];
    }];

    if (success) {
        return identTest;
    } else {
        return nil;
    }
}

@end
