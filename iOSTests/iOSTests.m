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

    NSArray *trustwords = [session trustwords:@"DB4713183660A12ABAFA7714EBE90D44146F62F4" forLanguage:@"en" shortened:false];
    XCTAssertEqual([trustwords count], 10);
    XCTAssertEqualObjects([trustwords firstObject], @"BAPTISMAL");
    
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

- (void)importBundledKey : (NSString*)item {
    
    NSString *txtFilePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:item];
    NSString *txtFileContents = [NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:NULL];
    //[keysStrings setObject:txtFileContents forKey:txtFilePath];
    [session importKey:txtFileContents];
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
    
    // Let' say we got that handshake, set PEP_ct_confirmed in Bob's identity
    [session trustPersonalKey:identBob];

    [session updateIdentity:identBob];

    // This time it should be green
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
        
        PEP_color clr = [session decryptMessage:mirosMsg dest:&decmsg keys:&keys];
        
        // At that time, Miro is still not in pEp's database.
        XCTAssert(clr == PEP_rating_unreliable);
        
        // This will add Miro in pEp db, matching key stored in pgp keyring,
        // and imported at decrypt.
        [session updateIdentity:identMiroAtPetra];

        XCTAssert(identMiroAtPetra[@"fpr"]);

        clr = [session decryptMessage:mirosMsg dest:&decmsg keys:&keys];
        
        // Now Miro is in pEp's database.
        XCTAssert(clr == PEP_rating_reliable);

        // Add some trust to that contact
        [session trustPersonalKey:identMiroAtPetra];

        clr = [session decryptMessage:mirosMsg dest:&decmsg keys:&keys];
        XCTAssert(clr == PEP_rating_trusted);

        // Lose trust to that contact
        [session keyResetTrust:identMiroAtPetra];
        
        clr = [session decryptMessage:mirosMsg dest:&decmsg keys:&keys];
        XCTAssertEqual(clr, PEP_rating_unreliable, @"keyResetTrust didn't work?");

        
        XCTAssert([@"That was so easy !" compare:decmsg[@"longmsg"]]==0);
        
    }
    [self pEpCleanUp:@"Petra"];
    
}


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

    NSArray *keys;
    NSMutableDictionary *decMsg;
    PEP_color clr = [session decryptMessage:msg dest:&decMsg keys:&keys];
    XCTAssertEqual(clr, PEP_rating_reliable);

    [self pEpCleanUp];
}

@end