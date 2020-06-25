//
//  PEPPasswordCacheTest.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 25.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPPasswordCache.h"

@interface PEPPasswordCacheTest : XCTestCase

@property (nonatomic) PEPPasswordCache *cache;

@end

@implementation PEPPasswordCacheTest

- (void)setUp
{
    self.cache = [[PEPPasswordCache alloc] init];
}

- (void)testContainsEmptyPassphrase
{
    XCTAssertEqual(self.cache.passwords.count, 1);
    XCTAssertEqualObjects(self.cache.passwords, @[@""]);
}

- (void)testContainsSetPassphrase
{
    NSString *passphrase = @"somepass";
    [self.cache addPassword:passphrase];
    XCTAssertEqual(self.cache.passwords.count, 2);
    XCTAssertEqualObjects(self.cache.passwords, @[@""]);
}

@end
