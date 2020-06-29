//
//  PEPPassphraseCacheTest.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 25.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPPassphraseCache.h"
#import "PEPPassphraseCacheInternal.h"

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
    NSArray *expected = @[@"", passphrase2, passphrase1];
    XCTAssertEqualObjects(self.cache.passphrases, expected);
}

- (void)testTwentyPassphrases
{
    NSMutableArray *passphrases = [NSMutableArray arrayWithCapacity:20];
    for (NSUInteger i = 1; i <= 20; ++i) {
        NSString *newPhrase = [NSString stringWithFormat:@"passphrase_%lu", (unsigned long) i];
        [passphrases addObject:newPhrase];
        [self.cache addPassphrase:newPhrase];
    }

    NSMutableArray *expected = [NSMutableArray arrayWithArray:[self reversedArray:passphrases]];

    XCTAssertEqual(self.cache.passphrases.count, expected.count + 1);
    [expected insertObject:@"" atIndex:0];
    XCTAssertEqualObjects(self.cache.passphrases, expected);
}

- (void)testTwentyOnePassphrases
{
    NSMutableArray *expectedPassphrases = [NSMutableArray arrayWithCapacity:20];
    for (NSUInteger i = 1; i <= 20; ++i) {
        NSString *newPhrase = [NSString stringWithFormat:@"passphrase_%lu", (unsigned long) i];
        [expectedPassphrases addObject:newPhrase];
        [self.cache addPassphrase:newPhrase];
    }

    NSString *latestPassphrase = @"theLatest";
    [self.cache addPassphrase:latestPassphrase];
    [expectedPassphrases addObject:latestPassphrase];

    // Last added passphrase is the newest, so it comes first.
    expectedPassphrases = [NSMutableArray arrayWithArray:[self reversedArray:expectedPassphrases]];

    // There are 21 passphrases, so the oldest (last) is removed.
    [expectedPassphrases removeLastObject];

    [expectedPassphrases insertObject:@"" atIndex:0];
    XCTAssertEqualObjects(self.cache.passphrases, expectedPassphrases);
}

- (void)testTimeout
{
    NSTimeInterval timeout = 0.2;
    PEPPassphraseCache *ownCache = [[PEPPassphraseCache alloc]
                                    initWithPassphraseTimeout:timeout
                                    checkExpiryInterval:timeout/2];

    NSString *ownPassphrase = @"blah";
    [ownCache addPassphrase:ownPassphrase];

    NSArray *expectedBefore = @[@"", ownPassphrase];
    XCTAssertEqualObjects(ownCache.passphrases, expectedBefore);

    [NSThread sleepForTimeInterval:2*timeout];
    XCTAssertEqualObjects(ownCache.passphrases, @[@""]);
}

- (void)testResetTimeout
{
    NSString *passphrase1 = @"somepass1";
    NSString *passphrase2 = @"somepass2";
    NSString *passphrase3 = @"somepass3";

    [self.cache addPassphrase:passphrase1];
    [self.cache addPassphrase:passphrase2];
    [self.cache addPassphrase:passphrase3];

    [self.cache resetTimeoutForPassphrase:passphrase1];

    NSArray *expected1 = @[@"", passphrase1, passphrase3, passphrase2];
    XCTAssertEqualObjects(self.cache.passphrases, expected1);

    [self.cache resetTimeoutForPassphrase:passphrase3];
    NSArray *expected2 = @[@"", passphrase3, passphrase1, passphrase2];
    XCTAssertEqualObjects(self.cache.passphrases, expected2);
}

#pragma mark - Helpers

- (NSArray *)reversedArray:(NSArray *)array
{
    NSMutableArray *reversedArray = [NSMutableArray arrayWithCapacity:array.count];
    for (id obj in [array reverseObjectEnumerator]) {
        [reversedArray addObject:obj];
    }
    return [NSArray arrayWithArray:reversedArray];
}

@end
