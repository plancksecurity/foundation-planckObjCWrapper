//
//  iOSTests.m
//  iOSTests
//
//  Created by Edouard Tisserant on 03/11/15.
//  Copyright © 2015 p≡p. All rights reserved.
//

#include <regex.h>
#import <XCTest/XCTest.h>
#import "pEpiOSAdapter/PEPiOSAdapter.h"
#import "pEpiOSAdapter/PEPSession.h"

@interface iOSTests : XCTestCase

@end

@implementation iOSTests

PEPSession *session;

#pragma mark -- Helpers

-(void)delFile : (NSString *)path : (NSString *)bkpsfx {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:path];
    if (fileExists)
    {
        BOOL success;
        if(!bkpsfx)
        {
            success = [fileManager removeItemAtPath:path error:&error];
        }else{
            NSString *toPath = [path stringByAppendingString:bkpsfx];
            
            if([fileManager fileExistsAtPath:toPath])
                [fileManager removeItemAtPath:toPath error:&error];
            
            success = [fileManager moveItemAtPath:path
                                   toPath:toPath
                                   error:&error];
        }
        if (!success) NSLog(@"Error: %@", [error localizedDescription]);
    }
}

-(void)undelFile : (NSString *)path : (NSString *)bkpsfx {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString* bpath = [path stringByAppendingString:bkpsfx];
    BOOL fileExists = [fileManager fileExistsAtPath:bpath];
    if (fileExists)
    {
        BOOL success;
        success = [fileManager moveItemAtPath:bpath
                                       toPath:path
                                        error:&error];
        if (!success) NSLog(@"Error: %@", [error localizedDescription]);
    }
}

- (NSArray*)pEpWorkFiles
{
    // Only files whose content is affected by tests.
    NSString* home = [[[NSProcessInfo processInfo]environment]objectForKey:@"HOME"];
    NSString* gpgHome = [home stringByAppendingPathComponent:@".gnupg"];
    return @[[home stringByAppendingPathComponent:@".pEp_management.db"],
             [gpgHome stringByAppendingPathComponent:@"pubring.gpg"],
             [gpgHome stringByAppendingPathComponent:@"secring.gpg"]];
    
}

- (void)pEpCleanUp : (NSString*)backup {
    session=nil;
    
    for(id path in [self pEpWorkFiles])
        [self delFile:path :backup];

}
- (void)pEpCleanUp
{
    [self pEpCleanUp:NULL];
}

- (void)pEpSetUp : (NSString*)restore{
    // Must be the first thing you do before using anything pEp-related
    [PEPiOSAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];

    for(id path in [self pEpWorkFiles])
        [self delFile:path:NULL];

    if(restore)
        for(id path in [self pEpWorkFiles])
            [self undelFile:path:restore];

    session = [[PEPSession alloc]init];
    XCTAssert(session);
    
}
- (void)pEpSetUp
{
    [self pEpSetUp:NULL];
}

- (void)importBundledKey : (NSString*)item {

    NSString *txtFilePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:item];
    NSString *txtFileContents = [NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:NULL];
    //[keysStrings setObject:txtFileContents forKey:txtFilePath];
    [session importKey:txtFileContents];
}

- (NSDictionary *)unarchiveDictionary:(NSString *)fileName
{
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:fileName];
    NSMutableData *data = [NSMutableData dataWithContentsOfFile:filePath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict = [unarchiver decodeObject];
    [unarchiver finishDecoding];
    return dict;
}

#pragma mark -- Tests

- (void)testEmptySession {
    
    [self pEpSetUp];

    // Do nothing.

    
    [self pEpCleanUp];
    
}


- (void)testOverlapingSessions {
    
    PEPSession *session2;
    [self pEpSetUp];
    
    session2 = session;
    
    session = [[PEPSession alloc]init];
    XCTAssert(session);

    sleep(1);

    session2 = nil;
    
    [self pEpCleanUp];

}

- (void)testNestedSessions {
    
    PEPSession *session2;
    [self pEpSetUp];
    
    session2 = [[PEPSession alloc]init];
    XCTAssert(session2);

    sleep(1);
   
    session2 = nil;
    
    [self pEpCleanUp];
    
}

- (void)testShortKeyServerLookup {
    
    [self pEpSetUp];
    [PEPiOSAdapter startKeyserverLookup];
    
    // Do nothing.
    
    [PEPiOSAdapter stopKeyserverLookup];
    [self pEpCleanUp];
    
}

- (void)testLongKeyServerLookup {
    
    [self pEpSetUp];
    [PEPiOSAdapter startKeyserverLookup];
    
    NSMutableDictionary *ident = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"pEpDontAssert", @"username",
                                    @"vb@ulm.ccc.de", @"address",
                                    @"SsI6H9", @"user_id",
                                    nil];
    
    [session updateIdentity:ident];
    
    sleep(2);

    // FIXME: updateIdentity should not assert if username is not provided
    [session updateIdentity:ident];
    
    XCTAssert(ident[@"fpr"]);
    
    [PEPiOSAdapter stopKeyserverLookup];
    [self pEpCleanUp];
    
}

- (void)testTrustWords {
    [self pEpSetUp];

    NSArray *trustwords = [session trustwords:@"DB47DB47DB47DB47DB47DB47DB47DB47DB47DB47" forLanguage:@"en" shortened:false];
    XCTAssertEqual([trustwords count], 10);
    
    for(id word in trustwords)
        XCTAssertEqualObjects(word, @"BAPTISMAL");

    [self pEpCleanUp];
    
}

- (void)testGenKey {
    
    [self pEpSetUp];
    
    NSMutableDictionary *identMe = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"pEp Test iOS GenKey", @"username",
                                       @"pep.test.iosgenkey@pep-project.org", @"address",
                                       @"Me", @"user_id",
                                       nil];
    
    [session mySelf:identMe];
    
    XCTAssert(identMe[@"fpr"]);

    [self pEpCleanUp];
    
}

- (void)testOutgoingColors {

    [self pEpSetUp];

    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    [self importBundledKey:@"6FF00E97_sec.asc"];
    
    NSMutableDictionary *identAlice = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"pEp Test Alice", @"username",
                                  @"pep.test.alice@pep-project.org", @"address",
                                  @"23", @"user_id",
                                  @"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97",@"fpr",
                                  nil];
 
    [session mySelf:identAlice];
    
    NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       identAlice, @"from",
                                       [NSMutableArray arrayWithObjects:
                                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 @"pEp Test Bob", @"username",
                                                 @"pep.test.bob@pep-project.org", @"address",
                                                 nil],
                                            nil], @"to",
                                        @"All Green Test", @"shortmsg",
                                        @"This is a text content", @"longmsg",
                                        @YES, @"outgoing",
                                       nil];

    // Test with unknown Bob
    PEP_color clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_unencrypted);

    // Now let see with bob's pubkey already known
    // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
    // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
    [self importBundledKey:@"0xC9C2EE39.asc"];
    
    NSMutableDictionary *identBob = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"pEp Test Bob", @"username",
                                     @"pep.test.bob@pep-project.org", @"address",
                                     @"42", @"user_id",
                                     @"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39",@"fpr",
                                     nil];
    
    [session updateIdentity:identBob];

    // Should be yellow, since no handshake happened.
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_yellow);

    clr = [session identityColor:identBob];
    XCTAssert( clr == PEP_rating_yellow);
    
    // Let' say we got that handshake, set PEP_ct_confirmed in Bob's identity
    [session trustPersonalKey:identBob];

    // This time it should be green
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_green);

    clr = [session identityColor:identBob];
    XCTAssert( clr == PEP_rating_green);

    // Let' say we undo handshake
    [session keyResetTrust:identBob];
    
    // Yellow ?
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_yellow);

    // mistrust Bob
    [session keyCompromized:identBob];
    
    // Gray == PEP_rating_unencrypted
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_unencrypted);
    
    /*
    identBob = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                @"pEp Test Bob", @"username",
                @"pep.test.bob@pep-project.org", @"address",
                @"42", @"user_id",
                @"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39",@"fpr",
                nil];
*/
    // Forget
    [session keyResetTrust:identBob];
    
    // Back to yellow
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_yellow);

    // Trust again
    [session trustPersonalKey:identBob];
    
    // Back to green
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_green);
    
    // Now let see if it turns back yellow if we add an unconfirmed folk.
    // pEp Test John (test key, don't use) <pep.test.john@pep-project.org>
    // AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575
    [self importBundledKey:@"0x70DCF575.asc"];
    
    NSMutableDictionary *identJohn = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"pEp Test John", @"username",
                                      @"pep.test.john@pep-project.org", @"address",
                                      @"101", @"user_id",
                                      @"AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575",@"fpr",
                                      nil];
    
    [session updateIdentity:identJohn];

    [msg setObject:[NSMutableArray arrayWithObjects:
     [NSMutableDictionary dictionaryWithObjectsAndKeys:
      @"pEp Test John", @"username",
      @"pep.test.john@pep-project.org", @"address",
      nil], nil] forKey:@"cc"];

    // Yellow ?
    clr = [session outgoingMessageColor:msg];
    XCTAssert( clr == PEP_rating_yellow);

    NSMutableDictionary *encmsg;
    PEP_STATUS status = [session encryptMessage:msg extra:@[] dest:&encmsg];
    
    XCTAssert(status == PEP_STATUS_OK);
    
    [self pEpCleanUp];
}

- (void)testTwoNewUsers {

    NSMutableDictionary* petrasMsg;
    NSMutableDictionary *identMiroAtPetra =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"Miro", @"username",
     @"pep.test.miro@pep-project.org", @"address",
     @"Him", @"user_id",
     nil];

    
    [self pEpSetUp];

    {
        NSMutableDictionary *identPetra = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"Petra", @"username",
                                        @"pep.test.petra@pep-project.org", @"address",
                                        @"Me", @"user_id",
                                        nil];
        
        [session mySelf:identPetra];
        XCTAssert(identPetra[@"fpr"]);
        
        NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    identPetra, @"from",
                                    [NSMutableArray arrayWithObjects: identMiroAtPetra,
                                     nil], @"to",
                                    @"Lets use pEp", @"shortmsg",
                                    @"Dear, I just installed pEp, you should do the same !", @"longmsg",
                                    @YES, @"outgoing",
                                    nil];
        
        PEP_STATUS status = [session encryptMessage:msg extra:@[] dest:&petrasMsg];
        XCTAssert(status == PEP_UNENCRYPTED);

    }
    
    [self pEpCleanUp:@"Petra"];

    // Meanwhile, Petra's outgoing message goes through the Internet,
    // and becomes incomming message to Miro
    petrasMsg[@"outgoing"] = @NO;

    NSMutableDictionary* mirosMsg;
    
    [self pEpSetUp];
    
    {
        NSMutableDictionary *identMiro = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Miro", @"username",
                                       @"pep.test.miro@pep-project.org", @"address",
                                       @"Me", @"user_id",
                                       nil];
    
        [session mySelf:identMiro];
        XCTAssert(identMiro[@"fpr"]);
    
        NSMutableDictionary *decmsg;
        NSArray* keys;
        PEP_color clr = [session decryptMessage:petrasMsg dest:&decmsg keys:&keys];
        XCTAssert(clr == PEP_rating_unencrypted);

        NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    identMiro, @"from",
                                    [NSMutableArray arrayWithObjects:
                                     [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"Petra", @"username",
                                      @"pep.test.petra@pep-project.org", @"address",
                                      nil],
                                     nil], @"to",
                                    @"re:Lets use pEp", @"shortmsg",
                                    @"That was so easy !", @"longmsg",
                                    @YES, @"outgoing",
                                    nil];
        
        PEP_STATUS status = [session encryptMessage:msg extra:@[] dest:&mirosMsg];
        XCTAssert(status == PEP_STATUS_OK);
        
    }
    
    [self pEpCleanUp:@"Miro"];
    
    // Again, outgoing flips into incoming
    mirosMsg[@"outgoing"] = @NO;
    
    [self pEpSetUp:@"Petra"];
    {
        NSMutableDictionary *decmsg;
        NSArray* keys;
        NSMutableDictionary *encmsg = mirosMsg.mutableCopy;
        [encmsg setObject:identMiroAtPetra.mutableCopy forKey:@"from"];
        
        
        PEP_color clr = [session decryptMessage:encmsg dest:&decmsg keys:&keys];
        
        XCTAssert(clr == PEP_rating_reliable);
        
        // Check Miro is in DB
        [session updateIdentity:identMiroAtPetra];
        
        XCTAssertNotNil(identMiroAtPetra[@"fpr"]);
        
        NSLog(@"Test fpr %@",identMiroAtPetra[@"fpr"]);

        // Trust to that identity
        [session trustPersonalKey:identMiroAtPetra];

        clr = [session decryptMessage:encmsg dest:&decmsg keys:&keys];
        XCTAssertEqual(clr, PEP_rating_trusted, @"Not trusted");

        // Undo trust
        [session keyResetTrust:identMiroAtPetra];
        
        clr = [session decryptMessage:encmsg dest:&decmsg keys:&keys];
        XCTAssertEqual(clr, PEP_rating_reliable, @"keyResetTrust didn't work?");
        
        // Try compromized
        [session keyCompromized:identMiroAtPetra];

        clr = [session decryptMessage:encmsg dest:&decmsg keys:&keys];
        XCTAssertEqual(clr, PEP_rating_mistrust, @"Not mistrusted");
        
        // Regret
        [session keyResetTrust:identMiroAtPetra];
        
        clr = [session decryptMessage:encmsg dest:&decmsg keys:&keys];
        XCTAssertEqual(clr, PEP_rating_reliable, @"keyResetTrust didn't work?");
        
        // Trust again.
        [session trustPersonalKey:identMiroAtPetra];
        
        clr = [session decryptMessage:encmsg dest:&decmsg keys:&keys];
        XCTAssertEqual(clr, PEP_rating_trusted, @"Not trusted");
        
        XCTAssert([@"That was so easy !" compare:decmsg[@"longmsg"]]==0);
        
    }
    [self pEpCleanUp:@"Petra"];
    
}

#if 0
- (void)testEncryptedMailFromOutlook
{

    [self pEpSetUp];

    // This is the secret key for test001@peptest.ch
    [self importBundledKey:@"B623F674_sec.asc"];

    NSMutableDictionary *identMe = @{ @"username": @"Test 001",
                                     @"address": @"test001@peptest.ch",
                                     @"user_id": @"B623F674" }.mutableCopy;
    NSMutableDictionary *identMeOutlook = @{ @"username": @"Outlook 1",
                                             @"address": @"outlook1@peptest.ch",
                                             @"user_id": @"outlook1" }.mutableCopy;

    NSString *msgFilePath = [[[NSBundle bundleForClass:[self class]] resourcePath]
                             stringByAppendingPathComponent:@"msg_to_B623F674.asc"];
    NSString *msgFileContents = [NSString stringWithContentsOfFile:msgFilePath
                                                          encoding:NSASCIIStringEncoding error:NULL];

    NSMutableDictionary *msg = @{ @"from": identMe,
                                  @"to": @[identMeOutlook],
                                  @"shortmsg": @"Some subject",
                                  @"longmsg": msgFileContents,
                                  @"incoming": @YES }.mutableCopy;

    // Should happen quite fast, since test001@peptest.ch already has a secret key
    [session mySelf:identMe];
    XCTAssert(identMe[@"fpr"]);

    [session updateIdentity:identMeOutlook];

    NSArray *keys;
    NSMutableDictionary *decMsg;
    PEP_color clr = [session decryptMessage:msg dest:&decMsg keys:&keys];
    XCTAssertEqual(clr, PEP_rating_reliable);

    [self pEpCleanUp];
}
#endif

- (void)testEncryptedMailFromOutlook
{
    [self pEpSetUp];

    // This is the secret key for test001@peptest.ch
    [self importBundledKey:@"78EE1DBC_sec.asc"];

    // Mail from outlook, already processed into message dict by the app.
    NSMutableDictionary *msgDict = [self unarchiveDictionary:@"msg_to_78EE1DBC_from_outlook.ser"].mutableCopy;

    // Also extracted "live" from the app.
    NSMutableDictionary *accountDict = [self unarchiveDictionary:@"account_78EE1DBC.ser"].mutableCopy;

    [session mySelf:accountDict];
    XCTAssertNotNil(accountDict[@"fpr"]);

    NSArray* keys;
    NSMutableDictionary *pepDecryptedMail;
    PEP_color color = [session decryptMessage:msgDict dest:&pepDecryptedMail keys:&keys];
    XCTAssertEqual(color, PEP_rating_reliable);

    [self pEpCleanUp];
}

- (void)testEncryptedMailFromOutlook2
{
    [self pEpSetUp];

    // This is the secret key for test001@peptest.ch
    [self importBundledKey:@"80D111EF_sec.asc"];

    // Mail from outlook, already processed into message dict by the app.
    NSMutableDictionary *msgDict = [self unarchiveDictionary:@"msg_to_80D111EF_from_outlook.ser"].mutableCopy;

    // Also extracted "live" from the app.
    NSMutableDictionary *accountDict = [self unarchiveDictionary:@"account_80D111EF.ser"].mutableCopy;
    [accountDict removeObjectForKey:@"comm_type"];
    [accountDict removeObjectForKey:@"fpr"];

    [session mySelf:accountDict];
    XCTAssertNotNil(accountDict[@"fpr"]);

    NSArray* keys;
    NSMutableDictionary *pepDecryptedMail;
    PEP_color color = [session decryptMessage:msgDict dest:&pepDecryptedMail keys:&keys];
    XCTAssertEqual(color, PEP_rating_reliable);

    [self pEpCleanUp];
}

- (void)testEncryptedMailFromOutlook3
{
    [self pEpSetUp];

    // This is the secret key for test001@peptest.ch
    [self importBundledKey:@"80D111EF_sec.asc"];

    // Mail from outlook, already processed into message dict by the app.
    NSMutableDictionary *msgDict = [self unarchiveDictionary:@"msg_to_80D111EF_from_outlook_2.ser"].mutableCopy;

    // Also extracted "live" from the app.
    NSMutableDictionary *accountDict = [self unarchiveDictionary:@"account_80D111EF.ser"].mutableCopy;
    [accountDict removeObjectForKey:@"comm_type"];
    [accountDict removeObjectForKey:@"fpr"];

    [session mySelf:accountDict];
    XCTAssertNotNil(accountDict[@"fpr"]);

    NSArray* keys;
    NSMutableDictionary *pepDecryptedMail;
    PEP_color color = [session decryptMessage:msgDict dest:&pepDecryptedMail keys:&keys];
    XCTAssertEqual(color, PEP_rating_reliable);

    [self pEpCleanUp];
}

- (void)testEncryptedMailFromOutlookUnknownSigner
{
    [self pEpSetUp];

    // This is the public key for test001@peptest.ch
    [self importBundledKey:@"B45CCEB6.asc"];

    // This is the secret key for test001@peptest.ch
    [self importBundledKey:@"B45CCEB6_sec.asc"];

    // Mail from outlook, already processed into message dict by the app.
    NSMutableDictionary *msgDict = [self unarchiveDictionary:@"msg_to_B45CCEB6_from_outlook_unknown_signer.ser"].mutableCopy;

    // Also extracted "live" from the app.
    NSMutableDictionary *accountDict = [self unarchiveDictionary:@"account_B45CCEB6.ser"].mutableCopy;
    [accountDict removeObjectForKey:@"comm_type"];
    [accountDict removeObjectForKey:@"fpr"];

    [session mySelf:accountDict];
    XCTAssertNotNil(accountDict[@"fpr"]);

    NSArray* keys;
    NSMutableDictionary *pepDecryptedMail;
    PEP_color color = [session decryptMessage:msgDict dest:&pepDecryptedMail keys:&keys];
    XCTAssertEqual(color, PEP_rating_reliable);

    [self pEpCleanUp];
}

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
    [accountDict removeObjectForKey:@"comm_type"];
    [accountDict removeObjectForKey:@"fpr"];

    [session mySelf:accountDict];
    XCTAssertNotNil(accountDict[@"fpr"]);

    NSArray* keys;
    NSMutableDictionary *pepDecryptedMail;
    [session decryptMessage:msgDict dest:&pepDecryptedMail keys:&keys];
    XCTAssertNotNil(pepDecryptedMail[kPepLongMessage]);

    [self pEpCleanUp];
}

- (NSString *)loadStringByName:(NSString *)name
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:name withExtension:nil];
    return [NSString stringWithContentsOfURL:url usedEncoding:nil error:nil];
}

/**
 Checks whether the engine silently encrypts for BCCs.
 The current state is that it does this, and thus this test is successful.
 If in the future this test fails, then the engine behavior might have changed.
 */
- (void)testEncryptEngineBcc
{
    NSString *theMessage = @"THE MESSAGE";

    [self pEpSetUp];

    NSMutableDictionary *partner1Orig = @{ kPepAddress: @"partner1@dontcare.me",
                                           kPepUserID: @"partner1",
                                           kPepUsername: @"partner1" }.mutableCopy;

    NSString *keyPartner1 = [self loadStringByName:@"partner1_F2D281C2789DD7F6_pub.asc"];
    XCTAssertNotNil(keyPartner1);
    NSString *keyPartner2 = [self loadStringByName:@"partner2_F9D9CCD0A401311F_pub.asc"];
    XCTAssertNotNil(keyPartner2);
    NSString *keyMePub = [self loadStringByName:@"meATdontcare_E3BFBCA9248FC681_pub.asc"];
    XCTAssertNotNil(keyMePub);
    NSString *keyMeSec = [self loadStringByName:@"meATdontcare_E3BFBCA9248FC681_sec.asc"];
    XCTAssertNotNil(keyMeSec);

    __block NSMutableDictionary *pepEncMail;
    {
        NSMutableDictionary *me = @{ kPepAddress: @"me@dontcare.me",
                                     kPepUserID: @"me",
                                     kPepUsername: @"me" }.mutableCopy;

        NSMutableDictionary *partner1 = partner1Orig.mutableCopy;

        NSMutableDictionary *partner2 = @{ kPepAddress: @"partner2@dontcare.me",
                                           kPepUserID: @"partner2",
                                           kPepUsername: @"partner2" }.mutableCopy;
        NSMutableDictionary *mail = @{ kPepFrom: me, kPepTo: @[partner1],
                                       kPepLongMessage: theMessage,
                                       kPepBCC: @[partner2] }.mutableCopy;

        [PEPSession dispatchSyncOnSession:^(PEPSession *session) {
            [session importKey:keyMePub];
            [session importKey:keyMeSec];
            [session mySelf:me];
            XCTAssertNotNil(me[kPepFingerprint]);
            XCTAssertEqualObjects(me[kPepFingerprint], [@"CC1F73F6FB774BF08B197691E3BFBCA9248FC681"
                                                        lowercaseString]);
            [session importKey:keyPartner1];
            [session importKey:keyPartner2];
            [session encryptMessage:mail extra:nil dest:&pepEncMail];
        }];
    }

    [self pEpCleanUp];

    [self pEpSetUp];
    {
        NSMutableDictionary *partner1 = partner1Orig.mutableCopy;

        [PEPSession dispatchSyncOnSession:^(PEPSession *session) {
            NSString *privateKeyPartner1 = [self loadStringByName:@"partner1_F2D281C2789DD7F6_sec.asc"];
            [session importKey:privateKeyPartner1];
            [session mySelf:partner1];
            XCTAssertNotNil(partner1[kPepFingerprint]);
            XCTAssertEqualObjects(partner1[kPepFingerprint],
                                  [[@"F0CD 3F7B 422E 5D58 7ABD  885B F2D2 81C2 789D D7F6"
                                   stringByReplacingOccurrencesOfString:@" " withString:@""]
                                  lowercaseString]);

            [session importKey:keyPartner1];
            [session importKey:keyPartner2];
            XCTAssertNotNil(privateKeyPartner1);
            [session importKey:privateKeyPartner1];
            NSMutableDictionary *pepDecryptedMail;
            NSArray *keys = [NSArray array];
            [session decryptMessage:pepEncMail dest:&pepDecryptedMail keys:&keys];

            // If this assert holds, then the engine silently will encrypt for BCCs
            XCTAssertEqualObjects(pepDecryptedMail[kPepLongMessage], theMessage);
        }];
    }
}

@end
