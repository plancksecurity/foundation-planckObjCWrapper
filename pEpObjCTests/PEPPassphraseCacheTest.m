//
//  PEPPassphraseCacheTest.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 25.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPPassphraseCache.h"

@interface PEPPassphraseCacheTest : XCTestCase

@property (nonatomic) PEPPassphraseCache *cache;

@end

@implementation PEPPassphraseCacheTest

- (void)setUp
{
    self.cache = [[PEPPassphraseCache alloc] init];
}

- (void)testContainsEmptyPassphrase
{
    XCTAssertEqual(self.cache.passphrases.count, 1);
    XCTAssertEqualObjects(self.cache.passphrases, @[@""]);
}

- (void)testContainsSetPassphrase
{
    NSString *passphrase = @"somepass";
    [self.cache addPassphrase:passphrase];
    XCTAssertEqual(self.cache.passphrases.count, 2);
    XCTAssertEqualObjects(self.cache.passphrases, @[@""]);
}

@end
