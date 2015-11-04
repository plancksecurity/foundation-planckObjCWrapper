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
}

- (void)testSession {
    PEPSession *otherSession;
    
    [super setUp];
    otherSession = [[PEPSession alloc]init];
    XCTAssert(otherSession);
}

- (void)testExample {
    
    NSArray *trustwords = [session trustwords:@"DB4713183660A12ABAFA7714EBE90D44146F62F4" forLanguage:@"en" shortened:false];
    XCTAssertEqual([trustwords count], 10);
    XCTAssertEqualObjects([trustwords firstObject], @"BAPTISMAL");
    
    MCOAddress * from = [MCOAddress addressWithDisplayName:@"Volker Birk" mailbox:@"vb@dingens.org"];
    MCOAddress * to1 = [MCOAddress addressWithDisplayName:@"Outlook Test" mailbox:@"outlooktest@dingens.org"];
}
@end
