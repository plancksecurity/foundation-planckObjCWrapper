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
    // Our test user:
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    XCTAssertTrue([self importBundledKey:@"6FF00E97_sec.asc"]);

    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:ownUserId
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

    NSError *error = nil;
    PEPIdentity *identAliceMyselfed = [self mySelf:identAlice error:&error];
    XCTAssertNotNil(identAliceMyselfed);
    XCTAssertNil(error);

    PEPMessage *msg = [PEPMessage new];
    msg.from = identAlice;
    msg.to = @[identAlice];
    msg.shortMessage = @"Mail to Myself";
    msg.longMessage = @"This is a text content";
    msg.direction = PEPMsgDirectionOutgoing;

    error = nil;
    NSNumber *numRating = [self testOutgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingTrustedAndAnonymized);

    for (NSNumber *boolNumWithEncFormat in @[@YES, @NO]) {
        error = nil;
        PEPMessage *encryptedMessage = [PEPMessage new];
        if (boolNumWithEncFormat.boolValue) {
            encryptedMessage = [self
                                encryptMessage:msg
                                extraKeys:nil
                                encFormat:PEPEncFormatPEP
                                status:nil
                                error:&error];
            XCTAssertNotNil(encryptedMessage);
            XCTAssertNil(error);
        } else {
            encryptedMessage = [self encryptMessage:msg extraKeys:nil status:nil error:&error];
            XCTAssertNotNil(encryptedMessage);
            XCTAssertNil(error);
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
    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];

    NSError *error = nil;
    identMe = [self mySelf:identMe error:&error];
    XCTAssertNotNil(identMe);
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

    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

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
    PEPIdentity *me = [self
                       checkMySelfImportingKeyFilePath:@"6FF00E97_sec.asc"
                       address:@"pep.test.alice@pep-project.org"
                       userID:@"Alice_User_ID"
                       fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];
    XCTAssertNotNil(me);
    XCTAssertEqual([self ratingForIdentity:me], PEPRatingTrustedAndAnonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];
    XCTAssertNotNil(alice);

    XCTAssertEqual([self ratingForIdentity:alice], PEPRatingReliable);
}

- (void)testTrustWords
{
    NSError *error = nil;
    NSArray *trustwords = [self
                           trustwordsForFingerprint:@"DB47DB47DB47DB47DB47DB47DB47DB47DB47DB47"
                           languageID:@"en"
                           shortened:false
                           error:&error];
    XCTAssertNil(error);
    XCTAssertEqual([trustwords count], 10);

    for(id word in trustwords) {
        XCTAssertEqualObjects(word, @"BAPTISMAL");
    }
}

#pragma mark - Helpers

- (PEPMessage *)mailWrittenToMySelf
{
    // Write a e-mail to yourself ...
    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];

    NSError *error = nil;
    me = [self mySelf:me error:&error];
    XCTAssertNotNil(me);
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
                                               error:(NSError * _Nullable * _Nullable)error
{
    NSError *theError = nil;
    NSNumber *ratingOriginal = [self outgoingRatingForMessage:theMessage error:&theError];
    XCTAssertNotNil(ratingOriginal);
    XCTAssertNil(theError);

    if (ratingOriginal == nil) {
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
    BOOL success = [self importBundledKey:filePath];
    XCTAssertTrue(success);

    if (success) {
        // Our test user:
        PEPIdentity *identTest = [[PEPIdentity alloc]
                                  initWithAddress:address
                                  userID:userID
                                  userName:[NSString stringWithFormat:@"Some User Name %@", userID]
                                  isOwn:NO];

        NSError *error = nil;
        PEPIdentity *identTestUpdated = [self updateIdentity:identTest error:&error];

        XCTAssertNil(error);
        XCTAssertNotNil(identTestUpdated);
        XCTAssertNotNil(identTestUpdated.fingerPrint);
        XCTAssertEqualObjects(identTestUpdated.fingerPrint, fingerPrint);

        return identTestUpdated;
    } else {
        return nil;
    }
}

- (BOOL)importBundledKey:(NSString *)item
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

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

- (PEPIdentity * _Nullable)checkMySelfImportingKeyFilePath:(NSString *)filePath
                                                   address:(NSString *)address
                                                    userID:(NSString *)userID
                                               fingerPrint:(NSString *)fingerPrint
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

    XCTAssertTrue([self importBundledKey:filePath]);

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

    [self waitForExpectations:@[expSetOwnKey] timeout:PEPTestInternalSyncTimeout];

    if (success) {
        return identTest;
    } else {
        return nil;
    }
}

#pragma mark - Normal session to async

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
        resultingRating = rating;
        [expRated fulfill];
    }];
    [self waitForExpectations:@[expRated] timeout:PEPTestInternalSyncTimeout];

    return resultingRating;
}

- (PEPIdentity * _Nullable)mySelf:(PEPIdentity * _Nonnull)identity
                            error:(NSError * _Nullable * _Nullable)error
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];

    XCTestExpectation *expMyself = [self expectationWithDescription:@"expMyself"];
    __block PEPIdentity *identityMyselfed = nil;
    __block NSError *errorMyself = nil;
    [asyncSession mySelf:identity
           errorCallback:^(NSError * _Nonnull theError) {
        XCTFail();
        errorMyself = theError;
        [expMyself fulfill];
    } successCallback:^(PEPIdentity * _Nonnull identity) {
        identityMyselfed = identity;
        [expMyself fulfill];
    }];
    [self waitForExpectations:@[expMyself] timeout:PEPTestInternalSyncTimeout];

    *error = errorMyself;

    XCTAssertNotNil(identityMyselfed);

    if (error) {
        *error = errorMyself;
    }

    return identityMyselfed;
}

- (NSArray<NSString *> * _Nullable)trustwordsForFingerprint:(NSString * _Nonnull)fingerprint
                                                 languageID:(NSString * _Nonnull)languageID
                                                  shortened:(BOOL)shortened
                                                      error:(NSError * _Nullable * _Nullable)error
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSArray<NSString *> *result = nil;
    __block NSError *theError = nil;
    [asyncSession trustwordsForFingerprint:fingerprint
                                languageID:languageID
                                 shortened:shortened
                             errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        theError = error;
        [exp fulfill];
    } successCallback:^(NSArray<NSString *> * _Nonnull trustwords) {
        [exp fulfill];
        result = trustwords;
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (PEPIdentity * _Nullable)updateIdentity:(PEPIdentity * _Nonnull)identity
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];
    XCTestExpectation *expUpdateIdent = [self expectationWithDescription:@"expUpdateIdent"];
    __block PEPIdentity *identTestUpdated = nil;
    __block NSError *theError = nil;
    [asyncSession updateIdentity:identity
                   errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        theError = error;
        [expUpdateIdent fulfill];
    } successCallback:^(PEPIdentity * _Nonnull identity) {
        identTestUpdated = identity;
        [expUpdateIdent fulfill];
    }];
    [self waitForExpectations:@[expUpdateIdent] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return identTestUpdated;
}

- (NSNumber * _Nullable)outgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                                           error:(NSError * _Nullable * _Nullable)error
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSNumber *result = nil;
    __block NSError *theError = nil;
    [asyncSession outgoingRatingForMessage:theMessage
                             errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        theError = error;
        [exp fulfill];
    } successCallback:^(PEPRating rating) {
        result = [NSNumber numberWithPEPRating:rating];
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                               encFormat:(PEPEncFormat)encFormat
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block PEPMessage *result = nil;
    __block NSError *theError = nil;
    [asyncSession encryptMessage:message
                       extraKeys:extraKeys
                       encFormat:encFormat
                   errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        theError = error;
        [exp fulfill];
    } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
        result = destMessage;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block PEPMessage *result = nil;
    __block NSError *theError = nil;
    [asyncSession encryptMessage:message
                       extraKeys:extraKeys
                   errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        theError = error;
        [exp fulfill];
    } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
        result = destMessage;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)trustPersonalKey:(PEPIdentity * _Nonnull)identity
                   error:(NSError * _Nullable * _Nullable)error
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession trustPersonalKey:identity
                     errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        result = NO;
        theError = error;
        [exp fulfill];
    } successCallback:^{
        result = YES;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)keyResetTrust:(PEPIdentity * _Nonnull)identity
                error:(NSError * _Nullable * _Nullable)error
{
    PEPAsyncSession *asyncSession = [PEPAsyncSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession keyResetTrust:identity
                  errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        result = NO;
        theError = error;
        [exp fulfill];
    } successCallback:^{
        result = YES;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

@end
