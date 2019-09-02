//
//  PEPSessionTest.m
//  pEpObjCAdapterTests
//
//  Created by Andreas Buff on 18.01.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPObjCAdapterFramework.h"

#import "PEPObjCAdapter.h"
#import "PEPMessage.h"
#import "PEPAttachment.h"
#import "PEPTestUtils.h"
#import "PEPSync.h"
#import "PEPSendMessageDelegate.h"

#import "PEPSessionTestNotifyHandshakeDelegate.h"
#import "PEPSessionTestSendMessageDelegate.h"

@interface PEPSessionTest : XCTestCase

@property (nonatomic) PEPSync *sync;
@property (nonatomic) PEPSessionTestSendMessageDelegate *sendMessageDelegate;
@property (nonatomic) PEPSessionTestNotifyHandshakeDelegate *notifyHandshakeDelegate;

@end

@implementation PEPSessionTest

- (void)setUp
{
    [super setUp];

    [self pEpCleanUp];

    [PEPObjCAdapter setUnEncryptedSubjectEnabled:NO];
}

- (void)tearDown
{
    [self shutdownSync];
    [self pEpCleanUp];
    [super tearDown];
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
    XCTAssertNotEqual(identMe.commType, PEPCommTypeUnknown);

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
    XCTAssertNotEqual(identMe.commType, PEPCommTypeUnknown);

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

    XCTAssertTrue([session keyMistrusted:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingHaveNoKey);
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

    XCTAssertTrue([session keyMistrusted:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingHaveNoKey);
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
    XCTAssertEqual([self ratingForIdentity:me session:session], PEPRatingTrustedAndAnonymized);

    PEPIdentity *alice = [self
                          checkImportingKeyFilePath:@"6FF00E97_sec.asc"
                          address:@"pep.test.alice@pep-project.org"
                          userID:@"This Is Alice"
                          fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"
                          session: session];
    XCTAssertNotNil(alice);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingReliable);

    void (^encryptingBlock)(void) = ^{
        PEPSession *innerSession = [PEPSession new];
        PEPMessage *msg = [PEPMessage new];
        msg.from = me;
        msg.to = @[alice];
        msg.shortMessage = @"The subject";
        msg.longMessage = @"Lots and lots of text";
        msg.direction = PEPMsgDirectionIncoming;

        PEPStatus status;
        NSError *error = nil;
        PEPMessage *encMsg = [innerSession
                              encryptMessage:msg
                              forSelf:me
                              extraKeys:nil
                              status:&status error:&error];
        XCTAssertEqual(status, PEPStatusOK);
        XCTAssertNotNil(encMsg);
    };

    dispatch_group_t backgroundGroup = dispatch_group_create();
    dispatch_group_async(backgroundGroup,
                         dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), encryptingBlock);

    XCTAssertTrue([session trustPersonalKey:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingTrusted);

    XCTAssertTrue([session keyResetTrust:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingReliable);

    XCTAssertTrue([session keyMistrusted:alice error:&error]);
    XCTAssertNil(error);
    XCTAssertEqual([self ratingForIdentity:alice session:session], PEPRatingHaveNoKey);
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
    XCTAssertEqual(numRating.pEpRating, PEPRatingReliable);

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
    XCTAssertTrue([PEPTestUtils importBundledKey:@"0xC9C2EE39.asc" session:session]);

    PEPIdentity *identBob = [[PEPIdentity alloc]
                             initWithAddress:@"pep.test.bob@pep-project.org"
                             userID:@"42" userName:@"pEp Test Bob"
                             isOwn:NO
                             fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"];

    XCTAssertTrue([session updateIdentity:identBob error:&error]);
    XCTAssertNil(error);

    // Should be yellow, since no handshake happened.
    numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingReliable);

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
    msg.direction = PEPMsgDirectionOutgoing;

    NSNumber *numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingTrustedAndAnonymized);

    PEPMessage *encMsg = [session encryptMessage:msg extraKeys:nil status:nil error:&error];
    XCTAssertNotNil(encMsg);
    XCTAssertNil(error);

    NSArray *keys;

    error = nil;
    PEPRating rating = PEPRatingUndefined;
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
}

- (void)testEncryptedMailFromMuttWithReencryption
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
    PEPMessage *msgOriginal = [PEPMessage new];
    [msgOriginal setValuesForKeysWithDictionary:msgDict];

    XCTAssertEqualObjects(msg, msgOriginal);

    PEPRating rating = PEPRatingUndefined;
    PEPDecryptFlags flags = PEPDecryptFlagsUntrustedServer;

    PEPMessage *pepDecryptedMail = [session
                                    decryptMessage:msg
                                    flags:&flags
                                    rating:&rating
                                    extraKeys:&keys
                                    status:nil
                                    error:&error];
    XCTAssertNotNil(pepDecryptedMail);
    XCTAssertNil(error);

    // Technically, the mail is encrypted, but the signatures don't match
    XCTAssertEqual(rating, PEPRatingUnreliable);

    // Since we're requesting re-encryption, src should have been changed
    XCTAssertNotEqualObjects(msg, msgOriginal);

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

    PEPRating color = [self ratingForIdentity:partner1Orig session:session];
    XCTAssertEqual(color, PEPRatingReliable);
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
                                                      language:@"en" full:YES error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(trustwordsFull,
                          @"EMERSON GASPER TOKENISM BOLUS COLLAGE DESPISE BEDDED ENCRYPTION IMAGINE BEDFORD");

    NSString *trustwordsUndefined = [session getTrustwordsIdentity1:meOrig identity2:partner1Orig
                                                           language:@"ZZ" full:YES error:&error];
    XCTAssertNotNil(error);
    XCTAssertNil(trustwordsUndefined);
}

- (void)testStringToRating
{
    PEPSession *session = [PEPSession new];
    XCTAssertEqual([session ratingFromString:@"cannot_decrypt"], PEPRatingCannotDecrypt);
    XCTAssertEqual([session ratingFromString:@"have_no_key"], PEPRatingHaveNoKey);
    XCTAssertEqual([session ratingFromString:@"unencrypted"], PEPRatingUnencrypted);
    XCTAssertEqual([session ratingFromString:@"unencrypted_for_some"],
                   PEPRatingUnencryptedForSome);
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
    PEPSession *session = [PEPSession new];
    XCTAssertEqualObjects([session stringFromRating:PEPRatingCannotDecrypt], @"cannot_decrypt");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingHaveNoKey], @"have_no_key");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingUnencrypted], @"unencrypted");
    XCTAssertEqualObjects([session stringFromRating:PEPRatingUnencryptedForSome],
                          @"unencrypted_for_some");
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
    [self helperXEncStatusForOutgoingEncryptdMailToSelf:NO expectedRating:PEPRatingReliable];
}

- (void)testXEncStatusForOutgoingSelfEncryptedMail
{
    [self helperXEncStatusForOutgoingEncryptdMailToSelf:YES
                                         expectedRating:PEPRatingTrustedAndAnonymized];
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
    msg.direction = PEPMsgDirectionOutgoing;

    NSNumber *numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingUnencrypted);

    PEPMessage *encMsg = [session encryptMessage:msg extraKeys:nil status:nil error:&error];
    XCTAssertNotNil(encMsg);
    XCTAssertNil(error);

    XCTAssertNotNil(encMsg);

    PEPStringList *keys;
    PEPRating pEpRating;
    error = nil;
    PEPMessage *decMsg = [session
                          decryptMessage:encMsg
                          flags:nil
                          rating:&pEpRating
                          extraKeys:&keys
                          status:nil
                          error:&error];
    XCTAssertNotNil(decMsg);
    XCTAssertNil(error);

    XCTAssertEqual(pEpRating, PEPRatingUnencrypted);
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
    PEPSession *session = [PEPSession new];

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
    }
}

- (void)testTrustOwnKey
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    XCTAssertTrue([session trustOwnKeyIdentity:me error:&error]);
    XCTAssertNil(error);
}

#pragma mark - configUnencryptedSubject

- (void)testConfigUnencryptedSubject
{
    // Setup Config to encrypt subject
    [PEPObjCAdapter setUnEncryptedSubjectEnabled:NO];

    // Write mail to yourself ...
    PEPMessage *encMessage = [self mailWrittenToMySelf];

    // ... and assert subject is encrypted
    XCTAssertEqualObjects(encMessage.shortMessage, @"p≡p", @"Subject should be encrypted");
}

- (void)testConfigUnencryptedSubjectEncryptedSubjectDisabled
{
    // Setup Config to not encrypt subject
    [PEPObjCAdapter setUnEncryptedSubjectEnabled:YES];

    // Write mail to yourself ...
    PEPMessage *encMessage = [self mailWrittenToMySelf];

    // pEp to pEp uses message 2.0, which always encrypts subjects (ENGINE-429)
    XCTAssertEqualObjects(encMessage.shortMessage, @"p≡p", @"Subject should be encrypted");
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
    PEPSession *session = [PEPSession new];

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
    PEPRating rating = PEPRatingUndefined;
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

/**
 Prove that mySelf triggers a message to be sent.
 */
- (void)testBasicSendMessage
{
    PEPSession *session = [PEPSession new];
    [self testSendMessageOnSession:session];
}

- (void)testDeliverHandshakeResult
{
    PEPSession *session = [PEPSession new];
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

#pragma mark - key_reset_identity

- (void)testKeyResetIdentity
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *me = [PEPTestUtils ownPepIdentityWithAddress:@"me@peptest.ch"
                                                     userName:@"userName"];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:me error:&error]);
    XCTAssertNil(error);

    NSString *fprOriginal = me.fingerPrint;
    XCTAssertNotNil(fprOriginal);

    XCTAssertTrue([session keyReset:me fingerprint:nil error:&error]);
    XCTAssertNil(error);

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
    PEPSession *session = [PEPSession new];

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
    XCTAssertTrue([session leaveDeviceGroupError:&error]);
    XCTAssertNil(error);

    [self shutdownSync];
}

#pragma mark - enable/disable sync

- (void)testEnableDisableSyncOnOwnIdentityWithQuery
{
    PEPSession *session = [PEPSession new];

    PEPIdentity *identMe1 = [[PEPIdentity alloc]
                             initWithAddress:@"me-myself-and-i@pep-project.org"
                             userID:@"me-myself-and-i"
                             userName:@"pEp Me"
                             isOwn:YES];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:identMe1 error:&error]);
    XCTAssertNil(error);

    error = nil;
    PEPIdentity *identMe2 = [[PEPIdentity alloc]
                             initWithAddress:@"me-myself-and-i2@pep-project.org"
                             userID:@"me-myself-and-i2"
                             userName:@"pEp Me2"
                             isOwn:YES];
    XCTAssertTrue([session mySelf:identMe2 error:&error]);
    XCTAssertNil(error);

    XCTAssertNotEqualObjects(identMe1.fingerPrint, identMe2.fingerPrint);

    for (int i = 0; i < 10; ++i) {
        error = nil;
        BOOL enable = i % 2 == 0; // enable keysync on even numbers (roughly)
        if (enable) {
            XCTAssertTrue([session enableSyncForIdentity:identMe1 error:&error]);
            XCTAssertTrue([identMe2 enableKeySync:&error]);
        } else {
            XCTAssertTrue([session disableSyncForIdentity:identMe1 error:&error]);
            XCTAssertTrue([identMe2 disableKeySync:&error]);
        }
        XCTAssertNil(error);

        NSNumber *keySyncState1 = [session queryKeySyncEnabledForIdentity:identMe1 error:&error];
        NSNumber *keySyncState2 = [identMe2 queryKeySyncEnabled:&error];
        XCTAssertNil(error);
        XCTAssertNotNil(keySyncState1);
        XCTAssertNotNil(keySyncState2);
        if (enable) {
            XCTAssertTrue([keySyncState1 boolValue]);
        } else {
            XCTAssertFalse([keySyncState1 boolValue]);
        }
        XCTAssertEqualObjects(keySyncState1, keySyncState2);
    }
}

- (void)testQueryKeySyncOnOwnIdentityInALoop
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

    for (NSNumber *numBool in @[@YES, @NO]) {
        error = nil;
        if ([numBool boolValue]) {
            XCTAssertTrue([session enableSyncForIdentity:identMe error:&error]);
        } else {
            XCTAssertTrue([session disableSyncForIdentity:identMe error:&error]);
        }
        XCTAssertNil(error);

        for (int i = 0; i < 10; ++i) {
            NSNumber *numQuery = [session queryKeySyncEnabledForIdentity:identMe error:&error];
            XCTAssertNotNil(numQuery);
            XCTAssertEqualObjects(numBool, numQuery);
            XCTAssertNil(error);
        }
    }
}

#pragma mark - Helpers

- (void)testSendMessageOnSession:(PEPSession *)session
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

    [self startSync];

    XCTKVOExpectation *expHaveMessage = [[XCTKVOExpectation alloc]
                                         initWithKeyPath:@"lastMessage"
                                         object:self.sendMessageDelegate];

    XCTAssertNotNil(identMe.fingerPrint);

    [self waitForExpectations:@[expHaveMessage] timeout:PEPTestInternalSyncTimeout];
    XCTAssertNotNil(self.sendMessageDelegate.lastMessage);

    XCTAssertEqual(self.sendMessageDelegate.messages.count, 1);
    [self shutdownSync];
}

- (void)startSync
{
    self.sendMessageDelegate = [PEPSessionTestSendMessageDelegate new];
    self.notifyHandshakeDelegate = [PEPSessionTestNotifyHandshakeDelegate new];

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
                                             session:(PEPSession *)session
                                               error:(NSError * _Nullable * _Nullable)error
{
    NSNumber *ratingOriginal = [session outgoingRatingForMessage:theMessage error:error];
    NSNumber *ratingPreview = [session outgoingRatingPreviewForMessage:theMessage error:nil];
    XCTAssertEqual(ratingOriginal, ratingPreview);
    return ratingOriginal;
}

- (void)testPassiveModeEnabled:(BOOL)passiveModeEnabled
{
    [PEPObjCAdapter setPassiveModeEnabled:passiveModeEnabled];
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
- (PEPRating)ratingForIdentity:(PEPIdentity *)identity session:(PEPSession *)session
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

- (PEPIdentity *)checkMySelfImportingKeyFilePath:(NSString *)filePath
                                         address:(NSString *)address
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

    PEPStatus status;
    PEPMessage *encMessage = [session
                              encryptMessage:mail
                              forSelf:me
                              extraKeys:nil
                              status:&status
                              error:&error];
    XCTAssertEqual(status, 0);
    XCTAssertEqualObjects(encMessage.shortMessage, @"p≡p");

    PEPRating rating;
    error = nil;
    PEPMessage *unencDict = [session
                             decryptMessage:encMessage
                             flags:nil
                             rating:&rating
                             extraKeys:keys
                             status:nil
                             error:&error];
    XCTAssertNotNil(unencDict);
    XCTAssertNil(error);

    XCTAssertGreaterThanOrEqual(rating, PEPRatingReliable);

    XCTAssertEqualObjects(unencDict.shortMessage, shortMessage);
    XCTAssertEqualObjects(unencDict.longMessage, longMessage);

    return unencDict;
}

- (void)pEpCleanUp
{
    [PEPTestUtils cleanUp];
}

- (void)helperXEncStatusForOutgoingEncryptdMailToSelf:(BOOL)toSelf
                                       expectedRating:(PEPRating)expectedRating
{
    PEPSession *session = [PEPSession new];

    // Partner pubkey for the test:
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    XCTAssertTrue([PEPTestUtils importBundledKey:@"6FF00E97.asc" session:session]);

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

    PEPStringList *keys;
    PEPRating pEpRating;
    error = nil;
    PEPMessage *decMsg = [session
                          decryptMessage:encMsg
                          flags:nil
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
        PEPRating outgoingRating = [session ratingFromString:encStatusField[1]];
        XCTAssertEqual(outgoingRating, expectedRating);
    }
}

@end
