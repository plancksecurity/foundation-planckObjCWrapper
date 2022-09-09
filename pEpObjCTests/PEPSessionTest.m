//
//  PEPSessionTest.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 18.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPObjCTypes.h"
#import "PEPObjCAdapter_iOS.h"

#import "NSNumber+PEPRating.h"
#import "PEPTestUtils.h"
#import "PEPSessionProvider.h"
#import "PEPInternalSession.h"
#import "PEPInternalSession+SetIdentity.h"
#import "XCTestCase+PEPSession.h"

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

#pragma mark - Sync/sync_reinit

- (void)testSyncReinitWithoutSyncLoop
{
    NSError *error = nil;
    [self syncReinit:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, PEPStatusStatemachineError);
}

#pragma mark - Media Key / Echo Protocol

- (void)testConfigureMediaKeys
{
    NSArray *mediaKeys = @[
        [[PEPMediaKeyPair alloc] initWithPattern:@"*@example.com"
                                     fingerprint:@"97B69752A72FC5036971F5C83AC51FA45F01DA6C"]
    ];

    PEPSession *asyncSession = [PEPSession new];

    NSError *error = nil;
    [asyncSession configureMediaKeys:mediaKeys error:&error];
    XCTAssertNil(error);
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
        XCTAssertNil(identTestUpdated.fingerPrint); // key election, no key is chosen yet

        PEPInternalSession *session = [PEPInternalSession new];
        error = nil;
        identTest.fingerPrint = fingerPrint;
        [session setIdentity:identTest error:&error];
        XCTAssertNil(error);

        identTest.fingerPrint = fingerPrint;

        identTestUpdated = [self updateIdentity:identTest error:&error];
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

@end
