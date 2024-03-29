//
//  PEPInternalSessionTest.m
//  pEpObjCAdapterTests
//
//  Created by Andreas Buff on 18.01.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

// Changelog
//
// 26.02.2024/DZ - Adapt tests

#import <XCTest/XCTest.h>

@import PEPObjCAdapter;

#import "PEPTestUtils.h"

#import "PEPInternalSessionTestNotifyHandshakeDelegate.h"
#import "PEPInternalSessionTestSendMessageDelegate.h"
#import "PEPPassphraseCache+Reset.h"
#import "PEPPassphraseProviderMock.h"
#import "PEPSessionProvider.h"
#import "PEPInternalSession.h"
#import "PEPIdentity+isPEPUser.h"
#import "PEPInternalSession+SetIdentity.h"

@interface PEPInternalSessionTest : XCTestCase

@property (nonatomic) PEPSync *sync;
@property (nonatomic) PEPInternalSessionTestSendMessageDelegate *sendMessageDelegate;
@property (nonatomic) PEPInternalSessionTestNotifyHandshakeDelegate *notifyHandshakeDelegate;

@end

@implementation PEPInternalSessionTest

- (void)setUp
{
    [super setUp];

    [self pEpCleanUp];

    [PEPObjCAdapter setUnEncryptedSubjectEnabled:NO];

    NSError *error = nil;
    XCTAssertTrue([PEPObjCAdapter configurePassphraseForNewKeys:nil error:&error]);
    XCTAssertNil(error);

    [PEPPassphraseCache reset];
}

- (void)tearDown
{
    [self shutdownSync];
    [self pEpCleanUp];
    [super tearDown];
}

- (void)testTrustWords
{
    PEPInternalSession *session = [PEPSessionProvider session];

    NSError *error = nil;
    NSArray *trustwords = [session
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

- (void)testGenKey
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"pep.test.iosgenkey@pep-project.org"
                            userID:@"Me"
                            userName:@"pEp Test iOS GenKey"
                            isOwn:YES];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(identMe.fingerPrint);
    XCTAssertNotEqual(identMe.commType, PEPCommTypeUnknown);

    XCTAssertTrue([identMe isPEPUser:session error:&error]);
}

- (void)testMySelfCommType
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"pep.test.iosgenkey@pep-project.org"
                            userID:@"pep.test.iosgenkey@pep-project.org_userID"
                            userName:@"pEp Test iOS GenKey"
                            isOwn:YES];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(identMe.fingerPrint);
    XCTAssertNotEqual(identMe.commType, PEPCommTypeUnknown);

    XCTAssertTrue([identMe isPEPUser:session error:&error]);

    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
    dispatch_sync(queue, ^{
        NSError *innerError = nil;
        PEPInternalSession *session2 = [PEPSessionProvider session];

        // Now simulate an update from the app, which usually only caches
        // kPepUsername, kPepAddress and optionally kPepUserID.
        PEPIdentity *identMe2 = [[PEPIdentity alloc]
                                 initWithAddress:identMe.address
                                 userID:identMe.userID
                                 userName:identMe.userName
                                 isOwn:NO];

        XCTAssertTrue([session2 mySelf:identMe2 error:&innerError]);
        XCTAssertNil(innerError);

        XCTAssertNotNil(identMe2.fingerPrint);
        XCTAssertTrue([identMe2 isPEPUser:session error:&innerError]);
        XCTAssertEqualObjects(identMe2.fingerPrint, identMe.fingerPrint);

        // Now pretend the app only knows kPepUsername and kPepAddress
        PEPIdentity *identMe3 = [PEPTestUtils foreignPepIdentityWithAddress:identMe.address
                                                                   userName:identMe.userName];
        XCTAssertTrue([session2 mySelf:identMe3 error:&innerError]);
        XCTAssertNil(innerError);

        XCTAssertNotNil(identMe3.fingerPrint);
        XCTAssertTrue([identMe3 isPEPUser:session error:&innerError]);
        XCTAssertEqualObjects(identMe3.fingerPrint, identMe.fingerPrint);

        XCTAssertEqualObjects(identMe.address, identMe2.address);
        XCTAssertEqualObjects(identMe.address, identMe3.address);
        XCTAssertEqual(identMe.commType, identMe2.commType);
        XCTAssertEqual(identMe.commType, identMe3.commType);
    });
}

- (void)testPartnerWithoutFingerPrint
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identRandom = [[PEPIdentity alloc]
                                initWithAddress:@"does_not_exist@example.com"
                                userID:@"got_out"
                                userName:@"No Way Not Even Alice"
                                isOwn:NO];

    NSError *error = nil;
    XCTAssertTrue([session updateIdentity:identRandom error:&error]);
    XCTAssertNil(error);
    XCTAssertNil(identRandom.fingerPrint);
}

- (void)testImportPartnerKeys
{
    XCTAssertNotNil([self checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                                            address:@"pep.test.alice@pep-project.org"
                                             userID:@"This Is Alice"
                                        fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                                            session: nil]);

    XCTAssertNotNil([self checkImportingKeyFilePath:@"0xC9C2EE39.asc"
                                            address:@"pep.test.bob@pep-project.org"
                                             userID:@"This Is Bob"
                                        fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"
                                            session: nil]);
}

- (void)testIdentityRating
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *me = [self
                       checkMySelfImportingKeyFilePath:@"6FF00E97_sec.asc"
                       address:@"pep.test.alice@pep-project.org"
                       userID:@"Alice_User_ID"
                       fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                       session:session];
    XCTAssertEqual([self ratingForIdentity:me session:session], PEPRatingTrustedAndAnonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingReliable);
}

/** ENGINE-409 */
- (void)testIdentityRatingMistrustReset
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *me = [[PEPIdentity alloc]
                       initWithAddress:@"me@example.org"
                       userID:@"me_myself"
                       userName:@"Me Me"
                       isOwn:YES];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(me.fingerPrint);
    XCTAssertEqual([self ratingForIdentity:me session:session], PEPRatingTrustedAndAnonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingReliable);

    XCTAssertTrue([session keyMistrusted:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingHaveNoKey);
}

- (void)testIdentityRatingTrustResetMistrustUndo
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *me = [[PEPIdentity alloc]
                       initWithAddress:@"me@example.org"
                       userID:@"me_myself"
                       userName:@"Me Me"
                       isOwn:YES];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(me.fingerPrint);
    XCTAssertEqual([self ratingForIdentity:me session:session], PEPRatingTrustedAndAnonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingReliable);

    XCTAssertTrue([session trustPersonalKey:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingTrusted);

    XCTAssertTrue([session keyResetTrust:alice error:&error]);
    XCTAssertNil(error);

    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingReliable);
}

/// This was once crashing, for historical details, see ENGINE-384.
- (void)testIdentityRatingCrash
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *me = [[PEPIdentity alloc]
                       initWithAddress:@"me@example.org"
                       userID:@"me_myself"
                       userName:@"Me Me"
                       isOwn:YES];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(me.fingerPrint);
    XCTAssertEqual([self ratingForIdentity:me session:session], PEPRatingTrustedAndAnonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingReliable);

    XCTAssertTrue([session trustPersonalKey:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingTrusted);

    XCTAssertTrue([session keyResetTrust:alice error:&error]);
    XCTAssertNil(error);

    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingReliable);
}

- (void)testOutgoingColors
{
    PEPInternalSession *session = [PEPSessionProvider session];

    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    XCTAssertTrue([PEPTestUtils importBundledKey:@"6FF00E97_sec.asc" session:session]);

    // Our test user :
    PEPIdentity *identAlice = [self
                               checkMySelfImportingKeyFilePath:@"6FF00E97_sec.asc"
                               address:@"pep.test.alice@pep-project.org"
                               userID:@"Alice_User_ID"
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                               session:session];

    //Message

    {
        PEPIdentity *identUnknownBob = [[PEPIdentity alloc]
                                        initWithAddress:@"pep.test.unknown.bob@pep-project.org"
                                        userID:@"4242" userName:@"pEp Test Bob Unknown"
                                        isOwn:NO];

        PEPMessage *msgGray = [PEPMessage new];
        msgGray.from = identAlice;
        msgGray.to = @[identUnknownBob];
        msgGray.shortMessage = @"All Gray Test";
        msgGray.longMessage = @"This is a text content";
        msgGray.direction = PEPMsgDirectionOutgoing;

        NSError *error = nil;

        // Test with unknown Bob
        NSNumber *numRating = [self
                               testOutgoingRatingForMessage:msgGray
                               session:session
                               error:&error];
        XCTAssertNotNil(numRating);
        XCTAssertNil(error);
        XCTAssertEqual(numRating.pEpRating, PEPRatingUnencrypted);
    }

    PEPIdentity *identBob = [self
                             checkImportingKeyFilePath:@"0xC9C2EE39.asc"
                             address:@"pep.test.bob@pep-project.org"
                             userID:@"42"
                             fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"
                             session: session];
    XCTAssertNotNil(identBob);

    PEPMessage *msg = [PEPMessage new];
    msg.from = identAlice;
    msg.to = @[identBob];
    msg.shortMessage = @"All Gray Test";
    msg.longMessage = @"This is a text content";
    msg.direction = PEPMsgDirectionOutgoing;

    NSError *error = nil;

    // Should be yellow, since no handshake happened.
    NSNumber *numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingReliable);

    PEPRating rating = [self ratingForIdentity:identBob session:session];
    XCTAssertEqual(rating, PEPRatingReliable);

    // Let' say we got that handshake, set PEP_ct_confirmed in Bob's identity
    XCTAssertTrue([session trustPersonalKey:identBob error:&error]);
    XCTAssertNil(error);

    // This time it should be green
    numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingTrusted);

    rating = [self ratingForIdentity:identBob session:session];
    XCTAssertEqual(rating, PEPRatingTrusted);

    // Let' say we undo handshake
    XCTAssertTrue([session keyResetTrust:identBob error:&error]);
    XCTAssertNil(error);

    // Yellow ?
    numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);

    // key_reset_trust makes the key not being elected anymore?
    
    // mistrust Bob
    XCTAssertTrue([session keyMistrusted:identBob error:&error]);
    XCTAssertNil(error);

    identBob.fingerPrint = nil;
    XCTAssertTrue([session updateIdentity:identBob error:&error]);
    XCTAssertNil(error);
    XCTAssertNil(identBob.fingerPrint);

    // Gray == PEPRatingUnencrypted
    numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingUnencrypted);
}


- (void)testOutgoingBccColors
{
    PEPInternalSession *session = [PEPSessionProvider session];

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
    msg.to = @[[[PEPIdentity alloc] initWithAddress:@"pep.test.bob@pep-project.org"
                                             userID:@"42" userName:@"pEp Test Bob" isOwn:NO]];
    msg.shortMessage = @"All Green Test";
    msg.longMessage = @"This is a text content";
    msg.direction = PEPMsgDirectionOutgoing;

    // Test with unknown Bob
    PEPRating rating;
    NSNumber *numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingUnencrypted);

    // Now let see with bob's pubkey already known
    // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
    // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
    PEPIdentity *identBob = [self
                             checkImportingKeyFilePath:@"0xC9C2EE39.asc"
                             address:@"pep.test.bob@pep-project.org"
                             userID:@"42"
                             fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"
                             session:session];
    XCTAssertNotNil(identBob);

    XCTAssertTrue([session updateIdentity:identBob error:&error]);
    XCTAssertNil(error);

    // `setIdentity` has already been called by the import, so message rating should be reliable.
    numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingReliable);

    // Identity rating is also already reliable, since setIdentity has been called already.
    rating = [self ratingForIdentity:identBob session:session];
    XCTAssertEqual(rating, PEPRatingReliable);

    // Let' say we got that handshake, set PEP_ct_confirmed in Bob's identity
    XCTAssertTrue([session trustPersonalKey:identBob error:&error]);
    XCTAssertNil(error);

    // This time it should be green
    numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingTrusted);

    rating = [self ratingForIdentity:identBob session:session];
    XCTAssertEqual(rating, PEPRatingTrusted);

    // Now let see if it turns back yellow if we add an unconfirmed folk.

    // pEp Test John (test key, don't use) <pep.test.john@pep-project.org>
    // AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575
    PEPIdentity *identJohn = [self
                              checkImportingKeyFilePath:@"0x70DCF575.asc"
                              address:@"pep.test.john@pep-project.org"
                              userID:@"This Is John"
                              fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"
                              session: session];
    XCTAssertNotNil(identJohn);

    // check john's rating
    rating = [self ratingForIdentity:identJohn session:session];
    XCTAssertEqual(rating, PEPRatingReliable);

    // Adding bcc is still reliable
    msg.bcc = @[identJohn];
    numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingReliable);

    XCTAssertTrue([session trustPersonalKey:identJohn error:&error]);
    XCTAssertNil(error);

    // This time it should be green
    numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingTrusted);

    rating = [self ratingForIdentity:identJohn session:session];
    XCTAssertEqual(rating, PEPRatingTrusted);
}

- (void)testDontEncryptForMistrusted
{
    PEPInternalSession *session = [PEPSessionProvider session];

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

    // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
    // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
    PEPIdentity *identBob = [self
                             checkImportingKeyFilePath:@"0xC9C2EE39.asc"
                             address:@"pep.test.bob@pep-project.org"
                             userID:@"This Is Bob"
                             fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"
                             session: session];
    XCTAssertNotNil(identBob);

    XCTAssertTrue([session updateIdentity:identBob error:&error]);
    XCTAssertNil(error);

    // mistrust Bob
    XCTAssertTrue([session keyMistrusted:identBob error:&error]);
    XCTAssertNil(error);

    PEPMessage *msg = [PEPMessage new];
    msg.from = identAlice;
    msg.to = @[[[PEPIdentity alloc] initWithAddress:@"pep.test.bob@pep-project.org" userID:@"42"
                                           userName:@"pEp Test Bob" isOwn:NO]];
    msg.shortMessage = @"All Green Test";
    msg.longMessage = @"This is a text content";
    msg.direction = PEPMsgDirectionOutgoing;

    // Gray == PEPRatingUnencrypted
    NSNumber *numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingUnencrypted);

    PEPMessage *encMsg = [session encryptMessage:msg extraKeys:nil status:nil error:&error];
    XCTAssertNotNil(encMsg);
    XCTAssertNil(error);

    XCTAssertNotEqualObjects(encMsg.attachments[0].mimeType, @"application/pgp-encrypted");

    [self pEpCleanUp];
}

- (void)testRevoke
{
    PEPInternalSession *session = [PEPSessionProvider session];

    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    XCTAssertTrue([PEPTestUtils importBundledKey:@"6FF00E97_sec.asc" session:session]);
    NSString *fpr = @"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97";

    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:ownUserId
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:fpr];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:identAlice error:&error]);
    XCTAssertNil(error);

    PEPIdentity *identAlice2 = [identAlice mutableCopy];

    // This will revoke key
    XCTAssertTrue([session keyMistrusted:identAlice2 error:&error]);
    XCTAssertNil(error);
    identAlice2.fingerPrint = nil;

    XCTAssertTrue([session mySelf:identAlice error:&error]);
    XCTAssertNil(error);

    // Check fingerprint is different
    XCTAssertNotEqualObjects(identAlice2.fingerPrint, fpr);
}

- (void)testMailToMyself
{
    PEPInternalSession *session = [PEPSessionProvider session];

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
    msg.attachments = @[];

    NSNumber *numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingTrustedAndAnonymized);

    PEPMessage *encMsg = [session encryptMessage:msg extraKeys:nil status:nil error:&error];
    XCTAssertNotNil(encMsg);
    XCTAssertNil(error);

    NSArray *keys;

    error = nil;

    PEPRating rating = PEPRatingB0rken;
    PEPMessage *decmsg = [session
                          decryptMessage:encMsg
                          flags:nil
                          rating:&rating
                          extraKeys:&keys
                          status:nil
                          error:&error];
    XCTAssertNotNil(decmsg);
    XCTAssertNil(error);
    XCTAssertEqual(rating, PEPRatingTrustedAndAnonymized);

    // There shouldn't be any attachments
    XCTAssertEqual(decmsg.attachments.count, 0);
}

- (void)testOutgoingContactColor
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *partner1Orig = [self
                                 checkImportingKeyFilePath:@"partner1_F2D281C2789DD7F6_pub.asc"
                                 address:@"partner1@dontcare.me"
                                 userID:@"partner1"
                                 fingerPrint:@"F0CD3F7B422E5D587ABD885BF2D281C2789DD7F6"
                                 session:session];
    XCTAssertNotNil(partner1Orig);

    PEPRating color = [self ratingForIdentity:partner1Orig session:session];
    XCTAssertEqual(color, PEPRatingReliable);
}

- (void)testGetTrustwords
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *me = [self
                       checkMySelfImportingKeyFilePath:@"6FF00E97_sec.asc"
                       address:@"pep.test.alice@pep-project.org"
                       userID:@"Alice_User_ID"
                       fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                       session:session];
    XCTAssertEqual([self ratingForIdentity:me session:session], PEPRatingTrustedAndAnonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingReliable);

    NSError *error = nil;

    XCTAssertNotNil([session getTrustwordsIdentity1:me
                                          identity2:alice
                                           language:@"en"
                                               full:YES
                                              error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual(error.code, PEPStatusOK);
}

- (void)testStringToRating
{
    PEPInternalSession *session = [PEPSessionProvider session];
    XCTAssertEqual([session ratingFromString:@"cannot_decrypt"], PEPRatingCannotDecrypt);
    XCTAssertEqual([session ratingFromString:@"have_no_key"], PEPRatingHaveNoKey);
    XCTAssertEqual([session ratingFromString:@"unencrypted"], PEPRatingUnencrypted);
    XCTAssertEqual([session ratingFromString:@"unreliable"], PEPRatingUnreliable);
    XCTAssertEqual([session ratingFromString:@"reliable"], PEPRatingReliable);
    XCTAssertEqual([session ratingFromString:@"trusted"], PEPRatingTrusted);
    XCTAssertEqual([session ratingFromString:@"trusted_and_anonymized"],
                   PEPRatingTrustedAndAnonymized);
    XCTAssertEqual([session ratingFromString:@"fully_anonymous"], PEPRatingFullyAnonymous);
    XCTAssertEqual([session ratingFromString:@"mistrust"], PEPRatingMistrust);
    XCTAssertEqual([session ratingFromString:@"b0rken"], PEPRatingB0rken);
    XCTAssertEqual([session ratingFromString:@"under_attack"], PEPRatingUnderAttack);
    XCTAssertEqual([session ratingFromString:@"undefined"], PEPRatingUndefined);
    XCTAssertEqual([session ratingFromString:@"does not exist111"], PEPRatingUndefined);
}

- (void)testRatingToString
{
    PEPInternalSession *session = [PEPSessionProvider session];
    XCTAssertEqualObjects([session stringFromRating:PEPRatingCannotDecrypt], @"cannot_decrypt");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingHaveNoKey], @"have_no_key");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingUnencrypted], @"unencrypted");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingUnreliable], @"unreliable");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingReliable], @"reliable");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingTrusted], @"trusted");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingTrustedAndAnonymized],
                          @"trusted_and_anonymized");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingFullyAnonymous],
                          @"fully_anonymous");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingMistrust], @"mistrust");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingB0rken], @"b0rken");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingUnderAttack], @"under_attack");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingUndefined], @"undefined");
    XCTAssertEqualObjects([session stringFromRating:500], @"undefined");
}

- (void)testIsPEPUser
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(identMe.fingerPrint);

    // PEP_CANNOT_FIND_PERSON == 902
    XCTAssertTrue([session isPEPUser:identMe error:&error]);
}

- (void)testXEncStatusForOutgoingEncryptedMail
{
    [self helperXEncStatusForOutgoingEncryptdMailToSelf:NO expectedRating:PEPRatingReliable];
}

- (void)testXEncStatusForOutgoingSelfEncryptedMail
{
    [self helperXEncStatusForOutgoingEncryptdMailToSelf:YES
                                         expectedRating:PEPRatingTrustedAndAnonymized];
}

/**
 ENGINE-364. Tries to invoke trustPersonalKey on an identity without key,
 giving it a fake fingerprint.
 */
- (void)testTrustPersonalKey
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(identMe.fingerPrint);

    // The fingerprint is definitely wrong, we don't have a key
    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"alice@pep-project.org"
                               userID:@"alice"
                               userName:@"pEp Test Alice"
                               isOwn:NO
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    XCTAssertFalse([session trustPersonalKey:identAlice error:&error]);
    XCTAssertNotNil(error);
}

/**
 ENGINE-381
 */
- (void)testVolatileIdentityRating
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(identMe.fingerPrint);

    PEPIdentity *identAlice = [self
                               checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                               address:@"pep.test.alice@pep-project.org"
                               userID:@"alice_user_id"
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                               session: session];
    XCTAssertNotNil(identAlice);

    dispatch_group_t identityRatingGroup = dispatch_group_create();

    void (^ratingBlock)(void) = ^{
        PEPInternalSession *innerSession = [PEPSessionProvider session];
        PEPRating rating = [self ratingForIdentity:identAlice session:innerSession];
        XCTAssertEqual(rating, PEPRatingReliable);
    };

    for (int i = 0; i < 4; ++i) {
        dispatch_group_async(identityRatingGroup,
                             dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0),
                             ratingBlock);
    }

    for (int i = 0; i < 4; ++i) {
        ratingBlock();
    }

    dispatch_group_wait(identityRatingGroup, DISPATCH_TIME_FOREVER);
}

/**
 IOSAD-93, testing for easy error case.
 */
- (void)testEncryptAndAttachPrivateKeyIllegalValue
{
    PEPInternalSession *session = [PEPSessionProvider session];

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

    NSString *shortMessage = @"whatever it may be";
    NSString *longMessage = [NSString stringWithFormat:@"%@ %@", shortMessage, shortMessage];
    PEPMessage *message = [PEPMessage new];
    message.from = identMe;
    message.to = @[identAlice];
    message.shortMessage = shortMessage;
    message.longMessage = longMessage;

    PEPStatus status = PEPStatusKeyNotFound;
    error = nil;
    PEPMessage *encrypted = [session
                             encryptMessage:message
                             toFpr:fprAlice
                             encFormat:PEPEncFormatPEP
                             flags:0
                             status:&status error:&error];
    XCTAssertEqual(status, PEPStatusIllegalValue);
    XCTAssertNotNil(error);
    XCTAssertNil(encrypted);
}

- (void)testSetIdentityFlags
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    PEPIdentityFlags theFlags[] = {
        PEPIdentityFlagsNotForSync,
        PEPIdentityFlagsList,
        PEPIdentityFlagsDeviceGroup,
        0
    };

    for (int i = 0;; ++i) {
        PEPIdentityFlags aFlag = theFlags[i];
        if (aFlag == 0) {
            break;
        }
        error = nil;
        XCTAssertTrue([session setFlags:(PEPIdentityFlags) aFlag forIdentity:me error:&error]);
        XCTAssertNil(error);

        XCTAssertTrue(me.flags & theFlags[i]);
    }
}

- (void)testTrustOwnKey
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    XCTAssertTrue([session trustOwnKeyIdentity:me error:&error]);
    XCTAssertNil(error);
}

- (void)testImportExtraKey
{
    PEPInternalSession *session = [PEPSessionProvider session];
    NSString *txtFileContents = [PEPTestUtils loadStringFromFileName:@"6FF00E97.asc"];
    NSError *error = nil;
    NSArray *fingerprints = [session importExtraKey:txtFileContents error:&error];
    XCTAssertNotNil(fingerprints);
    XCTAssertNil(error);
    XCTAssertEqual(fingerprints.count, 1);
    NSString *fingerprint = [fingerprints firstObject];
    XCTAssertEqualObjects(@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97", fingerprint);
}

- (void)testResetOwnKeysWithWeirdCommTypesOwnUserId:(NSString *)ownUserId
{
    NSString *address = @"tyrell@example.com";
    NSString *userName = @"Eldon Tyrell";

    PEPInternalSession *session = [PEPSessionProvider session];

    PEPCommType commTypes[] = {
        PEPCommTypeUnknown,
        PEPCommTypeNoEncryption,
        PEPCommTypeNoEncryptedChannel,
        PEPCommTypeKeyNotFound,
        PEPCommTypeKeyExpired,
        PEPCommTypeKeyRevoked,
        PEPCommTypeKeyB0rken,
        PEPCommTypeKeyExpiredButConfirmed,
        PEPCommTypeMyKeyNotIncluded,
        PEPCommTypeSecurityByObscurity,
        PEPCommTypeB0rkenCrypto,
        PEPCommTypeKeyTooShort,
        PEPCommTypeCompromised,
        PEPCommTypeCompromized,
        PEPCommTypeMistrusted,
        PEPCommTypeUnconfirmedEncryption,
        PEPCommTypeOpenPGPWeakUnconfirmed,
        PEPCommTypeToBeChecked,
        PEPCommTypeSmimeUnconfirmed,
        PEPCommTypeCmsUnconfirmed,
        PEPCommTypeStrongButUnconfirmed,
        PEPCommTypeOpenPGPUnconfirmed,
        PEPCommTypeOtrUnconfirmed,
        PEPCommTypeUnconfirmedEncAnon,
        PEPCommTypePEPUnconfirmed,
        PEPCommTypeConfirmed,
        PEPCommTypeConfirmedEncryption,
        PEPCommTypeOpenPGPWeak,
        PEPCommTypeToBeCheckedConfirmed,
        PEPCommTypeSmime,
        PEPCommTypeCms,
        PEPCommTypeStrongEncryption,
        PEPCommTypeOpenPGP,
        PEPCommTypeOtr,
        PEPCommTypeConfirmedEncAnon,
        PEPCommTypePEP
    };
    size_t commTypesLen = sizeof(commTypes) / sizeof(PEPCommType);

    for (NSUInteger i = 0; i < 3; ++i) {
        uint32_t index = arc4random() % commTypesLen;
        PEPCommType randomCommType = commTypes[index];

        PEPIdentity *tyrell = [[PEPIdentity alloc]
                               initWithAddress:address
                               userID:ownUserId
                               userName:userName
                               isOwn:YES];
        NSError *error = nil;
        XCTAssertTrue([session mySelf:tyrell error:&error]);
        XCTAssertNil(error);

        tyrell.commType = randomCommType;
        error = nil;
        XCTAssertTrue([session setTrustIdentity:tyrell error:&error]);

        error = nil;
        XCTAssertTrue([session keyResetAllOwnKeysError:&error]);
        XCTAssertNil(error);
    }
}

- (void)testResetOwnKeysWithWeirdCommTypesUserDefinedOwnUserId
{
    [self testResetOwnKeysWithWeirdCommTypesOwnUserId:@"tyrell"];
}

- (void)testResetOwnKeysWithWeirdCommTypesDefaultOwnUserId
{
    [self testResetOwnKeysWithWeirdCommTypesOwnUserId:@PEP_OWN_USERID];
}

#pragma mark - configUnencryptedSubject

- (void)testConfigUnencryptedSubject
{
    // Setup Config to encrypt subject
    [PEPObjCAdapter setUnEncryptedSubjectEnabled:NO];

    // Write mail to yourself ...
    PEPMessage *encMessage = [self mailWrittenToMySelf];

    // ... and assert subject is encrypted
    XCTAssertEqualObjects(encMessage.shortMessage, @"planck", @"Subject should be encrypted");
}

- (void)testConfigUnencryptedSubjectEncryptedSubjectDisabled
{
    // Setup Config to not encrypt subject
    [PEPObjCAdapter setUnEncryptedSubjectEnabled:YES];

    // Write mail to yourself ...
    PEPMessage *encMessage = [self mailWrittenToMySelf];

    // pEp to pEp uses message 2.0, which always encrypts subjects (ENGINE-429)
    XCTAssertEqualObjects(encMessage.shortMessage, @"planck", @"Subject should be encrypted");
}

#pragma mark - Passive mode

- (void)testPassiveMode
{
    [self testPassiveModeEnabled:NO];
    [self testPassiveModeEnabled:YES];
}

#pragma mark - Decryption

- (void)testDecryptionOfUnencryptedMessageWithOdtAttachmentContainingSpace
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    const char *dataString = "blahblah";
    const size_t dataSize = strlen(dataString);
    char *rawData = strndup(dataString, dataSize);

    PEPAttachment *attachment = [[PEPAttachment alloc]
                                 initWithData:[NSData
                                               dataWithBytesNoCopy:rawData length:dataSize]];
    attachment.filename = @"Someone andTextIncludingTheSpace.odt";
    attachment.mimeType = @"application/vnd.oasis.opendocument.text";

    NSString *shortMessage = @"Subject";
    NSString *longMessage = @"Oh, this is a long body text!";
    PEPMessage *mail = [PEPTestUtils mailFrom:me
                                      toIdent:me
                                 shortMessage:shortMessage
                                  longMessage:longMessage
                                     outgoing:YES];

    mail.attachments = @[attachment];

    error = nil;

    PEPStringList *keys;
    PEPRating rating = PEPRatingB0rken;
    PEPMessage *decmsg = [session
                          decryptMessage:mail
                          flags:nil
                          rating:&rating
                          extraKeys:&keys
                          status:nil
                          error:&error];
    XCTAssertNotNil(decmsg);
    XCTAssertNil(error);
    XCTAssertEqual(rating, PEPRatingUnencrypted);

    PEPAttachment *decryptedAttachment = [decmsg.attachments objectAtIndex:0];
    XCTAssertEqualObjects(decryptedAttachment.mimeType, attachment.mimeType);
    XCTAssertEqualObjects(decryptedAttachment.filename, attachment.filename);
}

#pragma mark - Sync

/// Prove that mySelf triggers a message to be sent.
- (void)testBasicSendMessage
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [self testSendMessageOnSession:session];
}

- (void)testDeliverHandshakeResult
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [self testSendMessageOnSession:session];

    PEPSyncHandshakeResult handshakeResults[] = { PEPSyncHandshakeResultCancel,
        PEPSyncHandshakeResultAccepted, PEPSyncHandshakeResultRejected };

    PEPIdentity *forSureNotMe = [[PEPIdentity alloc]
                                 initWithAddress:@"someoneelseentirely@pep-project.org"
                                 userID:@"that_someone_else"
                                 userName:@"other"
                                 isOwn:NO];

    for (int i = 0;; ++i) {
        NSError *error = nil;
        XCTAssertFalse([session
                        deliverHandshakeResult:handshakeResults[i]
                        identitiesSharing:@[forSureNotMe]
                        error:&error]);
        XCTAssertNotNil(error);
        XCTAssertEqual([error code], PEPStatusIllegalValue);

        if (handshakeResults[i] == PEPSyncHandshakeResultRejected) {
            break;
        }
    }
}

/// Test creating a new own identity with pEp sync disabled.
- (void)testNoBeaconOnMyself
{
    PEPInternalSession *session = [PEPSessionProvider session];

    XCTAssertEqual(self.sendMessageDelegate.messages.count, 0);
    XCTAssertNil(self.sendMessageDelegate.lastMessage);

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];
    identMe.flags |= PEPIdentityFlagsNotForSync;

    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);
    XCTAssertTrue([session disableSyncForIdentity:identMe error:&error]);
    XCTAssertNil(error);

    [self startSync];

    [NSThread sleepForTimeInterval:1];
    XCTAssertNil(self.sendMessageDelegate.lastMessage);

    XCTAssertEqual(self.sendMessageDelegate.messages.count, 0);
    [self shutdownSync];
}

#pragma mark - Sync/sync_reinit

- (void)testSyncReinitWithoutSyncLoop
{
    PEPInternalSession *session = [PEPSessionProvider session];
    NSError *error = nil;
    [session syncReinit:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, PEPStatusCannotFindIdentity);
}

/// @Note This test only proves that `sync_reinit` can be called without errors.
/// There was no observable change to verify, e.g., there was no message sent out.
- (void)testSyncReinit
{
    XCTAssertEqual(self.sendMessageDelegate.messages.count, 0);
    XCTAssertNil(self.sendMessageDelegate.lastMessage);

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];

    PEPInternalSession *session = [PEPSessionProvider session];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(identMe.fingerPrint);

    [self startSync];

    XCTKVOExpectation *expHaveMessage = [[XCTKVOExpectation alloc]
                                         initWithKeyPath:@"lastMessage"
                                         object:self.sendMessageDelegate];

    [self waitForExpectations:@[expHaveMessage] timeout:PEPTestInternalSyncTimeout];
    XCTAssertNotNil(self.sendMessageDelegate.lastMessage);

    XCTAssertEqual(self.sendMessageDelegate.messages.count, 1);

    self.sendMessageDelegate.lastMessage = nil;

    error = nil;
    [session syncReinit:&error];
    XCTAssertNil(error);

    [self shutdownSync];
}

#pragma mark - key_reset_user

- (void)testKeyResetIdentityOnOwnKeyIsIllegal
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    NSString *fprOriginal = me.fingerPrint;
    XCTAssertNotNil(fprOriginal);

    // Cannot reset all _own_ keys with this method, as documented
    XCTAssertFalse([session keyReset:me fingerprint:nil error:&error]);
    XCTAssertNotNil(error);

    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    NSString *fprAfterReset = me.fingerPrint;
    XCTAssertNotNil(fprAfterReset);

    XCTAssertNotEqual(fprOriginal, fprAfterReset);
}

#pragma mark - leave_device_group

/** Leaving a device group is successful even though none exists. */
- (void)testSuccessfulLeaveDeviceGroup
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);

    [self startSync];

    error = nil;
    XCTAssertTrue([session leaveDeviceGroup:&error]);
    XCTAssertNil(error);

    // leaving a device group should disable sync
    XCTAssertTrue(self.notifyHandshakeDelegate.engineDidShutdownKeySync);

    [self shutdownSync];
}

#pragma mark - enable/disable sync

- (void)testEnableDisableFailForSyncOnPartnerIdentity
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *notMe = [[PEPIdentity alloc]
                          initWithAddress:@"notme@pep-project.org"
                          userID:@"notme_ID"
                          userName:@"notme"
                          isOwn:NO];

    NSError *error = nil;
    XCTAssertFalse([session enableSyncForIdentity:notMe error:&error]);
    XCTAssertNotNil(error);

    error = nil;
    XCTAssertFalse([session disableSyncForIdentity:notMe error:&error]);
    XCTAssertNotNil(error);
}

#pragma mark - Basic Passphrases

- (void)testOwnKeyWithPasswordAndEncryptToSelf
{
    NSString *correctPassphrase = @"passphrase_testOwnKeyWithPasswordAndEncryptToSelf";

    NSError *error = nil;

    XCTAssertTrue([PEPObjCAdapter configurePassphraseForNewKeys:correctPassphrase error:&error]);
    XCTAssertNil(error);

    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identMeWithPassphrase = [[PEPIdentity alloc]
                                          initWithAddress:@"me-myself-and-i@pep-project.org"
                                          userID:@"me-myself-and-i"
                                          userName:@"pEp Me"
                                          isOwn:YES];

    XCTAssertTrue([session mySelf:identMeWithPassphrase error:&error]);
    XCTAssertNil(error);

    PEPIdentity *receiver1 = [[PEPIdentity alloc]
                              initWithAddress:@"partner1@example.com"
                              userID:@"partner1"
                              userName:@"Partner 1"
                              isOwn:NO];

    PEPMessage *draftMail = [PEPTestUtils
                             mailFrom:identMeWithPassphrase
                             toIdent:receiver1
                             shortMessage:@"hey"
                             longMessage:@"hey hey"
                             outgoing:YES];

    error = nil;
    PEPStatus status = PEPStatusOutOfMemory;

    XCTAssertTrue([session
                   encryptMessage:draftMail
                   forSelf:identMeWithPassphrase
                   extraKeys:nil
                   status:&status
                   error:&error]);
    XCTAssertNil(error);
}

#pragma mark - Passphrases

/// Use case: No passphrase provider
- (void)testPassphraseProviderNone
{
    PEPMessage *draftMail = nil;
    PEPInternalSession *session = nil;
    PEPIdentity *identMe = nil;

    [self setupEncryptWithImportedKeySession:&session
                                 ownIdentity:&identMe
                            messageToEncrypt:&draftMail];

    NSError *error = nil;
    PEPStatus status = PEPStatusOutOfMemory;

    XCTAssertFalse([session
                    encryptMessage:draftMail
                    forSelf:identMe
                    extraKeys:nil
                    status:&status
                    error:&error]);
    XCTAssertNotNil(error);

    XCTAssertEqualObjects(error.domain, PEPObjCEngineStatusErrorDomain);
    XCTAssertEqual(error.code, PEPStatusPassphraseRequired);
}

/// Use case: Passphrase provider set, but never delivers passphrases
- (void)testPassphraseProviderEmpty
{
    PEPMessage *draftMail = nil;
    PEPInternalSession *session = nil;
    PEPIdentity *identMe = nil;

    [self setupEncryptWithImportedKeySession:&session
                                 ownIdentity:&identMe
                            messageToEncrypt:&draftMail];

    NSError *error = nil;
    PEPStatus status = PEPStatusOutOfMemory;

    [PEPObjCAdapter setPassphraseProvider:[[PEPPassphraseProviderMock alloc]
                                           initWithPassphrases:@[]]];

    XCTAssertFalse([session
                    encryptMessage:draftMail
                    forSelf:identMe
                    extraKeys:nil
                    status:&status
                    error:&error]);
    XCTAssertNotNil(error);

    XCTAssertEqualObjects(error.domain, PEPObjCEngineStatusErrorDomain);
    XCTAssertEqual(error.code, PEPStatusPassphraseRequired);
}

/// Use case: Passphrase provider set, only delivers incorrect passphrases
- (void)testPassphraseProviderWrongPassphrases
{
    PEPMessage *draftMail = nil;
    PEPInternalSession *session = nil;
    PEPIdentity *identMe = nil;

    [self setupEncryptWithImportedKeySession:&session
                                 ownIdentity:&identMe
                            messageToEncrypt:&draftMail];

    NSError *error = nil;
    PEPStatus status = PEPStatusOutOfMemory;

    NSArray *nonsensePassphrases = @[@"blah1", @"blah2", @"blah3"];
    [PEPObjCAdapter setPassphraseProvider:[[PEPPassphraseProviderMock alloc]
                                           initWithPassphrases:nonsensePassphrases]];

    XCTAssertFalse([session
                    encryptMessage:draftMail
                    forSelf:identMe
                    extraKeys:nil
                    status:&status
                    error:&error]);
    XCTAssertNotNil(error);

    XCTAssertEqualObjects(error.domain, PEPObjCEngineStatusErrorDomain);
    XCTAssertEqual(error.code, PEPStatusWrongPassphrase);
}

/// Use case: 1 Passphrase, but too long
- (void)testPassphraseProviderPassphraseTooLong
{
    PEPMessage *draftMail = nil;
    PEPInternalSession *session = nil;
    PEPIdentity *identMe = nil;

    [self setupEncryptWithImportedKeySession:&session
                                 ownIdentity:&identMe
                            messageToEncrypt:&draftMail];

    NSError *error = nil;
    PEPStatus status = PEPStatusOutOfMemory;

    NSString *passphraseBase = @"base";
    NSString *passphraseTooLong = passphraseBase;
    for (NSUInteger i = 0; i < 250; ++i) {
        passphraseTooLong = [passphraseTooLong stringByAppendingString:passphraseBase];
    }

    NSArray *onePassphraseThatIsTooLong = @[passphraseTooLong];
    PEPPassphraseProviderMock *passphraseProviderMock1 = [[PEPPassphraseProviderMock
                                                           alloc]
                                                          initWithPassphrases:onePassphraseThatIsTooLong];
    [PEPObjCAdapter setPassphraseProvider:passphraseProviderMock1];

    XCTAssertFalse([session
                    encryptMessage:draftMail
                    forSelf:identMe
                    extraKeys:nil
                    status:&status
                    error:&error]);
    XCTAssertNotNil(error);

    XCTAssertEqualObjects(error.domain, PEPObjCEngineStatusErrorDomain);
    XCTAssertEqual(error.code, PEPStatusWrongPassphrase);
    XCTAssertTrue(passphraseProviderMock1.passphraseTooLongWasCalled);
}

/// Use case: Passphrase provider set, has correct passphrase after 2 unsuccessful attempts
- (void)testPassphraseProviderCorrectPassphrase
{
    PEPMessage *draftMail = nil;
    PEPInternalSession *session = nil;
    PEPIdentity *identMe = nil;

    [self setupEncryptWithImportedKeySession:&session
                                 ownIdentity:&identMe
                            messageToEncrypt:&draftMail];

    NSError *error = nil;
    PEPStatus status = PEPStatusOutOfMemory;

    NSString *correctPassphrase = @"uiae";
    NSArray *passphrases = @[@"blah1", @"blah2", correctPassphrase];
    [PEPObjCAdapter setPassphraseProvider:[[PEPPassphraseProviderMock alloc]
                                           initWithPassphrases:passphrases]];

    XCTAssertTrue([session
                   encryptMessage:draftMail
                   forSelf:identMe
                   extraKeys:nil
                   status:&status
                   error:&error]);
    XCTAssertNil(error);
}

/// @Note This test *assumes* that a key reset on an own key (with set passphrase)
/// will call ensure_passphrase if that passphrase has been "forgotten",
/// which in turn invokes the currently set passphrase provider.
/// That the passphrase provider was invoked
/// by ensure_passphrase (and not by the earlier passphrase handling in
/// `[PEPInternalSession keyResetAllOwnKeysError]` *cannot be easily proven*.
- (void)testEnsurePassphrase
{
    NSString *passphrase = @"a";

    NSError *error = nil;

    XCTAssertTrue([PEPObjCAdapter configurePassphraseForNewKeys:passphrase error:&error]);
    XCTAssertNil(error);

    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];

    error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);

    [[PEPPassphraseCache sharedInstance] setStoredPassphrase:nil];

    PEPPassphraseProviderMock *mock = [[PEPPassphraseProviderMock alloc] initWithPassphrases:@[]];
    [PEPObjCAdapter setPassphraseProvider:mock];

    error = nil;
    XCTAssertFalse([session keyResetAllOwnKeysError:&error]);
    XCTAssertNotNil(error);
    XCTAssertTrue(mock.passphraseRequiredWasCalled);
}

#pragma mark - Media Key / Echo Protocol

- (void)testConfigureMediaKeys
{
    // These echo settings don't interfere at all with the tests,
    // but may be used to prove (via debugger) that the config works.
    // See [PEPSessionProvider configureEchoProtocolOnSession:]
    [PEPObjCAdapter setEchoProtocolEnabled:NO];
    [PEPObjCAdapter setEchoInOutgoingMessageRatingPreviewEnabled:NO];

    NSArray *mediaKeys = @[
        [[PEPMediaKeyPair alloc] initWithPattern:@"*@example.com"
                                     fingerprint:@"97B69752A72FC5036971F5C83AC51FA45F01DA6C"]
    ];

    [PEPObjCAdapter configureMediaKeys:mediaKeys];
}

#pragma mark - Helpers

- (void)setupEncryptWithImportedKeySession:(PEPInternalSession **)session
                               ownIdentity:(PEPIdentity **)ownIdentity
                          messageToEncrypt:(PEPMessage **)messageToEncrypt
{
    *session = [PEPSessionProvider session];

    NSString *fingerprint = [@"9DD8 3053 3B93 988A 9777  52CA 4802 9ADE 43F2 70EC"
                             stringByReplacingOccurrencesOfString:@" " withString:@""];
    fingerprint = [fingerprint stringByReplacingOccurrencesOfString:@"  " withString:@""];

    *ownIdentity = [self
                    checkMySelfImportingKeyFilePath:@"Rick Deckard (43F270EC) – Secret.asc"
                    address:@"deckard@example.com"
                    userID:@"deckard_user_id"
                    fingerPrint:fingerprint
                    session:*session];
    XCTAssertNotNil(*ownIdentity);

    PEPIdentity *dummyReceiver = [[PEPIdentity alloc]
                                  initWithAddress:@"partner1@example.com"
                                  userID:@"partner1"
                                  userName:@"Partner 1"
                                  isOwn:NO];

    *messageToEncrypt = [PEPTestUtils
                         mailFrom:*ownIdentity
                         toIdent:dummyReceiver
                         shortMessage:@"hey"
                         longMessage:@"hey hey"
                         outgoing:YES];
}

- (void)testSendMessageOnSession:(PEPInternalSession *)session
{
    XCTAssertEqual(self.sendMessageDelegate.messages.count, 0);
    XCTAssertNil(self.sendMessageDelegate.lastMessage);

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(identMe.fingerPrint);

    [self startSync];

    XCTKVOExpectation *expHaveMessage = [[XCTKVOExpectation alloc]
                                         initWithKeyPath:@"lastMessage"
                                         object:self.sendMessageDelegate];

    [self waitForExpectations:@[expHaveMessage] timeout:PEPTestInternalSyncTimeout];
    XCTAssertNotNil(self.sendMessageDelegate.lastMessage);

    XCTAssertEqual(self.sendMessageDelegate.messages.count, 1);
    [self shutdownSync];
}

- (void)startSync
{
    self.sendMessageDelegate = [PEPInternalSessionTestSendMessageDelegate new];
    self.notifyHandshakeDelegate = [PEPInternalSessionTestNotifyHandshakeDelegate new];

    self.sync = [[PEPSync alloc]
                 initWithSendMessageDelegate:self.sendMessageDelegate
                 notifyHandshakeDelegate:self.notifyHandshakeDelegate];
    [self.sync startup];
}

- (void)shutdownSync
{
    [self.sync shutdown];
}

- (NSNumber * _Nullable)testOutgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                                             session:(PEPInternalSession *)session
                                               error:(NSError * _Nullable * _Nullable)error
{
    return [session outgoingRatingForMessage:theMessage error:error];
}

- (void)testPassiveModeEnabled:(BOOL)passiveModeEnabled
{
    [PEPObjCAdapter setPassiveModeEnabled:passiveModeEnabled];
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(identMe.fingerPrint);

    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:@"alice_user_id"
                               userName:@"Alice"
                               isOwn:NO];

    NSString *shortMessage = @"whatever it may be";
    NSString *longMessage = [NSString stringWithFormat:@"%@ %@", shortMessage, shortMessage];
    PEPMessage *message = [PEPMessage new];
    message.direction = PEPMsgDirectionOutgoing;
    message.from = identMe;
    message.to = @[identAlice];
    message.shortMessage = shortMessage;
    message.longMessage = longMessage;

    PEPStatus status = PEPStatusKeyNotFound;
    PEPMessage *encryptedMessage =  [session encryptMessage:message
                                                  extraKeys:@[]
                                                     status:&status
                                                      error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(status, PEPStatusUnencrypted);

    if (passiveModeEnabled) {
        XCTAssertNil(encryptedMessage.attachments);
    } else {
        XCTAssertEqual(encryptedMessage.attachments.count, 1);
    }
}

/**
 Determines the rating for the given identity.
 @return PEPRatingUndefined on error
 */
- (PEPRating)ratingForIdentity:(PEPIdentity *)identity session:(PEPInternalSession *)session
{
    NSError *error;
    NSNumber *numRating = [session ratingForIdentity:identity error:&error];
    XCTAssertNil(error);
    return numRating.pEpRating;
}

- (PEPIdentity *)checkImportingKeyFilePath:(NSString *)filePath address:(NSString *)address
                                    userID:(NSString *)userID
                               fingerPrint:(NSString *)fingerPrint
                                   session:(PEPInternalSession *)session
{
    if (!session) {
        session = [PEPSessionProvider session];
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
        XCTAssertNil(identTest.fingerPrint); // should be nil before setIdentity

        error = nil;
        identTest.fingerPrint = fingerPrint;
        XCTAssertTrue([session setIdentity:identTest error:&error]);
        XCTAssertNil(error);

        // forget the fingerprint
        identTest.fingerPrint = nil;

        error = nil;
        XCTAssertTrue([session updateIdentity:identTest error:&error]);
        XCTAssertNil(error);
        XCTAssertNotNil(identTest.fingerPrint);
        XCTAssertEqualObjects(identTest.fingerPrint, fingerPrint);

        return identTest;
    } else {
        return nil;
    }
}

- (PEPIdentity *)checkMySelfImportingKeyFilePath:(NSString *)filePath
                                         address:(NSString *)address
                                          userID:(NSString *)userID
                                     fingerPrint:(NSString *)fingerPrint
                                         session:(PEPInternalSession *)session
{
    XCTAssertTrue([PEPTestUtils importBundledKey:filePath session:session]);

    // Our test user:
    PEPIdentity *identTest = [[PEPIdentity alloc]
                              initWithAddress:address
                              userID:userID
                              userName:[NSString stringWithFormat:@"Some User Name %@", userID]
                              isOwn:YES
                              fingerPrint: fingerPrint];

    NSError *error;
    XCTAssertTrue([session setOwnKey:identTest fingerprint:fingerPrint error:&error]);
    XCTAssertNil(error);

    return identTest;
}

/**
 Verifies that a partner ID is really a correct Identity.
 Usually used on identities imported as keys, since the engine has problems with them.
 */
- (void)updateAndVerifyPartnerIdentity:(PEPIdentity *)partnerIdentity session:(PEPInternalSession *)session
{
    NSError *error = nil;

    XCTAssertNotNil(partnerIdentity.fingerPrint);
    XCTAssertTrue([session updateIdentity:partnerIdentity error:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(partnerIdentity.fingerPrint);
    NSString *fingerprint = partnerIdentity.fingerPrint;
    partnerIdentity.fingerPrint = nil;
    XCTAssertTrue([session updateIdentity:partnerIdentity error:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(partnerIdentity.fingerPrint);
    XCTAssertEqualObjects(partnerIdentity.fingerPrint, fingerprint);
}

- (PEPMessage *)mailWrittenToMySelf
{
    PEPInternalSession *session = [PEPSessionProvider session];

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
    PEPStatus status = PEPStatusUnknownError;
    PEPMessage *encMessage = [session
                              encryptMessage:mail
                              forSelf:me
                              extraKeys:nil
                              status:&status
                              error:&error];
    XCTAssertNil(error);

    return encMessage;
}

- (PEPMessage *)internalEncryptToMySelfKeys:(PEPStringList **)keys
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(me.fingerPrint);

    // Create draft
    NSString *shortMessage = @"Subject";
    NSString *longMessage = @"Oh, this is a long body text!";
    PEPMessage *mail = [PEPTestUtils mailFrom:me toIdent:me shortMessage:shortMessage longMessage:longMessage outgoing:YES];

    PEPStatus status;
    PEPMessage *encMessage = [session
                              encryptMessage:mail
                              forSelf:me
                              extraKeys:nil
                              status:&status
                              error:&error];
    XCTAssertEqual(status, 0);
    XCTAssertEqualObjects(encMessage.shortMessage, @"p≡p");

    error = nil;

    PEPRating rating = PEPRatingB0rken;
    PEPMessage *decMsg = [session
                          decryptMessage:encMessage
                          flags:nil
                          rating:&rating
                          extraKeys:keys
                          status:nil
                          error:&error];
    XCTAssertNotNil(decMsg);
    XCTAssertNil(error);

    XCTAssertGreaterThanOrEqual(rating, PEPRatingReliable);

    XCTAssertEqualObjects(decMsg.shortMessage, shortMessage);
    XCTAssertEqualObjects(decMsg.longMessage, longMessage);

    return decMsg;
}

- (void)pEpCleanUp
{
    [PEPTestUtils cleanUp];
}

- (void)helperXEncStatusForOutgoingEncryptdMailToSelf:(BOOL)toSelf
                                       expectedRating:(PEPRating)expectedRating
{
    PEPInternalSession *session = [PEPSessionProvider session];

    // Partner pubkey for the test:
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    PEPIdentity *identAlice = [self
                               checkImportingKeyFilePath:@"6FF00E97.asc"
                               address:@"pep.test.alice@pep-project.org"
                               userID:@"userid_alice"
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                               session:session];
    [self updateAndVerifyPartnerIdentity:identAlice session:session];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:ownUserId
                            userName:@"pEp Me"
                            isOwn:YES];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(identMe.fingerPrint);

    PEPMessage *msg = [PEPMessage new];
    msg.from = identMe;
    msg.to = @[identAlice];
    msg.shortMessage = @"Mail to Alice";
    msg.longMessage = @"Alice?";
    msg.direction = PEPMsgDirectionOutgoing;

    NSNumber *numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingReliable);

    PEPMessage *encMsg;

    PEPStatus statusEnc = PEPStatusVersionMismatch;
    if (toSelf) {
        encMsg = [session
                  encryptMessage:msg
                  forSelf:identMe
                  extraKeys:nil
                  status:&statusEnc
                  error:&error];
        XCTAssertEqual(statusEnc, PEPStatusOK);
    } else {
        encMsg = [session encryptMessage:msg extraKeys:nil status:nil error:&error];
        XCTAssertNotNil(encMsg);
        XCTAssertNil(error);
    }
    XCTAssertNotNil(encMsg);

    error = nil;

    PEPStringList *keys;
    PEPRating rating = PEPRatingB0rken;
    PEPMessage *decMsg = [session
                          decryptMessage:encMsg
                          flags:nil
                          rating:&rating
                          extraKeys:&keys
                          status:nil
                          error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(decMsg);

    if (!toSelf) {
        // Only check this for outgoing mails. For drafts etc. this rating looks incorrect
        // and the x-encstatus is the relevant one.
        XCTAssertEqual(rating, expectedRating);
    }

    NSArray * encStatusField = nil;
    for (NSArray *field in decMsg.optionalFields) {
        NSString *header = [field[0] lowercaseString];
        if ([header isEqualToString:@"x-encstatus"]) {
            encStatusField = field;
        }
    }
    XCTAssertNotNil(encStatusField);
    if (encStatusField) {
        PEPRating outgoingRating = [session ratingFromString:encStatusField[1]];
        XCTAssertEqual(outgoingRating, expectedRating);
    }
}

#pragma mark - Signing

- (void)testSigningRoundtrip
{
    // Basic signing, without needing an own identity
    PEPInternalSession *session = [PEPSessionProvider session];
    NSString *stringToSign = @"Hello, world";
    NSError *error = nil;
    NSString *signedString = [session signText:stringToSign error:&error];
    XCTAssertNotNil(signedString);
    XCTAssertNil(error);

    // Verify the signed text
    BOOL verified = NO;
    error = nil;
    BOOL sucess = [session verifyText:stringToSign
                            signature:signedString
                             verified:&verified
                                error:&error];
    XCTAssertTrue(sucess);
    XCTAssertNil(error);
    XCTAssertTrue(verified);

    // Reset all own keys
    error = nil;
    BOOL success = [session keyResetAllOwnKeysError:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);

    // Verify the signed text
    error = nil;
    success = [session verifyText:stringToSign
                        signature:signedString
                         verified:&verified
                            error:&error];
    XCTAssertTrue(sucess);
    XCTAssertNil(error);
    XCTAssertTrue(verified);

    // Verification should fail when text and signature don't match, obviously.
    error = nil;
    success = [session verifyText:@"This is a very different string"
                        signature:signedString
                         verified:&verified
                            error:&error];
    XCTAssertTrue(sucess);
    XCTAssertNil(error);
    XCTAssertFalse(verified);

    PEPIdentity *signingIdentity = [[PEPIdentity alloc]
                                    initWithAddress:SigningIdentityAddress
                                    userID:@PEP_OWN_USERID
                                    userName:SigningIdentityUserName
                                    isOwn:YES];

    // Get the fingerprint of the signing identity.
    error = nil;
    success = [session mySelf:signingIdentity error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);

    // Try to reset the signing identity.
    error = nil;
    success = [session keyReset:signingIdentity fingerprint:signingIdentity.fingerPrint error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);

    // Verify the signed text
    error = nil;
    success = [session verifyText:stringToSign
                        signature:signedString
                         verified:&verified
                            error:&error];
    XCTAssertTrue(sucess);
    XCTAssertNil(error);
    XCTAssertTrue(verified);
}

- (void)testSigningUTF8
{
    PEPInternalSession *session = [PEPSessionProvider session];
    NSString *stringToSign = @"Hello, world. Здравствуй, мир.";
    NSError *error = nil;
    NSString *signedString = [session signText:stringToSign error:&error];
    XCTAssertNotNil(signedString);
    XCTAssertNil(error);

    BOOL verified = NO;

    error = nil;
    BOOL success = [session verifyText:stringToSign
                             signature:signedString
                              verified:&verified
                                 error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);
    XCTAssertTrue(verified);

    error = nil;
    success = [session verifyText:@"Здравствуй, мир."
                        signature:signedString
                         verified:&verified
                            error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);
    XCTAssertFalse(verified);
}

@end
