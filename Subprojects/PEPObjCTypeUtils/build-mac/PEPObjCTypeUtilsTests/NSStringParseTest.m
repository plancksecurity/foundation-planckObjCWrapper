//
//  NSStringParseTest.m
//  PEPObjCTypeUtilsTests_macOS
//
//  Created by Martín Brude on 10/2/22.
//

#import <XCTest/XCTest.h>
#import "NSString+PEPParse.h"

@interface NSStringParseTest : XCTestCase

@end

@implementation NSStringParseTest

- (void)testStringBetweenString {
    NSString *result = [@"One two three" stringBetweenString:@" " andString: @" "];
    NSString *expectedResult = @"two";
    XCTAssertTrue([result isEqualToString:expectedResult], @"Strings are not equal %@ %@", result, expectedResult);
}

- (void)testStringBetweenStringWithEmptyEnd {
    NSString *result = [@"One two three" stringBetweenString:@"One " andString: @""];
    XCTAssertNil(result);
}
- (void)testStringBetweenStringWithEmptyStart {
    NSString *result = [@"One two three" stringBetweenString:@"" andString: @" three"];
    XCTAssertNil(result);
}

- (void)testStringBetweenStringIsCaseSensitve {
    NSString *result = [@"One two three" stringBetweenString:@"ONE " andString: @" THREE"];
    XCTAssertNil(result);
}

@end
