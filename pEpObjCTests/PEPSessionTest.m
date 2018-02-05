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

- (void)testOutgoingColors
{
    PEPSession *session = [PEPSession new];

    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [PEPTestUtils importBundledKey:@"6FF00E97_sec.asc"];

    // Our test user :
    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:ownUserId
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    [session mySelf:identAlice];

    //Message

    PEPMessage *msg = [PEPMessage new];
    msg.from = identAlice;
    msg.to = @[[[PEPIdentity alloc] initWithAddress:@"pep.test.bob@pep-project.org"
                                             userID: @"42"
                                           userName:@"pEp Test Bob"
                                              isOwn:NO]];
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

    // Let' say we undo handshake
    [session keyResetTrust:identBob];

    // Yellow ?
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_reliable);

    // mistrust Bob
    [session keyMistrusted:identBob];

    // Gray == PEP_rating_unencrypted
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_unencrypted);

    // Forget
    [session keyResetTrust:identBob];

    // Back to yellow
    clr = [session outgoingColorForMessage:msg];
    XCTAssertEqual(clr, PEP_rating_reliable);

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

- (void)testRenewExpired
{
    PEPSession *session = [PEPSession new];

    // Our expired test user :
    // pEp Test Hector (old test key don't use) <pep.test.hector@pep-project.org>
    [PEPTestUtils importBundledKey:@"5CB2C182_sec.asc"];

    PEPIdentity *identHector = [[PEPIdentity alloc]
                                initWithAddress:@"pep.test.hector@pep-project.org"
                                userID:@"fc2d33" userName:@"pEp Test Hector"
                                isOwn:NO
                                fingerPrint:@"EEA655839E347EC9E10A5DE2E80CB3FD5CB2C182"];

    // Check that this key is indeed expired
    [session updateIdentity:identHector];
    XCTAssertEqual(PEP_ct_key_expired, identHector.commType);

    PEPIdentity *identHectorOwn = [[PEPIdentity alloc]
                                   initWithAddress:@"pep.test.hector@pep-project.org"
                                   userID:ownUserId userName:@"pEp Test Hector"
                                   isOwn:YES
                                   fingerPrint:@"EEA655839E347EC9E10A5DE2E80CB3FD5CB2C182"];

    // Myself automatically renew expired key.
    [session mySelf:identHectorOwn];
    XCTAssertEqual(PEP_ct_pEp, identHectorOwn.commType);

    [self pEpCleanUpRestoringBackupNamed:@"Bob"];


    [self pEpSetUp:@"Bob"];

    PEPIdentity *_identHector = [[PEPIdentity alloc]
                                 initWithAddress:@"pep.test.hector@pep-project.org"
                                 userID:@"khkhkh" userName:@"pEp Test Hector"
                                 isOwn:NO
                                 fingerPrint:@"EEA655839E347EC9E10A5DE2E80CB3FD5CB2C182"];

    [session updateIdentity:_identHector];
    XCTAssertEqual(PEP_ct_OpenPGP_unconfirmed, _identHector.commType);
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
    NSMutableDictionary *msgDict = [PEPTestUtils unarchiveDictionary:@"msg_to_A3FC7F0A_from_mutt.ser"].mutableCopy;
    [msgDict removeObjectForKey:kPepLongMessage];
    [msgDict removeObjectForKey:kPepLongMessageFormatted];

    // Also extracted "live" from the app.
    NSMutableDictionary *accountDict = [PEPTestUtils unarchiveDictionary:@"account_A3FC7F0A.ser"].mutableCopy;
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

- (void)testMessageTrustwordsWithMySelf
{
    PEPSession *session = [PEPSession new];

    PEPStringList *keys = nil;
    PEPMessage *decryptedDict = [self internalEncryptToMySelfKeys:&keys];
    XCTAssertNotNil(keys);
    XCTAssert(keys.count > 0);

    PEPIdentity *receiver = decryptedDict.to[0];
    [session updateIdentity:receiver];
    XCTAssertNotNil(receiver);
    PEP_STATUS trustwordsStatus;

    NSString *trustwords = [session getTrustwordsForMessage:decryptedDict
                                                   receiver:receiver
                                                  keysArray:keys language:@"en"
                                                       full:YES
                                            resultingStatus: &trustwordsStatus];
    // No trustwords with yourself
    XCTAssertEqual(trustwordsStatus, PEP_TRUSTWORDS_DUPLICATE_FPR);
    XCTAssertNil(trustwords);
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

#pragma mark - Helpers

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

- (void)pEpCleanUpRestoringBackupNamed:(NSString *)backup {
    [PEPTestUtils deleteWorkFilesAfterBackingUpWithBackupName:backup];
}

- (void)pEpCleanUp
{
    [PEPSession cleanup];
    [self pEpCleanUpRestoringBackupNamed:NULL];
}

- (void)pEpSetUp:(NSString *)restore
{
    // Must be the first thing you do before using anything pEp-related
    // ... but this is now done in session, with a "dispatch_once"
    // [PEPObjCAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];

    [PEPTestUtils deleteWorkFilesAfterBackingUpWithBackupName:nil];
    [PEPTestUtils restoreWorkFilesFromBackupNamed:restore];
}

- (void)pEpSetUp
{
    [self pEpSetUp:NULL];
}

@end
