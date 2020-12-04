//
//  PEPSessionTest.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 18.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPObjCAdapterTypes_iOS.h"
#import "PEPObjCAdapter_iOS.h"

#import "NSNumber+PEPRating.h"
#import "PEPTestUtils.h"
#import "PEPSessionProvider.h"
#import "PEPInternalSession.h"

@interface PEPSessionTest : XCTestCase

@end

@implementation PEPSessionTest

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

    PEPSession *asyncSession = [PEPSession new];

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
                           PEPDecryptFlags flags,
                           BOOL isFormerlyEncryptedReuploadedMessage) {
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

    PEPSession *asyncSession = [PEPSession new];

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

- (void)testIdentityRatingTrustResetMistrustUndo
{
    PEPIdentity *me = [[PEPIdentity alloc]
                       initWithAddress:@"me@example.org"
                       userID:@"me_myself"
                       userName:@"Me Me"
                       isOwn:YES];

    NSError *error = nil;
    me = [self mySelf:me error:&error];
    XCTAssertNotNil(me);
    XCTAssertNil(error);

    XCTAssertNotNil(me.fingerPrint);
    XCTAssertEqual([self ratingForIdentity:me], PEPRatingTrustedAndAnonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice], PEPRatingReliable);

    XCTAssertTrue([self trustPersonalKey:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice], PEPRatingTrusted);

    XCTAssertTrue([self keyResetTrust:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice], PEPRatingReliable);

    XCTAssertTrue([self keyMistrusted:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice], PEPRatingHaveNoKey);
}

- (void)testQueryKeySyncOnOwnIdentityInALoop
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

    for (NSNumber *numBool in @[@YES, @NO]) {
        error = nil;
        if ([numBool boolValue]) {
            XCTAssertTrue([self enableSyncForIdentity:identMe error:&error]);
        } else {
            XCTAssertTrue([self disableSyncForIdentity:identMe error:&error]);
        }
        XCTAssertNil(error);

        for (int i = 0; i < 10; ++i) {
            NSNumber *numQuery = [self queryKeySyncEnabledForIdentity:identMe error:&error];
            XCTAssertNotNil(numQuery);
            XCTAssertEqualObjects(numBool, numQuery);
            XCTAssertNil(error);
        }
    }
}

- (void)testGetLogWithError
{
    NSError *error = nil;
    NSString *log = [self getLogWithError:&error];
    XCTAssertGreaterThan(log.length, 0);
    XCTAssertNotNil(log);
    XCTAssertNil(error);
}

- (void)testGetTrustwords
{
    PEPIdentity *partner1Orig = [[PEPIdentity alloc]
                                 initWithAddress:@"partner1@dontcare.me" userID:@"partner1"
                                 userName:@"partner1"
                                 isOwn:NO fingerPrint:@"F0CD3F7B422E5D587ABD885BF2D281C2789DD7F6"];

    PEPIdentity *meOrig = [[PEPIdentity alloc]
                           initWithAddress:@"me@dontcare.me" userID:@"me"
                           userName:@"me"
                           isOwn:NO fingerPrint:@"CC1F73F6FB774BF08B197691E3BFBCA9248FC681"];

    NSError *error = nil;
    NSString *trustwordsFull = [self getTrustwordsIdentity1:meOrig identity2:partner1Orig
                                                   language:@"en" full:YES error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(trustwordsFull,
                          @"EMERSON GASPER TOKENISM BOLUS COLLAGE DESPISE BEDDED ENCRYPTION IMAGINE BEDFORD");

    NSString *trustwordsUndefined = [self getTrustwordsIdentity1:meOrig identity2:partner1Orig
                                                        language:@"ZZ" full:YES error:&error];
    XCTAssertNotNil(error);
    XCTAssertNil(trustwordsUndefined);
}

- (void)testGenKey
{
    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"pep.test.iosgenkey@pep-project.org"
                            userID:@"Me"
                            userName:@"pEp Test iOS GenKey"
                            isOwn:YES];

    NSError *error = nil;
    identMe = [self mySelf:identMe error:&error];
    XCTAssertNotNil(identMe);
    XCTAssertNil(error);

    XCTAssertNotNil(identMe.fingerPrint);
    XCTAssertNotEqual(identMe.commType, PEPCommTypeUnknown);

    NSNumber *boolNum = [self isPEPUser:identMe error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(boolNum);
    XCTAssertTrue(boolNum.boolValue);
}

- (void)testTrustOwnKey
{
    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];
    NSError *error = nil;
    me = [self mySelf:me error:&error];
    XCTAssertNotNil(me);
    XCTAssertNil(error);

    XCTAssertTrue([self trustOwnKeyIdentity:me error:&error]);
    XCTAssertNil(error);
}

- (void)testKeyResetIdentityOnOwnKeyIsIllegal
{
    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];

    NSError *error = nil;
    me = [self mySelf:me error:&error];
    XCTAssertNotNil(me);
    XCTAssertNil(error);

    NSString *fprOriginal = me.fingerPrint;
    XCTAssertNotNil(fprOriginal);

    // Cannot reset all _own_ keys with this method, as documented
    XCTAssertFalse([self keyReset:me fingerprint:nil error:&error]);
    XCTAssertNotNil(error);

    me = [self mySelf:me error:&error];
    XCTAssertNotNil(me);
    XCTAssertNil(error);

    NSString *fprAfterReset = me.fingerPrint;
    XCTAssertNotNil(fprAfterReset);

    XCTAssertNotEqual(fprOriginal, fprAfterReset);
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

    PEPSession *asyncSession = [PEPSession new];

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

    NSNumber *ratingPreview = [[PEPSessionProvider session]
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
    PEPSession *asyncSession = [PEPSession new];

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
    PEPSession *asyncSession = [PEPSession new];

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
    PEPSession *asyncSession = [PEPSession new];

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
    PEPSession *asyncSession = [PEPSession new];

    XCTestExpectation *expMyself = [self expectationWithDescription:@"expMyself"];
    __block PEPIdentity *identityMyselfed = nil;
    __block NSError *errorMyself = nil;
    [asyncSession mySelf:identity
           errorCallback:^(NSError * _Nonnull theError) {
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
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSArray<NSString *> *result = nil;
    __block NSError *theError = nil;
    [asyncSession trustwordsForFingerprint:fingerprint
                                languageID:languageID
                                 shortened:shortened
                             errorCallback:^(NSError * _Nonnull error) {
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
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *expUpdateIdent = [self expectationWithDescription:@"expUpdateIdent"];
    __block PEPIdentity *identTestUpdated = nil;
    __block NSError *theError = nil;
    [asyncSession updateIdentity:identity
                   errorCallback:^(NSError * _Nonnull error) {
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
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSNumber *result = nil;
    __block NSError *theError = nil;
    [asyncSession outgoingRatingForMessage:theMessage
                             errorCallback:^(NSError * _Nonnull error) {
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
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block PEPMessage *result = nil;
    __block NSError *theError = nil;
    [asyncSession encryptMessage:message
                       extraKeys:extraKeys
                       encFormat:encFormat
                   errorCallback:^(NSError * _Nonnull error) {
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
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block PEPMessage *result = nil;
    __block NSError *theError = nil;
    [asyncSession encryptMessage:message
                       extraKeys:extraKeys
                   errorCallback:^(NSError * _Nonnull error) {
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
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession trustPersonalKey:identity
                     errorCallback:^(NSError * _Nonnull error) {
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
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession keyResetTrust:identity
                  errorCallback:^(NSError * _Nonnull error) {
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

- (BOOL)keyMistrusted:(PEPIdentity *)identity error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession keyMistrusted:identity
                  errorCallback:^(NSError * _Nonnull error) {
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

- (BOOL)enableSyncForIdentity:(PEPIdentity * _Nonnull)identity
                        error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession enableSyncForIdentity:identity
                  errorCallback:^(NSError * _Nonnull error) {
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

- (NSNumber * _Nullable)queryKeySyncEnabledForIdentity:(PEPIdentity * _Nonnull)identity
                                                 error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSNumber *result = nil;
    __block NSError *theError = nil;
    [asyncSession queryKeySyncEnabledForIdentity:identity
                                   errorCallback:^(NSError * _Nonnull error) {
        result = nil;
        theError = error;
        [exp fulfill];
    } successCallback:^(BOOL enabled) {
        result = [NSNumber numberWithBool:enabled];
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)disableSyncForIdentity:(PEPIdentity * _Nonnull)identity
                         error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession disableSyncForIdentity:identity
                           errorCallback:^(NSError * _Nonnull error) {
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

- (NSString * _Nullable)getLogWithError:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSString *result = nil;
    __block NSError *theError = nil;
    [asyncSession getLog:^(NSError * _Nonnull error) {
        result = nil;
        theError = error;
        [exp fulfill];
    } successCallback:^(NSString *theLog) {
        result = theLog;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (NSString * _Nullable)getTrustwordsIdentity1:(PEPIdentity * _Nonnull)identity1
                                     identity2:(PEPIdentity * _Nonnull)identity2
                                      language:(NSString * _Nullable)language
                                          full:(BOOL)full
                                         error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSString *result = nil;
    __block NSError *theError = nil;
    [asyncSession getTrustwordsIdentity1:identity1
                               identity2:identity2
                                language:language
                                    full:full
                           errorCallback:^(NSError * _Nonnull error) {
        result = nil;
        theError = error;
        [exp fulfill];
    } successCallback:^(NSString * _Nonnull trustwords) {
        result = trustwords;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (NSNumber * _Nullable)isPEPUser:(PEPIdentity * _Nonnull)identity
                            error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSNumber *result = nil;
    __block NSError *theError = nil;
    [asyncSession isPEPUser:identity
              errorCallback:^(NSError * _Nonnull error) {
        result = nil;
        theError = error;
        [exp fulfill];
    } successCallback:^(BOOL enabled) {
        result = [NSNumber numberWithBool:enabled];
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)trustOwnKeyIdentity:(PEPIdentity * _Nonnull)identity
                      error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession trustOwnKeyIdentity:identity
                        errorCallback:^(NSError * _Nonnull error) {
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

- (BOOL)keyReset:(PEPIdentity * _Nonnull)identity
     fingerprint:(NSString * _Nullable)fingerprint
           error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession keyReset:identity
               fingerprint:fingerprint
             errorCallback:^(NSError * _Nonnull error) {
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
