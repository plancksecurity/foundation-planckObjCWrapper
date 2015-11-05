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

- (void)setUp {
    [super setUp];
    [PEPiOSAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];
    session = [[PEPSession alloc]init];
    XCTAssert(session);
}

- (void)tearDown {
    [super tearDown];
    session=nil;
}

 - (void)test0Session {
    PEPSession *otherSession;
    
    [super setUp];
    otherSession = [[PEPSession alloc]init];
    XCTAssert(otherSession);
    otherSession = nil;
}

- (void)test1TrustWords {
    
    NSArray *trustwords = [session trustwords:@"DB4713183660A12ABAFA7714EBE90D44146F62F4" forLanguage:@"en" shortened:false];
    XCTAssertEqual([trustwords count], 10);
    XCTAssertEqualObjects([trustwords firstObject], @"BAPTISMAL");
    
}

- (void)testMCOMessageAPI {
    NSArray *keyFiles = @[
                          // Our test user :
                          // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
                          // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
                          @"6FF00E97_sec.asc",
                          // Other peers :
                          // pEp Test Bob (test key, don't use) <pep.test.bob@pep-project.org>
                          // BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39
                          @"0xC9C2EE39.asc",
                          // pEp Test John (test key, don't use) <pep.test.john@pep-project.org>
                          // AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575
                          @"0x70DCF575.asc"];
    //NSMutableDictionary *keysStrings = [[NSMutableDictionary alloc] init];

    for (NSString *item in keyFiles) {
        NSString *txtFilePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:item];
        NSString *txtFileContents = [NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:NULL];
        //[keysStrings setObject:txtFileContents forKey:txtFilePath];
        [session importKey:txtFileContents];
    }
    
    NSMutableDictionary *identAlice = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"pEp Test Alice", @"username",
                                  @"pep.test.alice@pep-project.org", @"address",
                                  @"23", @"user_id",
                                  @"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97",@"fpr",
                                  nil];
 
    [session mySelf:identAlice];
    
    NSMutableDictionary *identBob = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"pEp Test Bob", @"username",
                                  @"pep.test.bob@pep-project.org", @"address",
                                  @"42", @"user_id",
                                  @"BFCDB7F301DEEEBBF947F29659BFF488C9C2EE39",@"fpr",
                                  nil];
    
    [session updateIdentity:identBob];
    
    NSMutableDictionary *identJohn = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"pEp Test John", @"username",
                                  @"pep.test.john@pep-project.org", @"address",
                                  @"101", @"user_id",
                                  @"AA2E4BEB93E5FE33DEFD8BE1135CD6D170DCF575",@"fpr",
                                  nil];
    
    [session updateIdentity:identJohn];
    
    MCOAddress * from = [MCOAddress addressWithDisplayName:@"pEp Test Alice" mailbox:@"pep.test.alice@pep-project.org"];
    MCOAddress * to1 = [MCOAddress addressWithDisplayName:@"pEp Test Bob" mailbox:@"pep.test.bob@pep-project.org"];
    MCOAddress * to2 = [MCOAddress addressWithDisplayName:@"pEp Test John" mailbox:@"pep.test.John@pep-project.org"];

    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to1]];
    [[builder header] setCc:@[to2]];
    [[builder header] setSubject:@"All Green Test"];
    //[[builder header] setDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    //[[builder header] setMessageID:@"MyMessageID123@mail.gmail.com"];
    [builder setTextBody:@"This is a text content"];
    builder.outgoing = YES;
    

    XCTAssert([session outgoingMessageColor:builder]==PEP_rating_green);
}
@end
