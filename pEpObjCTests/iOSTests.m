//
//  iOSTests.m
//  iOSTests
//
//  Created by Edouard Tisserant on 03/11/15.
//  Copyright © 2015 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPObjCAdapter.h"
#import "PEPInternalSession.h"

#import "NSDictionary+Extension.h"
#import "PEPIdentity.h"

// MARK: - Helpers

PEPDict * _Nonnull mailFromTo(PEPDict * _Nullable fromDict, PEPDict * _Nullable toDict,
                              NSString *shortMessage, NSString *longMessage, BOOL outgoing) {
    PEPMutableDict *dict = [NSMutableDictionary dictionary];
    if (fromDict) {
        dict[kPepFrom] = fromDict;
    }
    if (toDict) {
        dict[kPepTo] = @[toDict];
    }
    if (outgoing) {
        dict[kPepOutgoing] = @YES;
    } else {
        dict[kPepOutgoing] = @NO;
    }
    dict[kPepShortMessage] = shortMessage;
    dict[kPepLongMessage] = longMessage;
    return [NSDictionary dictionaryWithDictionary:dict];
}

/**
 For now, safer to use that, until the engine copes with our own.
 Should mimick the value of PEP_OWN_USERID.
 */
static NSString *s_userID = @"pEp_own_userId";

// MARK: - PEPSyncDelegate

@interface SomeSyncDelegate : NSObject<PEPSyncDelegate>

- (BOOL)waitUntilSent:(time_t)maxSec;

@property (nonatomic) bool sendWasCalled;
@property (nonatomic, strong) NSCondition *cond;

@end

@implementation SomeSyncDelegate

- (id)init
{
    if (self = [super init])  {
        self.sendWasCalled = false;
        self.cond = [[NSCondition alloc] init];
    }
    return self;
}

- (PEP_STATUS)notifyHandshakeWithSignal:(sync_handshake_signal)signal me:(id)me
                                partner:(id)partner
{
    return PEP_STATUS_OK;
}

- (PEP_STATUS)sendMessage:(id)msg
{
    [_cond lock];

    self.sendWasCalled = true;
    [_cond signal];
    [_cond unlock];

    return PEP_STATUS_OK;
}

- (PEP_STATUS)fastPolling:(bool)isfast
{
    return PEP_STATUS_OK;
}

- (BOOL)waitUntilSent:(time_t)maxSec
{
    bool res;
    [_cond lock];
    [_cond waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:maxSec]];
    res = _sendWasCalled;
    [_cond unlock];
    return res;
}

@end

// MARK: - iOSTests

@interface iOSTests : XCTestCase

@end

@implementation iOSTests

PEPInternalSession *session;

- (void)setUp
{
    [PEPSession cleanup];
}

#pragma mark -- Helpers

- (void)delFilePath:(NSString *)path backupAs:(NSString *)bkpsfx {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager fileExistsAtPath:path]) {
        BOOL success;
        if (!bkpsfx) {
            success = [fileManager removeItemAtPath:path error:&error];
        } else {
            NSString *toPath = [path stringByAppendingString:bkpsfx];
            
            if ([fileManager fileExistsAtPath:toPath]) {
                [fileManager removeItemAtPath:toPath error:&error];
            }
            
            success = [fileManager moveItemAtPath:path toPath:toPath error:&error];
        }
        if (!success) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }
}

- (void)undelFileWithPath:(NSString *)path backup:(NSString *)backup {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString* bpath = [path stringByAppendingString:backup];
    BOOL fileExists = [fileManager fileExistsAtPath:bpath];
    if (fileExists) {
        BOOL success;
        success = [fileManager moveItemAtPath:bpath toPath:path error:&error];
        if (!success) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }
}

- (NSArray *)pEpWorkFiles
{
    // Only files whose content is affected by tests.
    NSString* home = [[[NSProcessInfo processInfo]environment]objectForKey:@"HOME"];
    NSString* gpgHome = [home stringByAppendingPathComponent:@".gnupg"];
    return @[[home stringByAppendingPathComponent:@".pEp_management.db"],
             [home stringByAppendingPathComponent:@".pEp_management.db-shm"],
             [home stringByAppendingPathComponent:@".pEp_management.db-wal"],
             [gpgHome stringByAppendingPathComponent:@"pubring.gpg"],
             [gpgHome stringByAppendingPathComponent:@"secring.gpg"]];
    
}

- (void)pEpCleanUp:(NSString *)backup {
    session = nil;
    [PEPSession cleanup];
    
    for (id path in [self pEpWorkFiles]) {
        [self delFilePath:path backupAs:backup];
    }
}

- (void)pEpCleanUp
{
    [self pEpCleanUp:NULL];
}

- (void)pEpSetUp:(NSString *)restore
{
    // Must be the first thing you do before using anything pEp-related
    // ... but this is now done in session, with a "dispatch_once"
    // [PEPObjCAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];

    for (id path in [self pEpWorkFiles]) {
        [self delFilePath:path backupAs:nil];
    }

    if (restore) {
        for (id path in [self pEpWorkFiles]) {
            [self undelFileWithPath:path backup:restore];
        }
    }

    session = [[PEPInternalSession alloc] init];
    XCTAssert(session);
}

- (void)pEpSetUp
{
    [self pEpSetUp:NULL];
}

- (void)importBundledKey:(NSString *)item
{
    [self importBundledKey:item intoSession:session];
}

- (NSString *)loadStringFromFileName:(NSString *)fileName
{
    NSString *txtFilePath = [[[NSBundle bundleForClass:[self class]] resourcePath]
                             stringByAppendingPathComponent:fileName];
    NSString *txtFileContents = [NSString stringWithContentsOfFile:txtFilePath
                                                          encoding:NSUTF8StringEncoding error:NULL];
    return txtFileContents;
}

- (void)importBundledKey:(NSString *)item intoSession:(PEPInternalSession *)theSession
{

    NSString *txtFileContents = [self loadStringFromFileName:item];
    [theSession importKey:txtFileContents];
}

- (NSDictionary *)unarchiveDictionary:(NSString *)fileName
{
    NSString *filePath = [[[NSBundle bundleForClass:[self class]]
                           resourcePath] stringByAppendingPathComponent:fileName];
    NSMutableData *data = [NSMutableData dataWithContentsOfFile:filePath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict = [unarchiver decodeObject];
    [unarchiver finishDecoding];
    return dict;
}

#pragma mark -- Tests

- (void)testEmptySession
{
    [self pEpSetUp];

    // Do nothing.

    [self pEpCleanUp];
}


- (void)testNestedSessions
{
    [self pEpSetUp];

    PEPInternalSession *session2 = [[PEPInternalSession alloc] init];

    session2 = nil;

    [self pEpCleanUp];
}

- (void)testShortKeyServerLookup
{
    [self pEpSetUp];
    [PEPObjCAdapter startKeyserverLookup];
    
    // Do nothing.
    
    [PEPObjCAdapter stopKeyserverLookup];
    [self pEpCleanUp];
}

- (void)testLongKeyServerLookup
{
    [self pEpSetUp];
    [PEPObjCAdapter startKeyserverLookup];
    
    PEPIdentity *ident = [[PEPIdentity alloc] initWithAddress:@"vb@ulm.ccc.de"
                                                       userID:@"SsI6H9"
                                                     userName:@"pEpDontAssert"
                                                        isOwn:NO];
    
    [session updateIdentity:ident];
    
    sleep(2);

    // FIXME: updateIdentity should not assert if username is not provided
    [session updateIdentity:ident];
    
    XCTAssert(ident.fingerPrint);
    
    [PEPObjCAdapter stopKeyserverLookup];
    [self pEpCleanUp];
}

- (void)testSyncSession
{
    SomeSyncDelegate *syncDelegate = [[SomeSyncDelegate alloc] init];
    [self pEpSetUp];
    
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
    
    [self pEpCleanUp];
}

- (void)testTrustWords
{
    [self pEpSetUp];

    NSArray *trustwords = [session trustwords:@"DB47DB47DB47DB47DB47DB47DB47DB47DB47DB47" forLanguage:@"en" shortened:false];
    XCTAssertEqual([trustwords count], 10);
    
    for(id word in trustwords)
        XCTAssertEqualObjects(word, @"BAPTISMAL");

    [self pEpCleanUp];
}

- (void)testGenKey
{
    [self pEpSetUp];

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

    [self pEpCleanUp];
}

- (void)testMySelfCommType
{
    [self pEpSetUp];

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
        PEPInternalSession *session2 = [[PEPInternalSession alloc] init];

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
        PEPIdentity *identMe3 = [[PEPIdentity alloc]
                                 initWithAddress:identMe.address
                                 userName:identMe.userName
                                 isOwn:NO];
        [session2 mySelf:identMe3];
        XCTAssertNotNil(identMe3.fingerPrint);
        XCTAssertFalse([identMe3 containsPGPCommType]);
        XCTAssertEqualObjects(identMe3.fingerPrint, identMe.fingerPrint);

        XCTAssertEqualObjects(identMe.address, identMe2.address);
        XCTAssertEqualObjects(identMe.address, identMe3.address);
        XCTAssertEqual(identMe.commType, identMe2.commType);
        XCTAssertEqual(identMe.commType, identMe3.commType);
    });

    [self pEpCleanUp];
}

- (void)testOutgoingColors
{
    [self pEpSetUp];

    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [self importBundledKey:@"6FF00E97_sec.asc"];
    
    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:s_userID
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    [session mySelf:identAlice];
    
    NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       identAlice, kPepFrom,
                                       [NSMutableArray arrayWithObjects:
                                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 @"pEp Test Bob", kPepUsername,
                                                 @"pep.test.bob@pep-project.org", kPepAddress,
                                                 @"42", kPepUserID,
                                                 nil],
                                            nil], @"to",
                                        @"All Green Test", @"shortmsg",
                                        @"This is a text content", @"longmsg",
                                        @YES, @"outgoing",
                                       nil];

    // Test with unknown Bob
    PEP_rating clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_unencrypted);

    // Now let see with bob's pubkey already known
    // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
    // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
    [self importBundledKey:@"0xC9C2EE39.asc"];
    
    PEPIdentity *identBob = [[PEPIdentity alloc]
                             initWithAddress:@"pep.test.bob@pep-project.org"
                             userID:@"42" userName:@"pEp Test Bob"
                             isOwn:NO
                             fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"];
    
    [session updateIdentity:identBob];

    // Should be yellow, since no handshake happened.
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_reliable);

    clr = [session identityRating:identBob.dictionary];
    XCTAssert( clr == PEP_rating_reliable);
    
    // Let' say we got that handshake, set PEP_ct_confirmed in Bob's identity
    [session trustPersonalKey:identBob];

    // This time it should be green
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_trusted);

    clr = [session identityRating:identBob.dictionary];
    XCTAssert( clr == PEP_rating_trusted);

    // Let' say we undo handshake
    [session keyResetTrust:identBob];
    
    // Yellow ?
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_reliable);

    // mistrust Bob
    [session keyMistrusted:identBob];
    
    // Gray == PEP_rating_unencrypted
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_unencrypted);
    
    // Forget
    [session keyResetTrust:identBob];
    
    // Back to yellow
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_reliable);

    // Trust again
    [session trustPersonalKey:identBob];
    
    // Back to green
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_trusted);
    
    // Now let see if it turns back yellow if we add an unconfirmed folk.
    // pEp Test John (test key, don't use) <pep.test.john@pep-project.org>
    // AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575
    [self importBundledKey:@"0x70DCF575.asc"];
    
    PEPIdentity *identJohn = [[PEPIdentity alloc]
                              initWithAddress:@"pep.test.john@pep-project.org"
                              userID:@"101" userName:@"pEp Test John"
                              isOwn:NO
                              fingerPrint:@"AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575"];

    [session updateIdentity:identJohn];

    [msg setObject:[NSMutableArray arrayWithObjects:
     [NSMutableDictionary dictionaryWithObjectsAndKeys:
      @"pEp Test John", kPepUsername,
      @"pep.test.john@pep-project.org", kPepAddress,
      nil], nil] forKey:@"cc"];

    // Yellow ?
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_reliable);

    NSMutableDictionary *encmsg;
    PEP_STATUS status = [session encryptMessageDict:msg extra:@[] dest:&encmsg];
    
    XCTAssert(status == PEP_STATUS_OK);
    
    [self pEpCleanUp];
}


- (void)testOutgoingBccColors
{
    [self pEpSetUp];
    
    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [self importBundledKey:@"6FF00E97_sec.asc"];
    
    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:s_userID
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    [session mySelf:identAlice];
    
    NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                identAlice, kPepFrom,
                                [NSMutableArray arrayWithObjects:
                                 [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"pEp Test Bob", kPepUsername,
                                  @"pep.test.bob@pep-project.org", kPepAddress,
                                  @"42", kPepUserID,
                                  nil],
                                 nil], @"to",
                                @"All Green Test", @"shortmsg",
                                @"This is a text content", @"longmsg",
                                @YES, @"outgoing",
                                nil];
    
    // Test with unknown Bob
    PEP_rating clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_unencrypted);
    
    // Now let see with bob's pubkey already known
    // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
    // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
    [self importBundledKey:@"0xC9C2EE39.asc"];
    
    PEPIdentity *identBob = [[PEPIdentity alloc]
                             initWithAddress:@"pep.test.bob@pep-project.org"
                             userID:@"42" userName:@"pEp Test Bob"
                             isOwn:NO
                             fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"];

    [session updateIdentity:identBob];
    
    // Should be yellow, since no handshake happened.
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_reliable);
    
    clr = [session identityRating:identBob.mutableDictionary];
    XCTAssert( clr == PEP_rating_reliable);
    
    // Let' say we got that handshake, set PEP_ct_confirmed in Bob's identity
    [session trustPersonalKey:identBob];
    
    // This time it should be green
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_trusted);
    
    clr = [session identityRating:identBob.mutableDictionary];
    XCTAssert( clr == PEP_rating_trusted);

    // Now let see if it turns back yellow if we add an unconfirmed folk.
    // pEp Test John (test key, don't use) <pep.test.john@pep-project.org>
    // AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575
    [self importBundledKey:@"0x70DCF575.asc"];
    
    PEPIdentity *identJohn = [[PEPIdentity alloc]
                              initWithAddress:@"pep.test.john@pep-project.org"
                              userID:@"101" userName:@"pEp Test John"
                              isOwn:NO
                              fingerPrint:@"AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575"];

    [session updateIdentity:identJohn];
    
    [msg setObject:[NSMutableArray arrayWithObjects:
                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     @"pEp Test John", kPepUsername,
                     @"pep.test.john@pep-project.org", kPepAddress,
                     @"101", kPepUserID,
                     nil], nil] forKey:@"bcc"];
    
    // Yellow ?
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_reliable);
    
    [session trustPersonalKey:identJohn];
    
    // This time it should be green
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_trusted);
    
    clr = [session identityRating:identJohn.mutableDictionary];
    XCTAssert( clr == PEP_rating_trusted);

    /* 
     
    
    NSMutableDictionary *encmsg;
    PEP_STATUS status = [session encryptMessageDict:msg extra:@[] dest:&encmsg];
    
    XCTAssert(status == PEP_STATUS_OK);
    */
    
    [self pEpCleanUp];
}

- (void)testDontEncryptForMistrusted
{
    [self pEpSetUp];
    
    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [self importBundledKey:@"6FF00E97_sec.asc"];
    
    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:s_userID
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    [session mySelf:identAlice];
    
    // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
    // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
    [self importBundledKey:@"0xC9C2EE39.asc"];
    
    PEPIdentity *identBob = [[PEPIdentity alloc]
                             initWithAddress:@"pep.test.bob@pep-project.org"
                             userID:@"42" userName:@"pEp Test Bob"
                             isOwn:NO
                             fingerPrint:@"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39"];

    [session updateIdentity:identBob];

    // mistrust Bob
    [session keyMistrusted:identBob];
    
    NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                identAlice, kPepFrom,
                                [NSMutableArray arrayWithObjects:
                                 [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"pEp Test Bob", kPepUsername,
                                  @"pep.test.bob@pep-project.org", kPepAddress,
                                  @"42", kPepUserID,
                                  nil],
                                 nil], @"to",
                                @"All Green Test", @"shortmsg",
                                @"This is a text content", @"longmsg",
                                @YES, @"outgoing",
                                nil];
    

    // Gray == PEP_rating_unencrypted
    PEP_rating clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_unencrypted);

    NSMutableDictionary *encmsg;
    PEP_STATUS status = [session encryptMessageDict:msg extra:@[] dest:&encmsg];
    
    XCTAssert(status == PEP_UNENCRYPTED);

    XCTAssert(![(NSString *)(encmsg[@"attachments"][0][@"mimeType"]) isEqualToString: @"application/pgp-encrypted"]);

    [self pEpCleanUp];
}

- (void)testRenewExpired
{
    [self pEpSetUp];
    
    // Our expired test user :
    // pEp Test Hector (old test key don't use) <pep.test.hector@pep-project.org>
    [self importBundledKey:@"5CB2C182_sec.asc"];
    
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
                                   userID:s_userID userName:@"pEp Test Hector"
                                   isOwn:YES
                                   fingerPrint:@"EEA655839E347EC9E10A5DE2E80CB3FD5CB2C182"];

    // Myself automatically renew expired key.
    [session mySelf:identHectorOwn];
    XCTAssertEqual(PEP_ct_pEp, identHectorOwn.commType);
    
    [self pEpCleanUp:@"Bob"];
    
    
    [self pEpSetUp:@"Bob"];
    
    PEPIdentity *_identHector = [[PEPIdentity alloc]
                                 initWithAddress:@"pep.test.hector@pep-project.org"
                                 userID:@"khkhkh" userName:@"pEp Test Hector"
                                 isOwn:NO
                                 fingerPrint:@"EEA655839E347EC9E10A5DE2E80CB3FD5CB2C182"];

    [session updateIdentity:_identHector];
    XCTAssertEqual(PEP_ct_OpenPGP_unconfirmed, _identHector.commType);
    
    [self pEpCleanUp];
}

- (void)testRevoke
{
    [self pEpSetUp];
    
    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [self importBundledKey:@"6FF00E97_sec.asc"];
    NSString *fpr = @"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97";
    
    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:s_userID
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:fpr];

    [session mySelf:identAlice];

    PEPIdentity *identAlice2 = [identAlice mutableCopy];
    
    // This will revoke key
    [session keyMistrusted:identAlice2];
    
    // Check fingerprint is different
    XCTAssertNotEqualObjects(identAlice2.fingerPrint, fpr);

    [self pEpCleanUp];
}

- (void)testMailToMyself
{
    [self pEpSetUp];
    
    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [self importBundledKey:@"6FF00E97_sec.asc"];
    
    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:s_userID
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    [session mySelf:identAlice];
    
    NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                identAlice, kPepFrom,
                                [NSMutableArray arrayWithObjects: identAlice,
                                 nil], @"to",
                                @"Mail to Myself", @"shortmsg",
                                @"This is a text content", @"longmsg",
                                @YES, @"outgoing",
                                nil];
    
    // Test with unknown Bob
    PEP_rating clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_trusted_and_anonymized);
    
    NSMutableDictionary *encmsg;
    PEP_STATUS status = [session encryptMessageDict:msg extra:@[] dest:&encmsg];
    
    XCTAssert(status == PEP_STATUS_OK);
    
    NSArray* keys;
    NSMutableDictionary *decmsg;

    clr = [session decryptMessageDict:encmsg dest:&decmsg keys:&keys];
    XCTAssert( clr == PEP_rating_trusted_and_anonymized);
    
    [self pEpCleanUp];
}

#if 0
- (void)testMessMisTrust
{
NSMutableDictionary *encmsg;
{
    
    [self pEpSetUp];
    
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [self importBundledKey:@"6FF00E97_sec.asc"];
    
    NSMutableDictionary *identAlice = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"pEp Test Alice", kPepUsername,
                                       @"pep.test.alice@pep-project.org", kPepAddress,
                                       @"23", kPepUserID,
                                       @"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97",kPepFingerprint,
                                       nil];
    
    [session mySelf:identAlice];

    // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
    // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
    [self importBundledKey:@"0xC9C2EE39.asc"];
    
    NSMutableDictionary *identBob = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"pEp Test Bob", kPepUsername,
                                     @"pep.test.bob@pep-project.org", kPepAddress,
                                     @"42", kPepUserID,
                                     @"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39",kPepFingerprint,
                                     nil];
    
    [session updateIdentity:identBob];
    
    
    NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                identAlice, kPepFrom,
                                [NSMutableArray arrayWithObjects:
                                 identBob,
                                 nil], @"to",
                                @"All Green Test", @"shortmsg",
                                @"This is a text content", @"longmsg",
                                @YES, @"outgoing",
                                nil];
    
    PEP_STATUS status = [session encryptMessageDict:msg extra:@[] dest:&encmsg];
    XCTAssert(status == PEP_STATUS_OK);
    
    [self pEpCleanUp];
}

encmsg[@"outgoing"] = @NO;
[encmsg[kPepFrom] removeObjectForKey:kPepFingerprint];
[encmsg[kPepFrom] removeObjectForKey:kPepUserID];
[encmsg[@"to"][0] removeObjectForKey:kPepFingerprint];
[encmsg[@"to"][0] removeObjectForKey:kPepUserID];

{
    NSMutableDictionary *msg = [encmsg copy];

    [self pEpSetUp];
    
    
    // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
    // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
    [self importBundledKey:@"C9C2EE39_sec.asc"];
    
    NSMutableDictionary *identBob = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"pEp Test Bob", kPepUsername,
                                     @"pep.test.bob@pep-project.org", kPepAddress,
                                     @"42", kPepUserID,
                                     @"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39",kPepFingerprint,
                                     nil];
    
    [session mySelf:identBob];

    msg[kPepFrom][kPepUserID] = @"new_id_from_mail";
    
    NSMutableDictionary *decmsg;
    NSArray* keys;
    PEP_rating clr = [session decryptMessageDict:msg dest:&decmsg keys:&keys];
    XCTAssert(clr == PEP_rating_reliable);
    
    NSMutableDictionary *identAlice = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"pEp Test Alice", kPepUsername,
                                       @"pep.test.alice@pep-project.org", kPepAddress,
                                       @"new_id_from_mail", kPepUserID,
                                       nil];
    
    [session updateIdentity:identAlice];
    clr = [session identityRating:identAlice];
    XCTAssert( clr == PEP_rating_reliable);

    [session trustPersonalKey:identAlice];
    clr = [session identityRating:identAlice];
    XCTAssert( clr == PEP_rating_trusted);
    
    [session keyResetTrust:identAlice];
    clr = [session identityRating:identAlice];
    XCTAssert( clr == PEP_rating_reliable);
    
    [self pEpCleanUp:@"Bob"];
    
}{ // This is simulating a shutdown.
    NSMutableDictionary *msg = [encmsg copy];

    msg[kPepFrom][kPepUserID] = @"new_id_from_mail";

    [self pEpSetUp:@"Bob"];
    
    PEP_rating clr;
    {
        NSArray* keys;
        NSMutableDictionary *decmsg;
        clr = [session decryptMessageDict:msg dest:&decmsg keys:&keys];
    }
    XCTAssert(clr == PEP_rating_reliable);
    
    NSMutableDictionary *identAlice = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"pEp Test Alice", kPepUsername,
                                       @"pep.test.alice@pep-project.org", kPepAddress,
                                       @"new_id_from_mail", kPepUserID,
                                       nil];
    
    [session updateIdentity:identAlice];
    clr = [session identityRating:identAlice];
    XCTAssert( clr == PEP_rating_reliable);
    
    [session keyMistrusted:identAlice];
    clr = [session identityRating:identAlice];
    XCTAssert( clr == PEP_rating_mistrust);
    
    [session keyResetTrust:identAlice];
    clr = [session identityRating:identAlice];
    XCTAssert( clr == PEP_rating_reliable);
    
    [session trustPersonalKey:identAlice];
    clr = [session identityRating:identAlice];
    XCTAssert( clr == PEP_rating_trusted);
    
}{
    NSMutableDictionary *msg = [encmsg copy];
    PEP_rating clr;

    msg[kPepFrom][kPepUserID] = @"new_id_from_mail";
    {
        NSArray* keys;
        NSMutableDictionary *decmsg;
        clr = [session decryptMessageDict:msg dest:&decmsg keys:&keys];
    }
    XCTAssert(clr == PEP_rating_trusted);
    
    [self pEpCleanUp];
    
}}
#endif

- (void)testTwoNewUsers
{
    NSMutableDictionary* petrasMsg;
    PEPIdentity *identMiroAtPetra = [[PEPIdentity alloc]
                                     initWithAddress:@"pep.test.miro@pep-project.org"
                                     userID:@"not_me"
                                     userName:@"Miro"
                                     isOwn:NO];

    [self pEpSetUp];
    {
        PEPIdentity *identPetra = [[PEPIdentity alloc]
                                   initWithAddress:@"pep.test.petra@pep-project.org"
                                   userID:s_userID
                                   userName:@"Petra"
                                   isOwn:YES];

        [session mySelf:identPetra];
        XCTAssert(identPetra.fingerPrint);
        
        NSMutableDictionary *msg = @{ kPepFrom: identPetra,
                                      kPepTo: @[identMiroAtPetra],
                                      kPepShortMessage: @"Lets use pEp",
                                      kPepLongMessage: @"Dear, I just installed pEp, you should do the same !",
                                      kPepOutgoing: @YES }.mutableCopy;
        
        PEP_STATUS status = [session encryptMessageDict:msg extra:@[] dest:&petrasMsg];
        XCTAssert(status == PEP_UNENCRYPTED);
    }
    
    [self pEpCleanUp:@"Petra"];

    // Meanwhile, Petra's outgoing message goes through the Internet,
    // and becomes incomming message to Miro
    petrasMsg[kPepOutgoing] = @NO;

    NSMutableDictionary* mirosMsg;
    
    [self pEpSetUp];
    
    {
        PEPIdentity *identMiro = [[PEPIdentity alloc]
                                  initWithAddress:@"pep.test.miro@pep-project.org"
                                  userID:s_userID
                                  userName:@"Miro"
                                  isOwn:YES];

        [session mySelf:identMiro];
        XCTAssert(identMiro.fingerPrint);
    
        NSMutableDictionary *decmsg;
        NSArray* keys;
        PEP_rating clr = [session decryptMessageDict:petrasMsg dest:&decmsg keys:&keys];
        XCTAssert(clr == PEP_rating_unencrypted);

        NSMutableDictionary *msg = @{ kPepFrom: identMiro,
                                      kPepTo:
                                          @[ @{ kPepUsername: @"Petra",
                                                kPepAddress: @"pep.test.petra@pep-project.org" }],
                                      kPepShortMessage: @"re:Lets use pEp",
                                      kPepLongMessage: @"That was so easy !",
                                      kPepOutgoing: @YES }.mutableCopy;
        
        PEP_STATUS status = [session encryptMessageDict:msg extra:@[] dest:&mirosMsg];
        XCTAssert(status == PEP_STATUS_OK);
    }
    
    [self pEpCleanUp:@"Miro"];
    
    // Again, outgoing flips into incoming
    mirosMsg[kPepOutgoing] = @NO;
    
    [self pEpSetUp:@"Petra"];
    {
        NSMutableDictionary *decmsg;
        NSArray* keys;
        NSMutableDictionary *encmsg = mirosMsg.mutableCopy;
        [encmsg setObject:identMiroAtPetra.mutableCopy forKey:kPepFrom];

        PEP_rating clr = [session decryptMessageDict:encmsg dest:&decmsg keys:&keys];

        XCTAssertEqual(clr, PEP_rating_reliable);

        PEP_rating secondclr = [session reEvaluateMessageRating:decmsg];

        XCTAssertEqual(secondclr, PEP_rating_reliable);

        // Check Miro is in DB
        [session updateIdentity:identMiroAtPetra];
        
        XCTAssertNotNil(identMiroAtPetra.fingerPrint);
        
        // Trust to that identity
        [session trustPersonalKey:(NSMutableDictionary *) identMiroAtPetra];

        secondclr = [session reEvaluateMessageRating:decmsg];
        XCTAssertEqual(secondclr, PEP_rating_trusted_and_anonymized, @"Not trusted");
        
        clr = [session decryptMessageDict:encmsg dest:&decmsg keys:&keys];
        XCTAssertEqual(clr, PEP_rating_trusted_and_anonymized, @"Not trusted");

        // Undo trust
        [session keyResetTrust:(NSMutableDictionary *) identMiroAtPetra];
        
        clr = [session decryptMessageDict:encmsg dest:&decmsg keys:&keys];
        XCTAssertEqual(clr, PEP_rating_reliable, @"keyResetTrust didn't work?");
        
        // Try compromized
        [session keyMistrusted:(NSMutableDictionary *) identMiroAtPetra];

        clr = [session decryptMessageDict:encmsg dest:&decmsg keys:&keys];
        XCTAssertEqual(clr, PEP_rating_mistrust, @"Not mistrusted");
        
        // Regret
        [session keyResetTrust:(NSMutableDictionary *) identMiroAtPetra];
        
        clr = [session decryptMessageDict:encmsg dest:&decmsg keys:&keys];
        XCTAssertEqual(clr, PEP_rating_reliable, @"keyResetTrust didn't work?");
        
        // Trust again.
        [session trustPersonalKey:(NSMutableDictionary *) identMiroAtPetra];
        
        clr = [session decryptMessageDict:encmsg dest:&decmsg keys:&keys];
        XCTAssertEqual(clr, PEP_rating_trusted_and_anonymized, @"Not trusted");

        XCTAssertEqualObjects(decmsg[@"longmsg"], @"That was so easy !");
    }
    [self pEpCleanUp:@"Petra"];
}

#if 0
- (void)testEncryptedMailFromOutlook
{

    [self pEpSetUp];

    // This is the secret key for test001@peptest.ch
    [self importBundledKey:@"B623F674_sec.asc"];

    NSMutableDictionary *identMe = @{ kPepUsername: @"Test 001",
                                     kPepAddress: @"test001@peptest.ch",
                                     kPepUserID: @"B623F674" }.mutableCopy;
    NSMutableDictionary *identMeOutlook = @{ kPepUsername: @"Outlook 1",
                                             kPepAddress: @"outlook1@peptest.ch",
                                             kPepUserID: @"outlook1" }.mutableCopy;

    NSString *msgFilePath = [[[NSBundle bundleForClass:[self class]] resourcePath]
                             stringByAppendingPathComponent:@"msg_to_B623F674.asc"];
    NSString *msgFileContents = [NSString stringWithContentsOfFile:msgFilePath
                                                          encoding:NSASCIIStringEncoding error:NULL];

    NSMutableDictionary *msg = @{ kPepFrom: identMe,
                                  @"to": @[identMeOutlook],
                                  @"shortmsg": @"Some subject",
                                  @"longmsg": msgFileContents,
                                  @"incoming": @YES }.mutableCopy;

    // Should happen quite fast, since test001@peptest.ch already has a secret key
    [session mySelf:identMe];
    XCTAssert(identMe[kPepFingerprint]);

    [session updateIdentity:identMeOutlook];

    NSArray *keys;
    NSMutableDictionary *decMsg;
    PEP_rating clr = [session decryptMessage:msg dest:&decMsg keys:&keys];
    XCTAssertEqual(clr, PEP_rating_reliable);

    [self pEpCleanUp];
}
#endif

- (void)testEncryptedMailFromMutt
{
    [self pEpSetUp];

    // This is the public key for test001@peptest.ch
    [self importBundledKey:@"A3FC7F0A.asc"];

    // This is the secret key for test001@peptest.ch
    [self importBundledKey:@"A3FC7F0A_sec.asc"];

    // Mail from mutt, already processed into message dict by the app.
    NSMutableDictionary *msgDict = [self unarchiveDictionary:@"msg_to_A3FC7F0A_from_mutt.ser"].mutableCopy;
    [msgDict removeObjectForKey:kPepLongMessage];
    [msgDict removeObjectForKey:kPepLongMessageFormatted];

    // Also extracted "live" from the app.
    NSMutableDictionary *accountDict = [self unarchiveDictionary:@"account_A3FC7F0A.ser"].mutableCopy;
    [accountDict removeObjectForKey:kPepCommType];
    [accountDict removeObjectForKey:kPepFingerprint];
    PEPIdentity *identMe = [[PEPIdentity alloc] initWithDictionary:accountDict];

    [session mySelf:identMe];
    XCTAssertNotNil(identMe.fingerPrint);

    NSArray* keys;
    NSMutableDictionary *pepDecryptedMail;
    [session decryptMessageDict:msgDict dest:&pepDecryptedMail keys:&keys];
    XCTAssertNotNil(pepDecryptedMail[kPepLongMessage]);

    [self pEpCleanUp];
}

- (NSString *)loadStringByName:(NSString *)name
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:name withExtension:nil];
    return [NSString stringWithContentsOfURL:url usedEncoding:nil error:nil];
}

/**
 Checks reduced BCCs support when encrypting.
 Currently only one BCCs recipient is supported for encrypting.
 In that case no single TO oc CC are allowed.
 */
- (void)testEncryptBcc
{
    NSString *theMessage = @"THE MESSAGE";

    [self pEpSetUp];

    NSMutableDictionary *partner1Orig =
    @{ kPepAddress: @"partner1@dontcare.me",
       kPepUserID: @"partner1",
       kPepFingerprint: @"F0CD3F7B422E5D587ABD885BF2D281C2789DD7F6",
       kPepUsername: @"partner1" }.mutableCopy;

    NSMutableDictionary *meOrig =
    @{ kPepAddress: @"me@dontcare.me",
       kPepUserID: s_userID,
       kPepFingerprint: @"CC1F73F6FB774BF08B197691E3BFBCA9248FC681",
       kPepUsername: @"me" }.mutableCopy;

    NSString *pubKeyPartner1 = [self loadStringByName:@"partner1_F2D281C2789DD7F6_pub.asc"];
    XCTAssertNotNil(pubKeyPartner1);
    NSString *pubKeyMe = [self loadStringByName:@"meATdontcare_E3BFBCA9248FC681_pub.asc"];
    XCTAssertNotNil(pubKeyMe);
    NSString *secKeyMe = [self loadStringByName:@"meATdontcare_E3BFBCA9248FC681_sec.asc"];
    XCTAssertNotNil(secKeyMe);

    __block NSMutableDictionary *pepEncMail;
    {
        PEPIdentity *me = [[PEPIdentity alloc] initWithDictionary:meOrig];

        NSMutableDictionary *partner1 = partner1Orig.mutableCopy;

        NSMutableDictionary *mail = @{ kPepFrom: me,
                                       kPepOutgoing: @YES,
                                       kPepLongMessage: theMessage,
                                       kPepBCC: @[partner1] }.mutableCopy;

        [session importKey:pubKeyMe];
        [session importKey:secKeyMe];
        [session mySelf:me];
        XCTAssertNotNil(me.fingerPrint);
        XCTAssertEqualObjects(me.fingerPrint, meOrig[kPepFingerprint]);
        [session importKey:pubKeyPartner1];
        PEP_STATUS status = [session encryptMessageDict:mail extra:nil dest:&pepEncMail];
        XCTAssertEqual(status, PEP_STATUS_OK);
    }

    [self pEpCleanUp];

    [self pEpSetUp];
    {
        PEPIdentity *partner1 = [[PEPIdentity alloc] initWithDictionary:partner1Orig];

        NSString *privateKeyPartner1 = [self
                                        loadStringByName:@"partner1_F2D281C2789DD7F6_sec.asc"];
        [session importKey:privateKeyPartner1];
        XCTAssertNotNil(privateKeyPartner1);

        [session importKey:pubKeyPartner1];
        [session importKey:pubKeyMe];

        [session mySelf:partner1];
        XCTAssertNotNil(partner1.fingerPrint);
        XCTAssertEqualObjects(partner1.fingerPrint, partner1Orig[kPepFingerprint]);

        PEPIdentity *me = [[PEPIdentity alloc] initWithDictionary:meOrig];
        [session updateIdentity:me];

        NSMutableDictionary *pepDecryptedMail;
        NSArray *keys = [NSArray array];
        [session decryptMessageDict:pepEncMail dest:&pepDecryptedMail keys:&keys];

        // If this assert holds, then the engine ignores BCCs when encrypting
        XCTAssertEqualObjects(pepDecryptedMail[kPepLongMessage], theMessage);
    }

    [self pEpCleanUp];
}

- (void)doSomeWorkOnSession:(PEPInternalSession *)session count:(NSInteger)count
{
    PEPIdentity *me = [[PEPIdentity alloc]
                       initWithAddress:[NSString
                                        stringWithFormat:@"me%ld@dontcare.me", (long)count]
                       userID:[NSString stringWithFormat:@"me%ld", (long)count]
                       userName:[NSString stringWithFormat:@"me%ld", (long)count]
                       isOwn:YES];
    [session mySelf:me];
    XCTAssertNotNil(me.fingerPrint);
}

- (void)testParallelSessions
{
    //[PEPObjCAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];

    // Currently, the first session use MUST be on the main thread
    [self pEpSetUp];
    [self doSomeWorkOnSession:session count:0];

    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);

    for (int i = 1; i < 3; ++i) {
        dispatch_group_async(group, queue, ^{
            PEPInternalSession *innerSession = [[PEPInternalSession alloc] init];
            [self doSomeWorkOnSession:innerSession count:i];
            innerSession = nil;
        });
    }

    long result = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    XCTAssertEqual(result, 0);

    [self pEpCleanUp];
}

#if 0 // This test assert fails
- (void)testParallelDecryptionTest
{
    // Have one session open at all times, from main thread
    [self pEpSetUp];

    // Mail from outlook1@peptest.ch to test001@peptest.ch, extracted from the app
    NSDictionary *msgDict = [self unarchiveDictionary:@"msg_to_78EE1DBC_from_outlook.ser"];

    // Also extracted "live" from the app.
    NSDictionary *accountDict = [self unarchiveDictionary:@"account_78EE1DBC.ser"];

    PEPSession *someSession = [[PEPSession alloc] init];

    // This is the public key for test001@peptest.ch
    [self importBundledKey:@"78EE1DBC.asc" intoSession:someSession];

    // This is the secret key for test001@peptest.ch
    [self importBundledKey:@"78EE1DBC_sec.asc" intoSession:someSession];

    someSession = nil;

    dispatch_queue_t queue = dispatch_queue_create("Concurrent test queue",
                                                   DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();

    void (^decryptionBlock)(int) = ^(int index) {
        PEPSession *innerSession = [[PEPSession alloc] init];

        NSMutableDictionary *innerAccountDict = [accountDict mutableCopy];
        [innerSession mySelf:innerAccountDict];
        XCTAssertNotNil(innerAccountDict[kPepFingerprint]);

        NSArray* keys;
        NSMutableDictionary *pepDecryptedMail;
        PEP_rating color = [innerSession decryptMessageDict:msgDict dest:&pepDecryptedMail
                                                      keys:&keys];
        XCTAssertEqual(color, PEP_rating_reliable);
        NSLog(@"%d: decryption color -> %d", index, color);

    };

    // Test single decryption on main thread
    decryptionBlock(0);

    for (int i = 1; i < 21; ++i) {
        dispatch_group_async(group, queue, ^{
            decryptionBlock(i);
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    [self pEpCleanUp];
}
#endif

/**
 Simulate accessing a sent folder with about 20 messages in it, and trying to decrypt them
 all at once.
 */
#if 0 // This test assert fails
- (void)testLoadMassiveSentFolder
{
    // Have one session open at all times, from main thread
    [self pEpSetUp];

    NSDictionary *meOrig = @{ kPepAddress: @"test000@dontcare.me",
                              kPepUserID: @"test000",
                              kPepUsername: @"Test 000" };

    NSDictionary *partner = @{ kPepAddress: @"test001@peptest.ch",
                               kPepUserID: @"test001",
                               kPepFingerprint: @"FEBFEAC4AB3E870C447C8427BD7B7A3478EE1DBC",
                               kPepUsername: @"Test 001" };

    dispatch_queue_t queue = dispatch_queue_create("Concurrent test queue",
                                                   DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();

    // Set up keys in a background thread
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        PEPSession *someSession = [[PEPSession alloc] init];
        NSMutableDictionary *mySelf = meOrig.mutableCopy;
        [someSession mySelf:mySelf];
        XCTAssertNotNil(mySelf[kPepFingerprint]);

        // This is the public key for test001@peptest.ch (partner)
        [self importBundledKey:@"78EE1DBC.asc" intoSession:someSession];
        dispatch_group_leave(group);
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    // Write a couple of mails to 78EE1DBC
    NSMutableArray *sentMails = @[].mutableCopy;
    dispatch_goup_async(group, queue, ^{
        PEPSession *someSession = [[PEPSession alloc] init];
        NSMutableDictionary *mySelf = meOrig.mutableCopy;
        [someSession mySelf:mySelf];
        XCTAssertNotNil(mySelf[kPepFingerprint]);

        for (int i = 0; i < 20; i++) {
            NSDictionary *mail = @{ kPepFrom: mySelf,
                                    kPepTo: @[partner],
                                    kPepShortMessage: [NSString
                                                       stringWithFormat:@"Message %d",
                                                       i + 1],
                                    kPepLongMessage: [NSString
                                                      stringWithFormat:@"Message Content %d",
                                                       i + 1],
                                    kPepOutgoing: @YES};

            NSDictionary *encryptedMail;
            PEP_STATUS status = [someSession encryptMessageDict:mail extra:@[] dest:&encryptedMail];
            XCTAssertEqual(status, PEP_STATUS_OK);

            [sentMails addObject:encryptedMail];
        }

    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    // massively decrypt
    for (NSDictionary *sentMail in sentMails) {
        dispatch_group_async(group, queue, ^{
            PEPSession *someSession = [[PEPSession alloc] init];
            NSDictionary *decryptedMail;
            NSArray *keys;
            PEP_rating color = [someSession decryptMessageDict:sentMail dest:&decryptedMail
                                                         keys:&keys];
            NSLog(@"Decrypted %@: %d", decryptedMail[kPepShortMessage], color);
            XCTAssertGreaterThanOrEqual(color, PEP_rating_reliable);
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    [self pEpCleanUp];
}
#endif

- (void)testOutgoingContactColor
{
    [self pEpSetUp];

    NSMutableDictionary *partner1Orig =
    @{kPepAddress: @"partner1@dontcare.me",
      kPepUsername: @"Partner 1"}.mutableCopy;

    NSString *pubKeyPartner1 = [self loadStringByName:@"partner1_F2D281C2789DD7F6_pub.asc"];
    XCTAssertNotNil(pubKeyPartner1);
    [session importKey:pubKeyPartner1];

    PEP_rating color = [session identityRating:partner1Orig];
    XCTAssertEqual(color, PEP_rating_reliable);

    [self pEpCleanUp];

}

- (PEPDict *)internalEncryptToMySelfKeys:(PEPStringList **)keys
{
    PEPIdentity *me = [[PEPIdentity alloc]
                       initWithAddress:@"me@peptest.ch" userName:@"userName"
                       isOwn:YES];
    [session mySelf:me];
    XCTAssertNotNil(me.fingerPrint);

    // Create draft
    NSString *shortMessage = @"Subject";
    NSString *longMessage = @"Oh, this is a long body text!";
    PEPDict *mail = mailFromTo((PEPDict *) me, (PEPDict *) me, shortMessage, longMessage,
                               YES);

    NSMutableDictionary *encDict;
    PEP_STATUS status = [session encryptMessageDict:mail identity:(PEPDict *) me dest:&encDict];
    XCTAssertEqual(status, 0);
    XCTAssertEqualObjects(encDict[kPepShortMessage], @"p≡p");

    NSMutableDictionary *unencDict;
    PEP_rating rating = [session decryptMessageDict:encDict dest:&unencDict keys:keys];
    XCTAssertGreaterThanOrEqual(rating, PEP_rating_reliable);

    XCTAssertEqualObjects(unencDict[kPepShortMessage], shortMessage);
    XCTAssertEqualObjects(unencDict[kPepLongMessage], longMessage);

    return unencDict;
}

- (void)testEncryptToMySelf
{
    [self pEpSetUp];
    [self internalEncryptToMySelfKeys:nil];
    [self pEpCleanUp];
}

- (void)testMessageTrustwordsWithMySelf
{
    [self pEpSetUp];

    PEPStringList *keys = nil;
    PEPDict *decryptedDict = [self internalEncryptToMySelfKeys:&keys];
    XCTAssertNotNil(keys);
    XCTAssert(keys.count > 0);

    PEPIdentity *receiver = decryptedDict[kPepTo][0];
    [session updateIdentity:receiver];
    XCTAssertNotNil(receiver);
    PEP_STATUS trustwordsStatus;

    NSString *trustwords = [session getTrustwordsMessageDict:decryptedDict
                                                receiverDict:receiver.mutableDictionary
                                                   keysArray:keys language:@"en"
                                                        full:YES
                                             resultingStatus: &trustwordsStatus];

    // No trustwords with yourself
    XCTAssertEqual(trustwordsStatus, PEP_TRUSTWORDS_DUPLICATE_FPR);
    XCTAssertNil(trustwords);

    [self pEpCleanUp];
}

- (void)testGetTrustwords
{
    [self pEpSetUp];

    NSDictionary *partner1Orig =
    @{ kPepAddress: @"partner1@dontcare.me",
       kPepUserID: @"partner1",
       kPepFingerprint: @"F0CD3F7B422E5D587ABD885BF2D281C2789DD7F6",
       kPepUsername: @"partner1" };

    NSDictionary *meOrig =
    @{ kPepAddress: @"me@dontcare.me",
       kPepUserID: @"me",
       kPepFingerprint: @"CC1F73F6FB774BF08B197691E3BFBCA9248FC681",
       kPepUsername: @"me" };

    NSString *pubKeyPartner1 = [self loadStringByName:@"partner1_F2D281C2789DD7F6_pub.asc"];
    XCTAssertNotNil(pubKeyPartner1);
    NSString *pubKeyMe = [self loadStringByName:@"meATdontcare_E3BFBCA9248FC681_pub.asc"];
    XCTAssertNotNil(pubKeyMe);
    NSString *secKeyMe = [self loadStringByName:@"meATdontcare_E3BFBCA9248FC681_sec.asc"];
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

    [self pEpCleanUp];
}
// Temporary tests that made to reproduce concurrency issues, i.e. to fail
// TODO: delete this tests after a final solution/approach is found for our concurrency isues
// TODO: re-write those tests using the found solution

//#pragma mark - Concurrent Calls
//
//// Tests trying to reproduce IOSAD-35 (IOSAD-23)
//// Assumption: multiple sessions in one thread are OK
///*
// This tests crashes often (but not always) here.
// Assertion failed: (status == PEP_STATUS_OK), function _myself, file /Users/buff/workspace/pEp/src/pEpEngine/src/keymanagement.c, line 619.
// If you can not reproduce it, comment the marked line, run, run agin, uncomment the marked line, run.
// */
//- (void)testParallelDecryptionOneThreadMultipleSessions
//{
//    // Have one session open at all times, from main thread
//    [self pEpSetUp];
//    // An unecrypted Mail
//    NSMutableDictionary *msgDict = [[self unarchiveDictionary:@"msg_to_A3FC7F0A_from_mutt.ser"] mutableCopy];
//    [msgDict removeObjectForKey:@"attachments"]; // toggle comment/uncomment this line in between runs helps to reproduce the issue
//    msgDict[kPepAddress] = @"some.unkown@user.com";
//    msgDict[kPepUsername] = @"some unkown user";
//    // me
//    NSDictionary *accountDict = [self unarchiveDictionary:@"account_A3FC7F0A.ser"];
//
//    PEPInternalSession *someSession = [[PEPInternalSession alloc] initInternal];
//    //Some key
//    [self importBundledKey:@"5CB2C182.asc" intoSession:someSession];
//    // This is the secret key for test001@peptest.ch
//    [self importBundledKey:@"5CB2C182_sec.asc" intoSession:someSession];
//    someSession = nil;
//
//    dispatch_queue_t queue = dispatch_queue_create("Concurrent test queue",
//                                                   DISPATCH_QUEUE_CONCURRENT);
//    dispatch_group_t group = dispatch_group_create();
//    void (^decryptionBlock)(int) = ^(int index) {
//        PEPInternalSession *innerSession = [[PEPInternalSession alloc] initInternal];
//        NSMutableDictionary *innerAccountDict = [accountDict mutableCopy];
//        [innerSession mySelf:innerAccountDict]; //Random Assertion failed: (status == PEP_STATUS_OK), function _myself, file /Users/buff/workspace/pEp/src/pEpEngine/src/keymanagement.c, line 619.
//        XCTAssertNotNil(innerAccountDict[kPepFingerprint]);
//        NSArray* keys;
//        NSMutableDictionary *pepDecryptedMail;
//        [innerSession decryptMessageDict:msgDict dest:&pepDecryptedMail
//                                                       keys:&keys];
//        innerSession = nil;
//    };
//
//    decryptionBlock(0);
//
//    for (int i = 1; i < 15; ++i) {
//        dispatch_group_async(group, queue, ^{
//            decryptionBlock(i);
//        });
//    }
//
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//
//    [self pEpCleanUp];
//}
//
//- (void)testParallelDecryptionOneThreadOneSessionCopiedToBlock
//{
//    // Have one session open at all times, from main thread
//    [self pEpSetUp];
//
//    // An unecrypted Mail
//    NSMutableDictionary *msgDict = [[self unarchiveDictionary:@"msg_to_A3FC7F0A_from_mutt.ser"] mutableCopy];
//    msgDict[kPepAddress] = @"some.unkown@user.com";
//    msgDict[kPepUsername] = @"some unkown user";
//    // me
//    NSDictionary *accountDict = [self unarchiveDictionary:@"account_A3FC7F0A.ser"];
//
//    PEPInternalSession *someSession = [[PEPInternalSession alloc] initInternal];
//    //Some key
//    [self importBundledKey:@"5CB2C182.asc" intoSession:someSession];
//    // This is the secret key for test001@peptest.ch
//    [self importBundledKey:@"5CB2C182_sec.asc" intoSession:someSession];
//    someSession = nil;
//
//    dispatch_queue_t queue = dispatch_queue_create("Concurrent test queue",
//                                                   DISPATCH_QUEUE_CONCURRENT);
//    dispatch_group_t group = dispatch_group_create();
//    PEPInternalSession *oneSessionCopiedToBlock = [[PEPInternalSession alloc] initInternal];
//    void (^decryptionBlock)(int) = ^(int index) {
//        NSMutableDictionary *innerAccountDict = [accountDict mutableCopy];
//        [oneSessionCopiedToBlock mySelf:innerAccountDict];        XCTAssertNotNil(innerAccountDict[kPepFingerprint]);
//        NSArray* keys;
//        NSMutableDictionary *pepDecryptedMail;
//        [oneSessionCopiedToBlock decryptMessageDict:msgDict dest:&pepDecryptedMail
//                                                                  keys:&keys];
//    };
//    decryptionBlock(0);
//    for (int i = 1; i < 84; ++i) {
//        dispatch_group_async(group, queue, ^{
//            decryptionBlock(i);
//        });
//    }
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//
//    [self pEpCleanUp];
//}
//
//- (void)testParallelDecryptionOneThreadOneSessionBlockReference
//{
//    // Have one session open at all times, from main thread
//    [self pEpSetUp];
//
//    // An unecrypted Mail
//    NSMutableDictionary *msgDict = [[self unarchiveDictionary:@"msg_to_A3FC7F0A_from_mutt.ser"] mutableCopy];
//    msgDict[kPepAddress] = @"some.unkown@user.com";
//    msgDict[kPepUsername] = @"some unkown user";
//    // me
//    NSDictionary *accountDict = [self unarchiveDictionary:@"account_A3FC7F0A.ser"];
//
//    PEPInternalSession *someSession = [[PEPInternalSession alloc] initInternal];
//    //Some key
//    [self importBundledKey:@"5CB2C182.asc" intoSession:someSession];
//    // This is the secret key for test001@peptest.ch
//    [self importBundledKey:@"5CB2C182_sec.asc" intoSession:someSession];
//    someSession = nil;
//
//    dispatch_queue_t queue = dispatch_queue_create("Concurrent test queue",
//                                                   DISPATCH_QUEUE_CONCURRENT);
//    dispatch_group_t group = dispatch_group_create();
//    __block PEPInternalSession *oneSessionCopiedToBlock = [[PEPInternalSession alloc] initInternal];
//    void (^decryptionBlock)(int) = ^(int index) {
//        NSMutableDictionary *innerAccountDict = [accountDict mutableCopy];
//        [oneSessionCopiedToBlock mySelf:innerAccountDict];        XCTAssertNotNil(innerAccountDict[kPepFingerprint]);
//
//        NSArray* keys;
//        NSMutableDictionary *pepDecryptedMail;
//        [oneSessionCopiedToBlock decryptMessageDict:msgDict dest:&pepDecryptedMail
//                                                                  keys:&keys];
//    };
//
//    decryptionBlock(0);
//    for (int i = 1; i < 84; ++i) {
//        dispatch_group_async(group, queue, ^{
//            decryptionBlock(i);
//        });
//    }
//
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//
//    [self pEpCleanUp];
//}
//
//// IOSAD-34
//- (void)testParallelDecryptionPlusParallelInitOneThreadMultipleSessions
//{
//    // Have one session open at all times, from main thread
//    [self pEpSetUp];
//    // An unecrypted Mail
//    NSMutableDictionary *msgDict = [[self unarchiveDictionary:@"msg_to_A3FC7F0A_from_mutt.ser"] mutableCopy];
//    msgDict[kPepAddress] = @"some.unkown@user.com";
//    msgDict[kPepUsername] = @"some unkown user";
//    // me
//    NSDictionary *accountDict = [self unarchiveDictionary:@"account_A3FC7F0A.ser"];
//    PEPInternalSession *someSession = [[PEPInternalSession alloc] initInternal];
//    //Some key
//    [self importBundledKey:@"5CB2C182.asc" intoSession:someSession];
//    // This is the secret key for test001@peptest.ch
//    [self importBundledKey:@"5CB2C182_sec.asc" intoSession:someSession];
//    someSession = nil;
//
//    dispatch_queue_t queue = dispatch_queue_create("Concurrent test queue",
//                                                   DISPATCH_QUEUE_CONCURRENT);
//    __block dispatch_group_t group = dispatch_group_create();
//    PEPInternalSession *decryptSession = [[PEPInternalSession alloc] initInternal];
//    void (^decryptionBlock)(int) = ^(int index) {
//        NSMutableDictionary *innerAccountDict = [accountDict mutableCopy];
//        [decryptSession mySelf:innerAccountDict];         XCTAssertNotNil(innerAccountDict[kPepFingerprint]);
//        NSArray* keys;
//        NSMutableDictionary *pepDecryptedMail;
//        [decryptSession decryptMessageDict:msgDict dest:&pepDecryptedMail
//                                                         keys:&keys];
//    };
//
//    PEPInternalSession *decryptSession2 = [[PEPInternalSession alloc] initInternal];
//    void (^decryptionBlock2)(int) = ^(int index) {
//        NSMutableDictionary *innerAccountDict = [accountDict mutableCopy];
//        [decryptSession2 mySelf:innerAccountDict];         XCTAssertNotNil(innerAccountDict[kPepFingerprint]);
//        NSArray* keys;
//        NSMutableDictionary *pepDecryptedMail;
//        [decryptSession2 decryptMessageDict:msgDict dest:&pepDecryptedMail
//                                                          keys:&keys];
//    };
//
//    void (^initBlock)(void) = ^() {
//        for (int i = 0; i < 100; ++i) {
//            PEPInternalSession *tmp = [[PEPInternalSession alloc] initInternal];
//            tmp = nil;
//        }
//    };
//
//    for (int i = 1; i < 15; ++i) {
//        dispatch_group_async(group, queue, ^{
//            decryptionBlock(i);
//        });
//        dispatch_group_async(group, queue, ^{
//            decryptionBlock2(i);
//        });
//        dispatch_group_async(group, queue, ^{
//            initBlock();
//        });
//        dispatch_group_async(group, queue, ^{
//            initBlock();
//        });
//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//    }
//
//    XCTAssertTrue(YES, @"We are done and did not crash.");
//    [self pEpCleanUp];
//}

@end
