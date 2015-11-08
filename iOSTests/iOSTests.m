//
//  iOSTests.m
//  iOSTests
//
//  Created by Edouard Tisserant on 03/11/15.
//  Copyright © 2015 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "pEpiOSAdapter/PEPiOSAdapter.h"
#import "pEpiOSAdapter/PEPSession.h"

@interface iOSTests : XCTestCase

@end

@implementation iOSTests

PEPSession *session;

-(void)delFile : (NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:path];
    NSLog(@"Path to file: %@", path);
    NSLog(@"File exists: %d", fileExists);
    NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:path]);
    if (fileExists)
    {
        BOOL success = [fileManager removeItemAtPath:path error:&error];
        if (!success) NSLog(@"Error: %@", [error localizedDescription]);
    }
}

- (void)setUp {
    [super setUp];
    NSString* home = [[[NSProcessInfo processInfo]environment]objectForKey:@"HOME"];
    
    [self delFile:[home stringByAppendingPathComponent:@".pEp_management.db"]];
    [self delFile:[home stringByAppendingPathComponent:@".gnupg"]];
    
    [PEPiOSAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];
    session = [[PEPSession alloc]init];
    XCTAssert(session);
}

- (void)tearDown {
    [super tearDown];
    session=nil;
}

- (void)testEmptySession {
    // Do nothing.
    // Setup and TearDown create and destroy
    // session in that thread alredy
}

- (void)testTrustWords {
    
    NSArray *trustwords = [session trustwords:@"DB4713183660A12ABAFA7714EBE90D44146F62F4" forLanguage:@"en" shortened:false];
    XCTAssertEqual([trustwords count], 10);
    XCTAssertEqualObjects([trustwords firstObject], @"BAPTISMAL");
    
}

- (void)importBundledKey : (NSString*)item {
    
    NSString *txtFilePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:item];
    NSString *txtFileContents = [NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:NULL];
    //[keysStrings setObject:txtFileContents forKey:txtFilePath];
    [session importKey:txtFileContents];
}

- (void)testOutgoingColors {
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
    
    // Make a mail message, with (for now) unknown peer Bob
    MCOAddress * from = [MCOAddress addressWithDisplayName:@"pEp Test Alice" mailbox:@"pep.test.alice@pep-project.org"];
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

}
@end
