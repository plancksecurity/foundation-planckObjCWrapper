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

- (void)testStringBetweenStringWithMultipleOccurence {
    NSString * extractedExpr = [@"One 1 three One 2 three One 3 three" stringBetweenString:@"One " andString: @" three"];
    NSString *result = extractedExpr;
    NSString *expectedResult = @"1";
    XCTAssertTrue([result isEqualToString:expectedResult], @"Strings are not equal %@ %@", result, expectedResult);
}

- (void)testStringBetweenStringWithNothingInBetween {
    NSString *result = [@"Onethree" stringBetweenString:@"One" andString: @"three"];
    NSString *expectedResult = @"";
    XCTAssertTrue([result isEqualToString:expectedResult], @"Strings are not equal %@ %@", result, expectedResult);
}

- (void)testStringBetweenStringWithOnlyOneValidParam {
    NSString *result = [@"Onethree" stringBetweenString:@"One" andString: @"Four"];
    XCTAssertNil(result);
}

- (void)testStringBetweenStringWithEmojis {
    NSString *result = [@"😃😎🤩" stringBetweenString:@"😃" andString: @"🤩"];
    NSString *expectedResult = @"😎";
    XCTAssertTrue([result isEqualToString:expectedResult], @"Strings are not equal %@ %@", result, expectedResult);
}

- (void)testStringisNumericWithEmojis {
    BOOL result = [@"👀" isNumeric];
    XCTAssertFalse(result);
}

- (void)testStringisNumericWithText {
    BOOL result = [@"Foo" isNumeric];
    XCTAssertFalse(result);
}

- (void)testStringisNumericWithTextAndNumber {
    BOOL result = [@"Foo 10" isNumeric];
    XCTAssertFalse(result);
}

- (void)testStringisNumericWithNumberAndText {
    BOOL result = [@"42foo" isNumeric];
    XCTAssertFalse(result);
}

- (void)testStringisNumericWithOnlyFloatNumber {
    BOOL result = [@"10.2" isNumeric];
    XCTAssertTrue(result);
}

- (void)testStringisNumericWithOnlyIntegerNumber {
    BOOL result = [@"10" isNumeric];
    XCTAssertTrue(result);
}

@end
