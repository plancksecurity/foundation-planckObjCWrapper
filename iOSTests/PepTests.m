//
//  PepTests.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 01/08/16.
//  Copyright © 2016 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "pEpiOSAdapter/PEPiOSAdapter.h"
#import "pEpiOSAdapter/PEPSession.h"
#import "pEpiOSAdapter/PEPLanguage.h"

@interface PepTests : XCTestCase

@end

@implementation PepTests

- (void)setUp {
    [super setUp];
    [PEPiOSAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSessionFinalization {
    PEPSession *session = [[PEPSession alloc] init];
    session = nil;
}

- (void)testLanguageList {
    PEPSession *session = [[PEPSession alloc] init];
    NSArray<PEPLanguage *> *langs = [session languageList];
    XCTAssertGreaterThan(langs.count, 0);
    BOOL foundEn = NO;
    for (PEPLanguage *lang in langs) {
        if ([lang.code isEqualToString:@"en"]) {
            foundEn = YES;
        }
    }
    XCTAssertTrue(foundEn);
}

@end
