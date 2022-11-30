//
//  PepTests.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 01/08/16.
//  Copyright © 2016 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

@import PEPObjCAdapter;

#import "PEPInternalSession.h"
#import "PEPSessionProvider.h"

@interface PepTests : XCTestCase
@end

@implementation PepTests

- (void)setUp {
    [super setUp];
    [PEPObjCAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];
}

- (void)tearDown
{
    [PEPSession cleanup];
}

- (void)testSessionFinalization {
    PEPSession *session = [[PEPSession alloc] init];
    session = nil;
}

- (void)testLanguageList {
    PEPInternalSession *session = [PEPSessionProvider session];
    NSError *error = nil;
    NSArray<PEPLanguage *> *langs = [session languageListWithError:&error];
    XCTAssertNil(error);
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
