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
#import "PEPAttachment.h"
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

- (void)tearDown
{
    [self pEpCleanUp];
    [super tearDown];
}

- (void)testSyncSession
{
    PEPSession *session = [PEPSession new];

    // Dummy to set up the DB, since this is currenty only triggered by session use,
    // which PEPObjCAdapter.startSync does not trigger.
    NSError *error = nil;
    XCTAssertNotNil([session getLogWithError:&error]);
    XCTAssertNil(error);

    PEPTestSyncDelegate *syncDelegate = [[PEPTestSyncDelegate alloc] init];

    // This should attach session just created
    [PEPObjCAdapter startSync:syncDelegate];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"pep.test.iosgenkey@pep-project.org"
                            userID:@"Me"
                            userName:@"pEp Test iOS GenKey"
                            isOwn:YES];

    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);

    bool res = [syncDelegate waitUntilSent:1];

    // Can't currently work, engine doesn't contain sync.
    XCTAssertFalse(res);

    // This should detach session just created
    [PEPObjCAdapter stopSync];
}

- (void)testTrustWords
{
    PEPSession *session = [PEPSession new];

    NSError *error = nil;
    NSArray *trustwords = [session
                           trustwordsForFingerprint:@"DB47DB47DB47DB47DB47DB47DB47DB47DB47DB47"
                           languageID:@"en"
                           shortened:false
                           error:&error];
    XCTAssertNil(error);
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

    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(identMe.fingerPrint);
    XCTAssertNotEqual(identMe.commType, PEP_ct_unknown);

    XCTAssertTrue([identMe isPEPUser:session error:&error]);
}

- (void)testMySelfCommType
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *identMe = [[PEPIdentity alloc]
                            initWithAddress:@"pep.test.iosgenkey@pep-project.org"
                            userID:@"pep.test.iosgenkey@pep-project.org_userID"
                            userName:@"pEp Test iOS GenKey"
                            isOwn:YES];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(identMe.fingerPrint);
    XCTAssertNotEqual(identMe.commType, PEP_ct_unknown);

    XCTAssertTrue([identMe isPEPUser:session error:&error]);

    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
    dispatch_sync(queue, ^{
        NSError *innerError = nil;
        PEPSession *session2 = [PEPSession new];

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
    PEPSession *session = [PEPSession new];

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
    PEPSession *session = [PEPSession new];

    PEPIdentity *me = [self
                       checkMySelfImportingKeyFilePath:@"6FF00E97_sec.asc"
                       address:@"pep.test.alice@pep-project.org"
                       userID:@"Alice_User_ID"
                       fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                       session:session];
    XCTAssertEqual([self ratingForIdentity:me session:session], PEP_rating_trusted_and_anonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_reliable);
}

/** ENGINE-409 */
- (void)testIdentityRatingMistrustReset
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *me = [[PEPIdentity alloc]
                       initWithAddress:@"me@example.org"
                       userID:@"me_myself"
                       userName:@"Me Me"
                       isOwn:YES];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(me.fingerPrint);
    XCTAssertEqual([self ratingForIdentity:me session:session], PEP_rating_trusted_and_anonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_reliable);

    XCTAssertTrue([session keyMistrusted:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_have_no_key);

    XCTAssertTrue([session keyResetTrust:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_reliable);
}

- (void)testIdentityRatingTrustResetMistrustUndo
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *me = [[PEPIdentity alloc]
                       initWithAddress:@"me@example.org"
                       userID:@"me_myself"
                       userName:@"Me Me"
                       isOwn:YES];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(me.fingerPrint);
    XCTAssertEqual([self ratingForIdentity:me session:session], PEP_rating_trusted_and_anonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_reliable);

    XCTAssertTrue([session trustPersonalKey:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_trusted);

    XCTAssertTrue([session keyResetTrust:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_reliable);

    XCTAssertTrue([session keyMistrusted:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_have_no_key);

    XCTAssertTrue([session undoLastMistrustWithError:&error]);
    XCTAssertNil(error);

    // After ENGINE-371 has been fixed, this should be just PEP_rating_reliable
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_trusted);

    XCTAssertTrue([session trustPersonalKey:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_trusted);

    XCTAssertTrue([session keyResetTrust:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_reliable);
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
    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(me.fingerPrint);
    XCTAssertEqual([self ratingForIdentity:me session:session], PEP_rating_trusted_and_anonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_reliable);

    XCTAssertTrue([session trustPersonalKey:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_trusted);

    XCTAssertTrue([session keyResetTrust:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_reliable);

    XCTAssertTrue([session keyMistrusted:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_have_no_key);

    XCTAssertTrue([session undoLastMistrustWithError:&error]);
    XCTAssertNil(error);

    XCTAssertTrue([session trustPersonalKey:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_trusted);

    XCTAssertTrue([session keyResetTrust:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_reliable);

    // This line provoked the crash
    XCTAssertTrue([session trustPersonalKey:alice error:&error]);
    XCTAssertNil(error);
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
    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(me.fingerPrint);
    XCTAssertEqual([self ratingForIdentity:me session:session], PEP_rating_trusted_and_anonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_reliable);

    void (^encryptingBlock)(void) = ^{
        PEPSession *innerSession = [PEPSession new];
        PEPMessage *msg = [PEPMessage new];
        msg.from = me;
        msg.to = @[alice];
        msg.shortMessage = @"The subject";
        msg.longMessage = @"Lots and lots of text";
        msg.direction = PEP_dir_outgoing;

        PEP_STATUS status;
        NSError *error = nil;
        PEPMessage *encMsg = [innerSession
                              encryptMessage:msg
                              forSelf:me
                              extraKeys:nil
                              status:&status error:&error];
        XCTAssertEqual(status, PEP_STATUS_OK);
        XCTAssertNotNil(encMsg);
    };

    dispatch_group_t backgroundGroup = dispatch_group_create();
    dispatch_group_async(backgroundGroup,
                         dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), encryptingBlock);

    XCTAssertTrue([session trustPersonalKey:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_trusted);

    XCTAssertTrue([session keyResetTrust:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_reliable);

    XCTAssertTrue([session keyMistrusted:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_have_no_key);

    XCTAssertTrue([session undoLastMistrustWithError:&error]);
    XCTAssertNil(error);

    // After ENGINE-371 has been fixed, this should be just PEP_rating_reliable
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_trusted);

    XCTAssertTrue([session trustPersonalKey:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_trusted);

    XCTAssertTrue([session keyResetTrust:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEP_rating_reliable);

    dispatch_group_wait(backgroundGroup, DISPATCH_TIME_FOREVER);
}

- (void)testOutgoingColors
{
    PEPSession *session = [PEPSession new];

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
        msgGray.direction = PEP_dir_outgoing;

        NSError *error = nil;

        // Test with unknown Bob
        NSNumber *numRating = [session outgoingRatingForMessage:msgGray error:&error];
        XCTAssertNotNil(numRating);
        XCTAssertNil(error);
        XCTAssertEqual(numRating.pEpRating, PEP_rating_unencrypted);
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
    msg.direction = PEP_dir_outgoing;

    NSError *error = nil;

    // Should be yellow, since no handshake happened.
    NSNumber *numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_reliable);

    PEP_rating rating = [self ratingForIdentity:identBob session:session];
    XCTAssertEqual(rating, PEP_rating_reliable);

    // Let' say we got that handshake, set PEP_ct_confirmed in Bob's identity
    XCTAssertTrue([session trustPersonalKey:identBob error:&error]);
    XCTAssertNil(error);

    // This time it should be green
    numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_trusted);

    rating = [self ratingForIdentity:identBob session:session];
    XCTAssertEqual(rating, PEP_rating_trusted);

    // Let' say we undo handshake
    XCTAssertTrue([session keyResetTrust:identBob error:&error]);
    XCTAssertNil(error);

    // Yellow ?
    numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_reliable);

    // mistrust Bob
    XCTAssertTrue([session keyMistrusted:identBob error:&error]);
    XCTAssertNil(error);

    identBob.fingerPrint = nil;
    XCTAssertTrue([session updateIdentity:identBob error:&error]);
    XCTAssertNil(error);
    XCTAssertNil(identBob.fingerPrint);

    // Gray == PEP_rating_unencrypted
    numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_unencrypted);

    // Undo
    XCTAssertTrue([session undoLastMistrustWithError:&error]);
    XCTAssertNil(error);
    XCTAssertTrue([session updateIdentity:identBob error:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(identBob.fingerPrint);

    // Back to yellow
    numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);

    // After ENGINE-371 has been fixed, this should be just PEP_rating_reliable
    XCTAssertEqual(numRating.pEpRating, PEP_rating_trusted);
    XCTAssertEqual([self ratingForIdentity:identBob session:session], PEP_rating_trusted);

    // Trust again
    XCTAssertTrue([session trustPersonalKey:identBob error:&error]);
    XCTAssertNil(error);

    // Back to green
    numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_trusted);

    // Now let see if it turns back yellow if we add an unconfirmed folk.
    // pEp Test John (test key, don't use) <pep.test.john@pep-project.org>
    // AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575
    XCTAssertTrue([PEPTestUtils importBundledKey:@"0x70DCF575.asc" session:session]);

    PEPIdentity *identJohn = [[PEPIdentity alloc]
                              initWithAddress:@"pep.test.john@pep-project.org"
                              userID:@"101" userName:@"pEp Test John"
                              isOwn:NO
                              fingerPrint:@"AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575"];

    XCTAssertTrue([session updateIdentity:identJohn error:&error]);
    XCTAssertNil(error);

    msg.cc = @[[PEPTestUtils foreignPepIdentityWithAddress:@"pep.test.john@pep-project.org"
                                                  userName:@"pEp Test John"]];
    // Yellow ?
    numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_reliable);

    PEPMessage *encMsg = [session encryptMessage:msg extraKeys:nil status:nil error:&error];
    XCTAssertNotNil(encMsg);
    XCTAssertNil(error);

    XCTAssertEqualObjects(encMsg.shortMessage, @"p≡p");
    XCTAssertTrue([encMsg.longMessage containsString:@"p≡p"]);
}


- (void)testOutgoingBccColors
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
    msg.to = @[[[PEPIdentity alloc] initWithAddress:@"pep.test.bob@pep-project.org"
                                             userID:@"42" userName:@"pEp Test Bob" isOwn:NO]];
    msg.shortMessage = @"All Green Test";
    msg.longMessage = @"This is a text content";
    msg.direction = PEP_dir_outgoing;

    // Test with unknown Bob
    PEP_rating rating;
    NSNumber *numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_unencrypted);

    // Now let see with bob's pubkey already known
    // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
    // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
    XCTAssertTrue([PEPTestUtils importBundledKey:@"0xC9C2EE39.asc" session:session]);

    PEPIdentity *identBob = [[PEPIdentity alloc]
                             initWithAddress:@"pep.test.bob@pep-project.org"
                             userID:@"42" userName:@"pEp Test Bob"
                             isOwn:NO
                             fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"];

    XCTAssertTrue([session updateIdentity:identBob error:&error]);
    XCTAssertNil(error);

    // Should be yellow, since no handshake happened.
    numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_reliable);

    rating = [self ratingForIdentity:identBob session:session];
    XCTAssertEqual(rating, PEP_rating_reliable);

    // Let' say we got that handshake, set PEP_ct_confirmed in Bob's identity
    XCTAssertTrue([session trustPersonalKey:identBob error:&error]);
    XCTAssertNil(error);

    // This time it should be green
    numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_trusted);

    rating = [self ratingForIdentity:identBob session:session];
    XCTAssertEqual(rating, PEP_rating_trusted);

    // Now let see if it turns back yellow if we add an unconfirmed folk.
    // pEp Test John (test key, don't use) <pep.test.john@pep-project.org>
    // AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575
    XCTAssertTrue([PEPTestUtils importBundledKey:@"0x70DCF575.asc" session:session]);

    PEPIdentity *identJohn = [[PEPIdentity alloc]
                              initWithAddress:@"pep.test.john@pep-project.org"
                              userID:@"101" userName:@"pEp Test John"
                              isOwn:NO
                              fingerPrint:@"AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575"];

    XCTAssertTrue([session updateIdentity:identJohn error:&error]);
    XCTAssertNil(error);

    msg.bcc = @[[[PEPIdentity alloc] initWithAddress:@"pep.test.john@pep-project.org"
                                              userID:@"101" userName:@"pEp Test John" isOwn:NO]];

    // Yellow ?
    numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_reliable);

    XCTAssertTrue([session trustPersonalKey:identJohn error:&error]);
    XCTAssertNil(error);

    // This time it should be green
    numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_trusted);

    rating = [self ratingForIdentity:identJohn session:session];
    XCTAssertEqual(rating, PEP_rating_trusted);
}

- (void)testDontEncryptForMistrusted
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

    // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
    // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
    XCTAssertTrue([PEPTestUtils importBundledKey:@"0xC9C2EE39.asc" session:session]);

    PEPIdentity *identBob = [[PEPIdentity alloc]
                             initWithAddress:@"pep.test.bob@pep-project.org"
                             userID:@"42" userName:@"pEp Test Bob"
                             isOwn:NO
                             fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"];

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
    msg.direction = PEP_dir_outgoing;

    // Gray == PEP_rating_unencrypted
    NSNumber *numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_unencrypted);

    PEPMessage *encMsg = [session encryptMessage:msg extraKeys:nil status:nil error:&error];
    XCTAssertNotNil(encMsg);
    XCTAssertNil(error);

    XCTAssertNotEqualObjects(encMsg.attachments[0].mimeType, @"application/pgp-encrypted");

    [self pEpCleanUp];
}

- (void)testRevoke
{
    PEPSession *session = [PEPSession new];

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
    msg.direction = PEP_dir_outgoing;

    NSNumber *numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_trusted_and_anonymized);

    PEPMessage *encMsg = [session encryptMessage:msg extraKeys:nil status:nil error:&error];
    XCTAssertNotNil(encMsg);
    XCTAssertNil(error);

    NSArray *keys;

    error = nil;
    PEP_rating rating = PEP_rating_b0rken;
    PEPMessage *decmsg = [session
                          decryptMessage:encMsg
                          rating:&rating
                          extraKeys:&keys
                          status:nil
                          error:&error];
    XCTAssertNotNil(decmsg);
    XCTAssertNil(error);
    XCTAssertEqual(rating, PEP_rating_trusted_and_anonymized);
}

- (void)testEncryptedMailFromMutt
{
    PEPSession *session = [PEPSession new];

    // This is the public key for test001@peptest.ch
    XCTAssertTrue([PEPTestUtils importBundledKey:@"A3FC7F0A.asc" session:session]);

    // This is the secret key for test001@peptest.ch
    XCTAssertTrue([PEPTestUtils importBundledKey:@"A3FC7F0A_sec.asc" session:session]);

    // Mail from mutt, already processed into message dict by the app.
    NSMutableDictionary *msgDict = [[PEPTestUtils
                                     unarchiveDictionary:@"msg_to_A3FC7F0A_from_mutt.ser"]
                                    mutableCopy];
    [PEPTestUtils migrateUnarchivedMessageDictionary:msgDict];
    [msgDict removeObjectForKey:kPepLongMessage];
    [msgDict removeObjectForKey:kPepLongMessageFormatted];

    // Also extracted "live" from the app.
    NSMutableDictionary *accountDict = [[PEPTestUtils
                                         unarchiveDictionary:@"account_A3FC7F0A.ser"]
                                        mutableCopy];
    [accountDict removeObjectForKey:kPepCommType];
    [accountDict removeObjectForKey:kPepFingerprint];
    PEPIdentity *identMe = [[PEPIdentity alloc] initWithDictionary:accountDict];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(identMe.fingerPrint);

    NSArray* keys;
    PEPMessage *msg = [PEPMessage new];
    [msg setValuesForKeysWithDictionary:msgDict];

    // Technically, the mail is encrypted, but the signatures don't match
    PEPMessage *pepDecryptedMail = [session
                                    decryptMessage:msg
                                    rating:nil
                                    extraKeys:&keys
                                    status:nil
                                    error:&error];
    XCTAssertNotNil(pepDecryptedMail);
    XCTAssertNil(error);

    XCTAssertNotNil(pepDecryptedMail.longMessage);
}

- (void)testOutgoingContactColor
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *partner1Orig = [PEPTestUtils foreignPepIdentityWithAddress:@"partner1@dontcare.me"
                                                                   userName:@"Partner 1"];
    NSString *pubKeyPartner1 = [PEPTestUtils loadResourceByName:@"partner1_F2D281C2789DD7F6_pub.asc"];
    XCTAssertNotNil(pubKeyPartner1);

    NSError *error = nil;
    XCTAssertTrue([session importKey:pubKeyPartner1 error:&error]);
    XCTAssertNil(error);

    PEP_rating color = [self ratingForIdentity:partner1Orig session:session];
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

    NSError *error = nil;
    NSString *trustwordsFull = [session getTrustwordsIdentity1:meOrig identity2:partner1Orig
                                                      language:nil full:YES error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(trustwordsFull,
                          @"EMERSON GASPER TOKENISM BOLUS COLLAGE DESPISE BEDDED ENCRYPTION IMAGINE BEDFORD");

    NSString *trustwordsFullEnglish = [session getTrustwordsIdentity1:meOrig identity2:partner1Orig
                                                             language:@"en" full:YES error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(trustwordsFullEnglish, trustwordsFull);

    NSString *trustwordsUndefined = [session getTrustwordsIdentity1:meOrig identity2:partner1Orig
                                                           language:@"ZZ" full:YES error:&error];
    XCTAssertNotNil(error);
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
    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(identMe.fingerPrint);

    // PEP_CANNOT_FIND_PERSON == 902
    XCTAssertTrue([session isPEPUser:identMe error:&error]);
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
    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);

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

    NSNumber *numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_unencrypted);

    PEPMessage *encMsg = [session encryptMessage:msg extraKeys:nil status:nil error:&error];
    XCTAssertNotNil(encMsg);
    XCTAssertNil(error);

    XCTAssertNotNil(encMsg);

    PEPStringList *keys;
    PEP_rating pEpRating;
    error = nil;
    PEPMessage *decMsg = [session
                          decryptMessage:encMsg
                          rating:&pEpRating
                          extraKeys:&keys
                          status:nil
                          error:&error];
    XCTAssertNotNil(decMsg);
    XCTAssertNil(error);

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

    PEPIdentity *identAlice = [self
                               checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                               address:@"pep.test.alice@pep-project.org"
                               userID:@"alice_user_id"
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                               session: session];
    XCTAssertNotNil(identAlice);

    dispatch_group_t identityRatingGroup = dispatch_group_create();

    void (^ratingBlock)(void) = ^{
        PEPSession *innerSession = [PEPSession new];
        PEP_rating rating = [self ratingForIdentity:identAlice session:innerSession];
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

/**
 Determines the rating for the given identity.
 @return PEP_rating_undefined on error
 */
- (PEP_rating)ratingForIdentity:(PEPIdentity *)identity session:(PEPSession *)session
{
    NSError *error;
    NSNumber *numRating = [session ratingForIdentity:identity error:&error];
    XCTAssertNil(error);
    return numRating.pEpRating;
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

- (PEPIdentity *)checkMySelfImportingKeyFilePath:(NSString *)filePath address:(NSString *)address
                                          userID:(NSString *)userID
                                     fingerPrint:(NSString *)fingerPrint
                                         session:(PEPSession *)session
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
    PEP_STATUS status = PEP_UNKNOWN_ERROR;
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
    PEPSession *session = [PEPSession new];
    
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

    PEP_STATUS status;
    PEPMessage *encMessage = [session
                              encryptMessage:mail
                              forSelf:me
                              extraKeys:nil
                              status:&status
                              error:&error];
    XCTAssertEqual(status, 0);
    XCTAssertEqualObjects(encMessage.shortMessage, @"p≡p");

    PEP_rating rating;
    error = nil;
    PEPMessage *unencDict = [session
                             decryptMessage:encMessage
                             rating:&rating
                             extraKeys:keys
                             status:nil
                             error:&error];
    XCTAssertNotNil(unencDict);
    XCTAssertNil(error);

    XCTAssertGreaterThanOrEqual(rating, PEP_rating_reliable);

    XCTAssertEqualObjects(unencDict.shortMessage, shortMessage);
    XCTAssertEqualObjects(unencDict.longMessage, longMessage);

    return unencDict;
}

- (void)pEpCleanUp
{
    [PEPTestUtils cleanUp];
}

- (void)helperXEncStatusForOutgoingEncryptdMailToSelf:(BOOL)toSelf
                                       expectedRating:(PEP_rating)expectedRating
{
    PEPSession *session = [PEPSession new];

    // Partner pubkey for the test:
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    XCTAssertTrue([PEPTestUtils importBundledKey:@"0x6FF00E97.asc" session:session]);

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
    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe error:&error]);
    XCTAssertNil(error);

    XCTAssertNotNil(identMe.fingerPrint);

    PEPMessage *msg = [PEPMessage new];
    msg.from = identMe;
    msg.to = @[identAlice];
    msg.shortMessage = @"Mail to Alice";
    msg.longMessage = @"Alice?";
    msg.direction = PEP_dir_outgoing;

    NSNumber *numRating = [session outgoingRatingForMessage:msg error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEP_rating_reliable);

    PEPMessage *encMsg;

    PEP_STATUS statusEnc = PEP_VERSION_MISMATCH;
    if (toSelf) {
        encMsg = [session
                  encryptMessage:msg
                  forSelf:identMe
                  extraKeys:nil
                  status:&statusEnc
                  error:&error];
        XCTAssertEqual(statusEnc, PEP_STATUS_OK);
    } else {
        encMsg = [session encryptMessage:msg extraKeys:nil status:nil error:&error];
        XCTAssertNotNil(encMsg);
        XCTAssertNil(error);
    }
    XCTAssertNotNil(encMsg);

    PEPStringList *keys;
    PEP_rating pEpRating;
    error = nil;
    PEPMessage *decMsg = [session
                          decryptMessage:encMsg
                          rating:&pEpRating
                          extraKeys:&keys
                          status:nil
                          error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(decMsg);

    XCTAssertEqual(pEpRating, expectedRating);

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
