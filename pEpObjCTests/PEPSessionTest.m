//
//  PEPSessionTest.m
//  pEpObjCAdapterTests
//
//  Created by Andreas Buff on 18.01.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPObjCAdapter.h"
#import "NSDictionary+Extension.h"
#import "PEPIdentity.h"
#import "PEPMessage.h"

#import "PEPTestUtils.h"
#import "PEPTestSyncDelegate.h"

@interface PEPSessionTest : XCTestCase
@end

@implementation PEPSessionTest

- (void)setUp
{
    [super setUp];
    [PEPObjCAdapter setUnecryptedSubjectEnabled:NO];

    [self pEpCleanUp];
}

- (void)tearDown {
    [self pEpCleanUp];
    [super tearDown];
}

- (void)testSyncSession
{
    PEPSession *session = [PEPSession new];

    // Dummy to set up the DB, since this is currenty only triggered by session use,
    // which PEPObjCAdapter.startSync does not trigger.
    [session getLog];

    PEPTestSyncDelegate *syncDelegate = [[PEPTestSyncDelegate alloc] init];

    // This should attach session just created
    [PEPObjCAdapter startSync:syncDelegate];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"pep.test.iosgenkey@pep-project.org"
                            userID:@"Me"
                            userName:@"pEp Test iOS GenKey"
                            isOwn:YES];

    [session mySelf:identMe];

    bool res = [syncDelegate waitUntilSent:1];

    // Can't currently work, engine doesn't contain sync.
    XCTAssertFalse(res);

    // This should detach session just created
    [PEPObjCAdapter stopSync];
}

- (void)testTrustWords
{
    PEPSession *session = [PEPSession new];

    NSArray *trustwords = [session trustwords:@"DB47DB47DB47DB47DB47DB47DB47DB47DB47DB47"
                                  forLanguage:@"en" shortened:false];
    XCTAssertEqual([trustwords count], 10);

    for(id word in trustwords)
        XCTAssertEqualObjects(word, @"BAPTISMAL");
}

- (void)testGenKey
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"pep.test.iosgenkey@pep-project.org"
                            userID:@"Me"
                            userName:@"pEp Test iOS GenKey"
                            isOwn:YES];

    [session mySelf:identMe];

    XCTAssertNotNil(identMe.fingerPrint);
    XCTAssertNotEqual(identMe.commType, PEP_ct_unknown);

    // check that the comm type is not a PGP one
    XCTAssertFalse([identMe containsPGPCommType]);
}

- (void)testMySelfCommType
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"pep.test.iosgenkey@pep-project.org"
                            userID:@"Me"
                            userName:@"pEp Test iOS GenKey"
                            isOwn:YES];

    [session mySelf:identMe];

    XCTAssertNotNil(identMe.fingerPrint);
    XCTAssertNotEqual(identMe.commType, PEP_ct_unknown);

    // check that the comm type is not a PGP one
    XCTAssertFalse([identMe containsPGPCommType]);

    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
    dispatch_sync(queue, ^{
        PEPSession *session2 = [PEPSession new];

        // Now simulate an update from the app, which usually only caches
        // kPepUsername, kPepAddress and optionally kPepUserID.
        PEPIdentity *identMe2 = [[PEPIdentity alloc]
                                 initWithAddress:identMe.address
                                 userID:identMe.userID
                                 userName:identMe.userName
                                 isOwn:NO];
        [session2 mySelf:identMe2];
        XCTAssertNotNil(identMe2.fingerPrint);
        XCTAssertFalse([identMe2 containsPGPCommType]);
        XCTAssertEqualObjects(identMe2.fingerPrint, identMe.fingerPrint);

        // Now pretend the app only knows kPepUsername and kPepAddress
        PEPIdentity *identMe3 = [PEPTestUtils foreignPepIdentityWithAddress:identMe.address
                                                                   userName:identMe.userName];
        [session2 mySelf:identMe3];
        XCTAssertNotNil(identMe3.fingerPrint);
        XCTAssertFalse([identMe3 containsPGPCommType]);
        XCTAssertEqualObjects(identMe3.fingerPrint, identMe.fingerPrint);

        XCTAssertEqualObjects(identMe.address, identMe2.address);
        XCTAssertEqualObjects(identMe.address, identMe3.address);
        XCTAssertEqual(identMe.commType, identMe2.commType);
        XCTAssertEqual(identMe.commType, identMe3.commType);
    });
}

- (void)testPartnerWithoutFingerPrint
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *identRandom = [[PEPIdentity alloc]
                                initWithAddress:@"does_not_exist@example.com"
                                userID:@"got_out"
                                userName:@"No Way Not Even Alice"
                                isOwn:NO];

    [session updateIdentity:identRandom];
    XCTAssertNil(identRandom.fingerPrint);
}

- (void)testImportPartnerKeys
{
    [self checkImportingKeyFilePath:@"6FF00E97_sec.asc" address:@"pep.test.alice@pep-project.org"
                             userID:@"This Is Alice"
                        fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                            session: nil];

    [self checkImportingKeyFilePath:@"0xC9C2EE39.asc" address:@"pep.test.bob@pep-project.org"
                             userID:@"This Is Bob"
                        fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"
                            session: nil];
}

- (void)testIdentityRating
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *me = [self
                       checkMySelfImportingKeyFilePath:@"6FF00E97_sec.asc"
                       address:@"pep.test.alice@pep-project.org"
                       userID:@"Alice_User_ID"
                       fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];
    XCTAssertEqual([session identityRating:me], PEP_rating_trusted_and_anonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertEqual([session identityRating:alice], PEP_rating_reliable);
}

- (void)testIdentityRatingTrustResetMistrustUndo
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *me = [[PEPIdentity alloc]
                       initWithAddress:@"me@example.org"
                       userID:@"me_myself"
                       userName:@"Me Me"
                       isOwn:YES];
    [session mySelf:me];
    XCTAssertNotNil(me.fingerPrint);
    XCTAssertEqual([session identityRating:me], PEP_rating_trusted_and_anonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertEqual([session identityRating:alice], PEP_rating_reliable);

    [session trustPersonalKey:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_trusted);

    [session keyResetTrust:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_reliable);

    [session keyMistrusted:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_have_no_key);

    [session undoLastMistrust];
    XCTAssertEqual([session identityRating:alice], PEP_rating_reliable);

    [session trustPersonalKey:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_trusted);

    [session keyResetTrust:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_have_no_key);
}

/** ENGINE-384 */
- (void)testIdentityRatingCrash
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *me = [[PEPIdentity alloc]
                       initWithAddress:@"me@example.org"
                       userID:@"me_myself"
                       userName:@"Me Me"
                       isOwn:YES];
    [session mySelf:me];
    XCTAssertNotNil(me.fingerPrint);
    XCTAssertEqual([session identityRating:me], PEP_rating_trusted_and_anonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertEqual([session identityRating:alice], PEP_rating_reliable);

    [session trustPersonalKey:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_trusted);

    [session keyResetTrust:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_reliable);

    [session keyMistrusted:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_have_no_key);

    [session undoLastMistrust];

    [session trustPersonalKey:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_trusted);

    [session keyResetTrust:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_have_no_key);

    // This line provoked the crash
    [session trustPersonalKey:alice];
}

/**
 Try to provoke a SQLITE_BUSY (ENGINE-374)
 */
- (void)testIdentityRatingTrustResetMistrustUndoBusy
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *me = [[PEPIdentity alloc]
                       initWithAddress:@"me@example.org"
                       userID:@"me_myself"
                       userName:@"Me Me"
                       isOwn:YES];
    [session mySelf:me];
    XCTAssertNotNil(me.fingerPrint);
    XCTAssertEqual([session identityRating:me], PEP_rating_trusted_and_anonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertEqual([session identityRating:alice], PEP_rating_reliable);

    void (^encryptingBlock)(void) = ^{
        PEPSession *innerSession = [PEPSession new];
        PEPMessage *msg = [PEPMessage new];
        msg.from = me;
        msg.to = @[alice];
        msg.shortMessage = @"The subject";
        msg.longMessage = @"Lots and lots of text";
        msg.direction = PEP_dir_outgoing;
        PEPMessage *encMsg;
        PEP_STATUS status = [innerSession encryptMessage:msg identity:me dest:&encMsg];
        XCTAssertEqual(status, PEP_STATUS_OK);
    };

    dispatch_group_t backgroundGroup = dispatch_group_create();
    dispatch_group_async(backgroundGroup,
                         dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), encryptingBlock);

    [session trustPersonalKey:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_trusted);

    [session keyResetTrust:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_reliable);

    [session keyMistrusted:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_have_no_key);

    [session undoLastMistrust];
    XCTAssertEqual([session identityRating:alice], PEP_rating_reliable);

    [session trustPersonalKey:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_trusted);

    [session keyResetTrust:alice];
    XCTAssertEqual([session identityRating:alice], PEP_rating_have_no_key);

    dispatch_group_wait(backgroundGroup, DISPATCH_TIME_FOREVER);
}

- (void)testOutgoingColors
{
    PEPSession *session = [PEPSession new];

    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [PEPTestUtils importBundledKey:@"6FF00E97_sec.asc"];

    // Our test user :
    PEPIdentity *identAlice = [self
                               checkMySelfImportingKeyFilePath:@"6FF00E97_sec.asc"
                               address:@"pep.test.alice@pep-project.org"
                               userID:@"Alice_User_ID"
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

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
        msgGray.direction = PEP_dir_outgoing;

        // Test with unknown Bob
        PEP_rating clr = [session outgoingColorForMessage:msgGray];
        XCTAssertEqual(clr, PEP_rating_unencrypted);
    }

    PEPIdentity *identBob = [self
                             checkImportingKeyFilePath:@"0xC9C2EE39.asc"
                             address:@"pep.test.bob@pep-project.org"
                             userID:@"42"
                             fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"
                             session: session];

    PEPMessage *msg = [PEPMessage new];
    msg.from = identAlice;
    msg.to = @[identBob];
    msg.shortMessage = @"All Gray Test";
    msg.longMessage = @"This is a text content";
    msg.direction = PEP_dir_outgoing;

    // Should be yellow, since no handshake happened.
    PEP_rating clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_reliable);

    clr = [session identityRating:identBob];
    XCTAssertEqual(clr, PEP_rating_reliable);

    // Let' say we got that handshake, set PEP_ct_confirmed in Bob's identity
    [session trustPersonalKey:identBob];

    // This time it should be green
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_trusted);

    clr = [session identityRating:identBob];
    XCTAssertEqual(clr, PEP_rating_trusted);

    // Let' say we undo handshake
    [session keyResetTrust:identBob];

    // Yellow ?
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_reliable);

    // mistrust Bob
    [session keyMistrusted:identBob];

    identBob.fingerPrint = nil;
    [session updateIdentity:identBob];
    XCTAssertNil(identBob.fingerPrint);

    // Gray == PEP_rating_unencrypted
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_unencrypted);

    // Undo
    [session undoLastMistrust];
    [session updateIdentity:identBob];
    XCTAssertNotNil(identBob.fingerPrint);

    // Back to yellow
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_reliable);
    XCTAssertEqual([session identityRating:identBob], PEP_rating_reliable);

    // Trust again
    [session trustPersonalKey:identBob];

    // Back to green
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_trusted);

    // Now let see if it turns back yellow if we add an unconfirmed folk.
    // pEp Test John (test key, don't use) <pep.test.john@pep-project.org>
    // AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575
    [PEPTestUtils importBundledKey:@"0x70DCF575.asc"];

    PEPIdentity *identJohn = [[PEPIdentity alloc]
                              initWithAddress:@"pep.test.john@pep-project.org"
                              userID:@"101" userName:@"pEp Test John"
                              isOwn:NO
                              fingerPrint:@"AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575"];

    [session updateIdentity:identJohn];

    msg.cc = @[[PEPTestUtils foreignPepIdentityWithAddress:@"pep.test.john@pep-project.org"
                                                  userName:@"pEp Test John"]];
    // Yellow ?
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_reliable);

    PEPMessage *encmsg;
    PEP_STATUS status = [session encryptMessage:msg extra:@[] dest:&encmsg];

    XCTAssertNotNil(encmsg);
    XCTAssertEqualObjects(encmsg.shortMessage, @"p≡p");
    XCTAssertTrue([encmsg.longMessage containsString:@"p≡p"]);

    XCTAssertEqual(status, PEP_STATUS_OK);
}


- (void)testOutgoingBccColors
{
    PEPSession *session = [PEPSession new];

    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [PEPTestUtils importBundledKey:@"6FF00E97_sec.asc"];

    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:ownUserId
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    [session mySelf:identAlice];

    PEPMessage *msg = [PEPMessage new];
    msg.from = identAlice;
    msg.to = @[[[PEPIdentity alloc] initWithAddress:@"pep.test.bob@pep-project.org"
                                             userID:@"42" userName:@"pEp Test Bob" isOwn:NO]];
    msg.shortMessage = @"All Green Test";
    msg.longMessage = @"This is a text content";
    msg.direction = PEP_dir_outgoing;

    // Test with unknown Bob
    PEP_rating clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_unencrypted);

    // Now let see with bob's pubkey already known
    // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
    // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
    [PEPTestUtils importBundledKey:@"0xC9C2EE39.asc"];

    PEPIdentity *identBob = [[PEPIdentity alloc]
                             initWithAddress:@"pep.test.bob@pep-project.org"
                             userID:@"42" userName:@"pEp Test Bob"
                             isOwn:NO
                             fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"];

    [session updateIdentity:identBob];

    // Should be yellow, since no handshake happened.
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_reliable);

    clr = [session identityRating:identBob];
    XCTAssertEqual(clr, PEP_rating_reliable);

    // Let' say we got that handshake, set PEP_ct_confirmed in Bob's identity
    [session trustPersonalKey:identBob];

    // This time it should be green
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_trusted);

    clr = [session identityRating:identBob];
    XCTAssertEqual(clr, PEP_rating_trusted);

    // Now let see if it turns back yellow if we add an unconfirmed folk.
    // pEp Test John (test key, don't use) <pep.test.john@pep-project.org>
    // AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575
    [PEPTestUtils importBundledKey:@"0x70DCF575.asc"];

    PEPIdentity *identJohn = [[PEPIdentity alloc]
                              initWithAddress:@"pep.test.john@pep-project.org"
                              userID:@"101" userName:@"pEp Test John"
                              isOwn:NO
                              fingerPrint:@"AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575"];

    [session updateIdentity:identJohn];

    msg.bcc = @[[[PEPIdentity alloc] initWithAddress:@"pep.test.john@pep-project.org"
                                              userID:@"101" userName:@"pEp Test John" isOwn:NO]];

    // Yellow ?
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_reliable);

    [session trustPersonalKey:identJohn];

    // This time it should be green
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_trusted);

    clr = [session identityRating:identJohn];
    XCTAssertEqual(clr, PEP_rating_trusted);
}

- (void)testDontEncryptForMistrusted
{
    PEPSession *session = [PEPSession new];

    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [PEPTestUtils importBundledKey:@"6FF00E97_sec.asc"];

    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:ownUserId
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    [session mySelf:identAlice];

    // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
    // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
    [PEPTestUtils importBundledKey:@"0xC9C2EE39.asc"];

    PEPIdentity *identBob = [[PEPIdentity alloc]
                             initWithAddress:@"pep.test.bob@pep-project.org"
                             userID:@"42" userName:@"pEp Test Bob"
                             isOwn:NO
                             fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"];

    [session updateIdentity:identBob];

    // mistrust Bob
    [session keyMistrusted:identBob];

    PEPMessage *msg = [PEPMessage new];
    msg.from = identAlice;
    msg.to = @[[[PEPIdentity alloc] initWithAddress:@"pep.test.bob@pep-project.org" userID:@"42"
                                           userName:@"pEp Test Bob" isOwn:NO]];
    msg.shortMessage = @"All Green Test";
    msg.longMessage = @"This is a text content";
    msg.direction = PEP_dir_outgoing;

    // Gray == PEP_rating_unencrypted
    PEP_rating clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_unencrypted);

    PEPMessage *encmsg;
    PEP_STATUS status = [session encryptMessage:msg extra:@[] dest:&encmsg];

    XCTAssertEqual(status, PEP_UNENCRYPTED);

    XCTAssertNotEqualObjects(encmsg.attachments[0][@"mimeType"], @"application/pgp-encrypted");

    [self pEpCleanUp];
}

- (void)testRevoke
{
    PEPSession *session = [PEPSession new];

    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [PEPTestUtils importBundledKey:@"6FF00E97_sec.asc"];
    NSString *fpr = @"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97";

    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:ownUserId
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:fpr];

    [session mySelf:identAlice];

    PEPIdentity *identAlice2 = [identAlice mutableCopy];

    // This will revoke key
    [session keyMistrusted:identAlice2];
    identAlice2.fingerPrint = nil;
    [session mySelf:identAlice];

    // Check fingerprint is different
    XCTAssertNotEqualObjects(identAlice2.fingerPrint, fpr);
}

- (void)testMailToMyself
{
    PEPSession *session = [PEPSession new];

    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [PEPTestUtils importBundledKey:@"6FF00E97_sec.asc"];

    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:ownUserId
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    [session mySelf:identAlice];

    PEPMessage *msg = [PEPMessage new];
    msg.from = identAlice;
    msg.to = @[identAlice];
    msg.shortMessage = @"Mail to Myself";
    msg.longMessage = @"This is a text content";
    msg.direction = PEP_dir_outgoing;

    PEP_rating clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_trusted_and_anonymized);

    PEPMessage *encmsg;
    PEP_STATUS status = [session encryptMessage:msg extra:@[] dest:&encmsg];

    XCTAssertEqual(status, PEP_STATUS_OK);

    NSArray* keys;
    PEPMessage *decmsg;

    clr = [session decryptMessage:encmsg dest:&decmsg keys:&keys];
    XCTAssertEqual(clr, PEP_rating_trusted_and_anonymized);
}

- (void)testEncryptedMailFromMutt
{
    PEPSession *session = [PEPSession new];

    // This is the public key for test001@peptest.ch
    [PEPTestUtils importBundledKey:@"A3FC7F0A.asc"];

    // This is the secret key for test001@peptest.ch
    [PEPTestUtils importBundledKey:@"A3FC7F0A_sec.asc"];

    // Mail from mutt, already processed into message dict by the app.
    NSMutableDictionary *msgDict = [[PEPTestUtils
                                     unarchiveDictionary:@"msg_to_A3FC7F0A_from_mutt.ser"]
                                    mutableCopy];
    [msgDict removeObjectForKey:kPepLongMessage];
    [msgDict removeObjectForKey:kPepLongMessageFormatted];

    // Also extracted "live" from the app.
    NSMutableDictionary *accountDict = [[PEPTestUtils
                                         unarchiveDictionary:@"account_A3FC7F0A.ser"]
                                        mutableCopy];
    [accountDict removeObjectForKey:kPepCommType];
    [accountDict removeObjectForKey:kPepFingerprint];
    PEPIdentity *identMe = [[PEPIdentity alloc] initWithDictionary:accountDict];

    [session mySelf:identMe];
    XCTAssertNotNil(identMe.fingerPrint);

    NSArray* keys;
    PEPMessage *msg = [PEPMessage new];
    [msg setValuesForKeysWithDictionary:msgDict];
    PEPMessage *pepDecryptedMail;
    [session decryptMessage:msg dest:&pepDecryptedMail keys:&keys];
    XCTAssertNotNil(pepDecryptedMail.longMessage);
}

- (void)testOutgoingContactColor
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *partner1Orig = [PEPTestUtils foreignPepIdentityWithAddress:@"partner1@dontcare.me"
                                                                   userName:@"Partner 1"];
    NSString *pubKeyPartner1 = [PEPTestUtils loadResourceByName:@"partner1_F2D281C2789DD7F6_pub.asc"];
    XCTAssertNotNil(pubKeyPartner1);
    [session importKey:pubKeyPartner1];

    PEP_rating color = [session identityRating:partner1Orig];
    XCTAssertEqual(color, PEP_rating_reliable);
}

- (void)testGetTrustwords
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *partner1Orig = [[PEPIdentity alloc]
                                 initWithAddress:@"partner1@dontcare.me" userID:@"partner1"
                                 userName:@"partner1"
                                 isOwn:NO fingerPrint:@"F0CD3F7B422E5D587ABD885BF2D281C2789DD7F6"];

    PEPIdentity *meOrig = [[PEPIdentity alloc]
                           initWithAddress:@"me@dontcare.me" userID:@"me"
                           userName:@"me"
                           isOwn:NO fingerPrint:@"CC1F73F6FB774BF08B197691E3BFBCA9248FC681"];

    NSString *pubKeyPartner1 = [PEPTestUtils loadResourceByName:@"partner1_F2D281C2789DD7F6_pub.asc"];
    XCTAssertNotNil(pubKeyPartner1);
    NSString *pubKeyMe = [PEPTestUtils loadResourceByName:@"meATdontcare_E3BFBCA9248FC681_pub.asc"];
    XCTAssertNotNil(pubKeyMe);
    NSString *secKeyMe = [PEPTestUtils loadResourceByName:@"meATdontcare_E3BFBCA9248FC681_sec.asc"];
    XCTAssertNotNil(secKeyMe);

    NSString *trustwordsFull = [session getTrustwordsIdentity1:meOrig identity2:partner1Orig
                                                      language:nil full:YES];
    XCTAssertEqualObjects(trustwordsFull,
                          @"EMERSON GASPER TOKENISM BOLUS COLLAGE DESPISE BEDDED ENCRYPTION IMAGINE BEDFORD");

    NSString *trustwordsFullEnglish = [session getTrustwordsIdentity1:meOrig identity2:partner1Orig
                                                             language:@"en" full:YES];
    XCTAssertEqualObjects(trustwordsFullEnglish, trustwordsFull);

    NSString *trustwordsUndefined = [session getTrustwordsIdentity1:meOrig identity2:partner1Orig
                                                           language:@"ZZ" full:YES];
    XCTAssertNil(trustwordsUndefined);
}

- (void)testStringToRating
{
    PEPSession *session = [PEPSession new];
    XCTAssertEqual([session ratingFromString:@"cannot_decrypt"], PEP_rating_cannot_decrypt);
    XCTAssertEqual([session ratingFromString:@"have_no_key"], PEP_rating_have_no_key);
    XCTAssertEqual([session ratingFromString:@"unencrypted"], PEP_rating_unencrypted);
    XCTAssertEqual([session ratingFromString:@"unencrypted_for_some"],
                   PEP_rating_unencrypted_for_some);
    XCTAssertEqual([session ratingFromString:@"unreliable"], PEP_rating_unreliable);
    XCTAssertEqual([session ratingFromString:@"reliable"], PEP_rating_reliable);
    XCTAssertEqual([session ratingFromString:@"trusted"], PEP_rating_trusted);
    XCTAssertEqual([session ratingFromString:@"trusted_and_anonymized"],
                   PEP_rating_trusted_and_anonymized);
    XCTAssertEqual([session ratingFromString:@"fully_anonymous"], PEP_rating_fully_anonymous);
    XCTAssertEqual([session ratingFromString:@"mistrust"], PEP_rating_mistrust);
    XCTAssertEqual([session ratingFromString:@"b0rken"], PEP_rating_b0rken);
    XCTAssertEqual([session ratingFromString:@"under_attack"], PEP_rating_under_attack);
    XCTAssertEqual([session ratingFromString:@"undefined"], PEP_rating_undefined);
    XCTAssertEqual([session ratingFromString:@"does not exist111"], PEP_rating_undefined);
}

- (void)testRatingToString
{
    PEPSession *session = [PEPSession new];
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_cannot_decrypt], @"cannot_decrypt");
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_have_no_key], @"have_no_key");
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_unencrypted], @"unencrypted");
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_unencrypted_for_some],
                          @"unencrypted_for_some");
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_unreliable], @"unreliable");
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_reliable], @"reliable");
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_trusted], @"trusted");
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_trusted_and_anonymized],
                          @"trusted_and_anonymized");
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_fully_anonymous],
                          @"fully_anonymous");
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_mistrust], @"mistrust");
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_b0rken], @"b0rken");
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_under_attack], @"under_attack");
    XCTAssertEqualObjects([session stringFromRating:PEP_rating_undefined], @"undefined");
    XCTAssertEqualObjects([session stringFromRating:500], @"undefined");
}

- (void)testIsPEPUser
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];
    [session mySelf:identMe];
    XCTAssertNotNil(identMe.fingerPrint);

    // PEP_CANNOT_FIND_PERSON == 902
    XCTAssertTrue([session isPEPUser:identMe]);
}

- (void)testXEncStatusForOutgoingEncryptedMail
{
    [self helperXEncStatusForOutgoingEncryptdMailToSelf:NO expectedRating:PEP_rating_reliable];
}

- (void)testXEncStatusForOutgoingSelfEncryptedMail
{
    [self helperXEncStatusForOutgoingEncryptdMailToSelf:YES
                                         expectedRating:PEP_rating_trusted_and_anonymized];
}

- (void)testEncryptMessagesWithoutKeys
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];
    [session mySelf:identMe];
    XCTAssertNotNil(identMe.fingerPrint);

    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"alice@pep-project.org"
                               userID:@"alice"
                               userName:@"pEp Test Alice"
                               isOwn:NO];

    PEPMessage *msg = [PEPMessage new];
    msg.from = identMe;
    msg.to = @[identAlice];
    msg.shortMessage = @"Mail to Alice";
    msg.longMessage = @"Alice?";
    msg.direction = PEP_dir_outgoing;

    PEP_rating clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_unencrypted);

    PEPMessage *encMsg;

    PEP_STATUS statusEnc = statusEnc = [session encryptMessage:msg extra:@[] dest:&encMsg];

    XCTAssertEqual(statusEnc, PEP_UNENCRYPTED);

    XCTAssertNotNil(encMsg);

    PEPMessage *decMsg;
    PEPStringList *keys;
    PEP_rating pEpRating = [session decryptMessage:encMsg dest:&decMsg keys:&keys];
    XCTAssertEqual(pEpRating, PEP_rating_unencrypted);
    XCTAssertNotNil(decMsg);
}

/**
 ENGINE-364. Tries to invoke trustPersonalKey on an identity without key,
 giving it a fake fingerprint.
 */
- (void)testTrustPersonalKey
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];
    [session mySelf:identMe];
    XCTAssertNotNil(identMe.fingerPrint);

    // The fingerprint is definitely wrong, we don't have a key
    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"alice@pep-project.org"
                               userID:@"alice"
                               userName:@"pEp Test Alice"
                               isOwn:NO
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    [session trustPersonalKey:identAlice];
}

/**
 ENGINE-381
 */
- (void)testVolatileIdentityRating
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"me-myself-and-i@pep-project.org"
                            userID:@"me-myself-and-i"
                            userName:@"pEp Me"
                            isOwn:YES];
    [session mySelf:identMe];
    XCTAssertNotNil(identMe.fingerPrint);

    PEPIdentity *identAlice = [self
                               checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                               address:@"pep.test.alice@pep-project.org"
                               userID:@"alice_user_id"
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                               session: session];

    dispatch_group_t identityRatingGroup = dispatch_group_create();

    void (^ratingBlock)(void) = ^{
        PEPSession *innerSession = [PEPSession new];
        PEP_rating rating = [innerSession identityRating:identAlice];
        XCTAssertEqual(rating, PEP_rating_reliable);
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

#pragma mark - configUnencryptedSubject

- (void)testConfigUnencryptedSubject
{
    // Setup Config to encrypt subject
    [PEPObjCAdapter setUnecryptedSubjectEnabled:NO];

    // Write mail to yourself ...
    PEPMessage *encMessage = [self mailWrittenToMySelf];

    // ... and assert subject is encrypted
    XCTAssertEqualObjects(encMessage.shortMessage, @"p≡p", @"Subject should be encrypted");
}

- (void)testConfigUnencryptedSubject_encryptedSubjectDisabled
{
    // Setup Config to not encrypt subject
    [PEPObjCAdapter setUnecryptedSubjectEnabled:YES];

    // Write mail to yourself ...
    PEPMessage *encMessage = [self mailWrittenToMySelf];

    // ... and assert the subject is not encrypted
    XCTAssertNotEqualObjects(encMessage.shortMessage, @"p≡p", @"Subject should not be encrypted");
}

#pragma mark - Helpers

- (PEPIdentity *)checkImportingKeyFilePath:(NSString *)filePath address:(NSString *)address
                                    userID:(NSString *)userID
                               fingerPrint:(NSString *)fingerPrint
                                   session:(PEPSession *)session
{
    if (!session) {
        session = [PEPSession new];
    }

    [PEPTestUtils importBundledKey:filePath];

    // Our test user:
    PEPIdentity *identTest = [[PEPIdentity alloc]
                              initWithAddress:address
                              userID:userID
                              userName:[NSString stringWithFormat:@"Some User Name %@", userID]
                              isOwn:NO];

    [session updateIdentity:identTest];
    XCTAssertNotNil(identTest.fingerPrint);
    XCTAssertEqualObjects(identTest.fingerPrint, fingerPrint);

    return identTest;
}

- (PEPIdentity *)checkMySelfImportingKeyFilePath:(NSString *)filePath address:(NSString *)address
                                          userID:(NSString *)userID
                                     fingerPrint:(NSString *)fingerPrint
{
    PEPSession *session = [PEPSession new];

    [PEPTestUtils importBundledKey:filePath];

    // Our test user:
    PEPIdentity *identTest = [[PEPIdentity alloc]
                              initWithAddress:address
                              userID:userID
                              userName:[NSString stringWithFormat:@"Some User Name %@", userID]
                              isOwn:YES
                              fingerPrint: fingerPrint];

    [session mySelf:identTest];
    XCTAssertNotNil(identTest.fingerPrint);
    XCTAssertEqualObjects(identTest.fingerPrint, fingerPrint);

    return identTest;
}

/**
 Verifies that a partner ID is really a correct Identity.
 Usually used on identities imported as keys, since the engine has problems with them.
 */
- (void)updateAndVerifyPartnerIdentity:(PEPIdentity *)partnerIdentity session:(PEPSession *)session
{
    XCTAssertNotNil(partnerIdentity.fingerPrint);
    [session updateIdentity:partnerIdentity];
    XCTAssertNotNil(partnerIdentity.fingerPrint);
    NSString *fingerprint = partnerIdentity.fingerPrint;
    partnerIdentity.fingerPrint = nil;
    [session updateIdentity:partnerIdentity];
    XCTAssertNotNil(partnerIdentity.fingerPrint);
    XCTAssertEqualObjects(partnerIdentity.fingerPrint, fingerprint);
}

- (PEPMessage *)mailWrittenToMySelf
{
    PEPSession *session = [PEPSession new];

    // Write a e-mail to yourself ...
    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];
    [session mySelf:me];

    NSString *shortMessage = @"Subject";
    NSString *longMessage = @"Oh, this is a long body text!";
    PEPMessage *mail = [PEPTestUtils mailFrom:me
                                      toIdent:me
                                 shortMessage:shortMessage
                                  longMessage:longMessage
                                     outgoing:YES];
    PEPMessage *encMessage;
    [session encryptMessage:mail identity:me dest:&encMessage];

    return encMessage;
}

- (PEPMessage *)internalEncryptToMySelfKeys:(PEPStringList **)keys
{
    PEPSession *session = [PEPSession new];
    
    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];
    [session mySelf:me];
    XCTAssertNotNil(me.fingerPrint);

    // Create draft
    NSString *shortMessage = @"Subject";
    NSString *longMessage = @"Oh, this is a long body text!";
    PEPMessage *mail = [PEPTestUtils mailFrom:me toIdent:me shortMessage:shortMessage longMessage:longMessage outgoing:YES];

    PEPMessage *encMessage;
    PEP_STATUS status = [session encryptMessage:mail identity:me dest:&encMessage];
    XCTAssertEqual(status, 0);
    XCTAssertEqualObjects(encMessage.shortMessage, @"p≡p");

    PEPMessage *unencDict;
    PEP_rating rating = [session decryptMessage:encMessage dest:&unencDict keys:keys];
    XCTAssertGreaterThanOrEqual(rating, PEP_rating_reliable);

    XCTAssertEqualObjects(unencDict.shortMessage, shortMessage);
    XCTAssertEqualObjects(unencDict.longMessage, longMessage);

    return unencDict;
}

- (void)pEpCleanUp
{
    [PEPTestUtils cleanUp];
}

- (void)pEpSetUp
{
}

- (void)helperXEncStatusForOutgoingEncryptdMailToSelf:(BOOL)toSelf
                                       expectedRating:(PEP_rating)expectedRating
{
    PEPSession *session = [PEPSession new];

    // Partner pubkey for the test:
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [PEPTestUtils importBundledKey:@"0x6FF00E97.asc"];

    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:ownUserId
                               userName:@"pEp Test Alice"
                               isOwn:NO
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];
    [self updateAndVerifyPartnerIdentity:identAlice session:session];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                               initWithAddress:@"me-myself-and-i@pep-project.org"
                               userID:@"me-myself-and-i"
                               userName:@"pEp Me"
                               isOwn:YES];
    [session mySelf:identMe];
    XCTAssertNotNil(identMe.fingerPrint);

    PEPMessage *msg = [PEPMessage new];
    msg.from = identMe;
    msg.to = @[identAlice];
    msg.shortMessage = @"Mail to Alice";
    msg.longMessage = @"Alice?";
    msg.direction = PEP_dir_outgoing;

    PEP_rating clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_reliable);

    PEPMessage *encMsg;

    PEP_STATUS statusEnc = PEP_VERSION_MISMATCH;
    if (toSelf) {
        statusEnc = [session encryptMessage:msg identity:identMe dest:&encMsg];
    } else {
         statusEnc = [session encryptMessage:msg extra:@[] dest:&encMsg];
    }

    XCTAssertEqual(statusEnc, PEP_STATUS_OK);

    XCTAssertNotNil(encMsg);

    PEPMessage *decMsg;
    PEPStringList *keys;
    PEP_rating pEpRating = [session decryptMessage:encMsg dest:&decMsg keys:&keys];
    XCTAssertEqual(pEpRating, expectedRating);
    XCTAssertNotNil(decMsg);

    NSArray * encStatusField = nil;
    for (NSArray *field in decMsg.optionalFields) {
        NSString *header = [field[0] lowercaseString];
        if ([header isEqualToString:@"x-encstatus"]) {
            encStatusField = field;
        }
    }
    XCTAssertNotNil(encStatusField);
    if (encStatusField) {
        PEP_rating outgoingRating = [session ratingFromString:encStatusField[1]];
        XCTAssertEqual(outgoingRating, expectedRating);
    }
}

@end
