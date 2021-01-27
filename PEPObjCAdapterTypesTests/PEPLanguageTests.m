//
//  PEPLanguageTests.m
//  PEPObjCAdapterTypesTests_macOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPLanguageTest.h"

@interface PEPLanguageTests : XCTestCase
@property (nonatomic, strong) PEPLanguageTest *language;
@property (nonatomic, strong) PEPLanguageTest *unarchivedLanguage;
@end

@implementation PEPLanguageTests

- (void)setUp {
    [super setUp];

    self.language = [PEPLanguageTest new];

    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.language
                                         requiringSecureCoding:YES
                                                         error:&error];

    XCTAssertNil(error, "Error archiving pEp language.");

    self.unarchivedLanguage = [NSKeyedUnarchiver unarchivedObjectOfClass:[PEPLanguage class]
                                                                fromData:data
                                                                   error:&error];

    XCTAssertNil(error, "Error unarchiving pEp language.");
}

- (void)testConformsSecureCodingProtocol {
    XCTAssertTrue([self.language conformsToProtocol:@protocol(NSSecureCoding)]);
}

- (void)testSupportsSecureCodingProtocol {
    XCTAssertTrue([PEPLanguage supportsSecureCoding]);
}

- (void)testLanguageCode {
    XCTAssertEqualObjects(self.language.code, self.unarchivedLanguage.code);
}

- (void)testLanguageName {
    XCTAssertEqualObjects(self.language.name, self.unarchivedLanguage.name);
}

- (void)testLanguageSentence {
    XCTAssertEqualObjects(self.language.sentence, self.unarchivedLanguage.sentence);
}

@end
