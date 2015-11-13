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
            success = [fileManager moveItemAtPath:path
                                   toPath:[path stringByAppendingString:bkpsfx]
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
    
    for(id path in [self pEpWorkFiles])
        [self delFile:path:NULL];

    if(restore)
        for(id path in [self pEpWorkFiles])
            [self undelFile:path:restore];

    [PEPiOSAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];
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
    
    // MCOAddress.userId MUST be set to same as identity[@"user_id"]
    // for any MCOAddress referring own user, i.e. msg->from
    MCOAddress * from = [[MCOAddress alloc] initWithDict:identAlice];

    // Make a mail message, with (for now) unknown peer Bob
    MCOAddress * to1 = [MCOAddress addressWithDisplayName:@"pEp Test Bob" mailbox:@"pep.test.bob@pep-project.org"];

    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to1]];
    [[builder header] setSubject:@"All Green Test"];
    [builder setTextBody:@"This is a text content"];
    builder.outgoing = YES;

    // Test with unknown Bob
    PEP_color clr = [session outgoingMessageColor:builder];
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
    clr = [session outgoingMessageColor:builder];
    XCTAssert( clr == PEP_rating_yellow);
    
    // Let' say we got that handshake, set PEP_ct_confirmed in Bob's identity
    [session trustPersonalKey:identBob];

    [session updateIdentity:identBob];

    // This time it should be green
    clr = [session outgoingMessageColor:builder];
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
    
    MCOAddress * to2 = [MCOAddress addressWithDisplayName:@"pEp Test John" mailbox:@"pep.test.john@pep-project.org"];
    [[builder header] setCc:@[to2]];

    // Yellow ?
    clr = [session outgoingMessageColor:builder];
    XCTAssert( clr == PEP_rating_yellow);

    MCOMessageBuilder * encBuilder;
    [session encryptMessage:builder extra:@[] dest:&encBuilder];
    
    [self pEpCleanUp];
}

- (void)testTwoNewUsers {
    
    [self pEpSetUp];
    
    NSMutableDictionary *identPetra = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"Petra", @"username",
                                    @"pep.test.petra@pep-project.org", @"address",
                                    @"Me", @"user_id",
                                    nil];
    
    [session mySelf:identPetra];
    
    XCTAssert(identPetra[@"fpr"]);

    NSData* petrasMsg;
    
    @autoreleasepool {
        MCOAddress * from = [[MCOAddress alloc] initWithDict:identPetra];
        
        MCOAddress * to = [MCOAddress addressWithDisplayName:@"Miro" mailbox:@"pep.test.miro@pep-project.org"];
        
        MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
        [[builder header] setFrom:from];
        [[builder header] setTo:@[to]];
        [[builder header] setSubject:@"Lets use pEP"];
        [builder setTextBody:@"Dear I just installed pEp, you should do the same !"];
        builder.outgoing = YES;
        
        MCOMessageBuilder * encBuilder;
        [session encryptMessage:builder extra:@[] dest:&encBuilder];
        
        petrasMsg = [encBuilder data];
    }
    
    [self pEpCleanUp:@"Petra"];
    
    [self pEpSetUp];
    
    NSMutableDictionary *identMiro = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Miro", @"username",
                                       @"pep.test.miro@pep-project.org", @"address",
                                       @"Me", @"user_id",
                                       nil];
    
    [session mySelf:identMiro];
    
    XCTAssert(identMiro[@"fpr"]);
    
    @autoreleasepool {
        MCOMessageBuilder * builder;
        // Parse and try to decrypt Petra's message, this should import Petra's key.
        MCOMessageParser* parser = [[MCOMessageParser alloc] initWithData:petrasMsg ];
        NSArray* keys;
        [session decryptMessage:parser dest:&builder keys:&keys];
    }

    NSData* mirosMsg;
    
    @autoreleasepool {
        MCOAddress * from = [[MCOAddress alloc] initWithDict:identMiro];
        
        MCOAddress * to = [MCOAddress addressWithDisplayName:@"Petra" mailbox:@"pep.test.petra@pep-project.org"];
        
        MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
        [[builder header] setFrom:from];
        [[builder header] setTo:@[to]];
        [[builder header] setSubject:@"re:Lets use pEP"];
        [builder setTextBody:@"That was so easy !"];
        builder.outgoing = YES;
        
        // Yellow ?
        PEP_color clr = [session outgoingMessageColor:builder];
        XCTAssert( clr == PEP_rating_yellow);

        
        MCOMessageBuilder * encBuilder;
        [session encryptMessage:builder extra:@[] dest:&encBuilder];
        
        mirosMsg = [encBuilder data];
    }
    
    [self pEpCleanUp:@"Miro"];
    
}


@end
