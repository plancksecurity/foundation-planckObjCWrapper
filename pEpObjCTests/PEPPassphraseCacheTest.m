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
    NSArray *expected = @[@"", passphrase];
    XCTAssertEqualObjects(self.cache.passphrases, expected);
}

- (void)testContainsSetPassphrases
{
    NSString *passphrase1 = @"somepass1";
    NSString *passphrase2 = @"somepass2";

    [self.cache addPassphrase:passphrase1];
    [self.cache addPassphrase:passphrase2];

    XCTAssertEqual(self.cache.passphrases.count, 3);
    NSArray *expected = @[@"", passphrase1, passphrase2];
    XCTAssertEqualObjects(self.cache.passphrases, expected);
}

- (void)testTwentyPassphrases
{
    NSMutableArray *passphrases = [NSMutableArray arrayWithCapacity:20];
    for (NSUInteger i = 0; i < 20; ++i) {
        NSString *newPhrase = [NSString stringWithFormat:@"passphrase_%lu", (unsigned long) i];
        [passphrases addObject:newPhrase];
        [self.cache addPassphrase:newPhrase];
    }

    XCTAssertEqual(self.cache.passphrases.count, passphrases.count + 1);
    NSMutableArray *expected = [NSMutableArray arrayWithArray:passphrases];
    [expected insertObject:@"" atIndex:0];
    XCTAssertEqualObjects(self.cache.passphrases, expected);
}

- (void)testTwentyOnePassphrases
{
    NSMutableArray *passphrases = [NSMutableArray arrayWithCapacity:20];
    for (NSUInteger i = 0; i < 20; ++i) {
        NSString *newPhrase = [NSString stringWithFormat:@"passphrase_%lu", (unsigned long) i];
        [passphrases addObject:newPhrase];
        [self.cache addPassphrase:newPhrase];
    }

    NSString *latestPassphrase = @"theLatest";
    [passphrases replaceObjectAtIndex:0 withObject:latestPassphrase];

    XCTAssertEqual(self.cache.passphrases.count, passphrases.count + 1);
    NSMutableArray *expected = [NSMutableArray arrayWithArray:passphrases];
    [expected insertObject:@"" atIndex:0];
    XCTAssertEqualObjects(self.cache.passphrases, expected);
}

@end
