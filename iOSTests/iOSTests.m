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

- (void)setUp {
    [super setUp];
    [PEPiOSAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSession {
    id session;
    session = [[PEPSession alloc]init];
    XCTAssert(session);
}


@end
