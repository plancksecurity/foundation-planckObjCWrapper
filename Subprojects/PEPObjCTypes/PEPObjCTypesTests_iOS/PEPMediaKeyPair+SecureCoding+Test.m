//
//  PEPMediaKeyPair+SecureCoding+Test.m
//  PEPObjCTypesTests_iOS
//
//  Created by Dirk Zimmermann on 06.09.22.
//

#import <XCTest/XCTest.h>

#import "PEPMediaKeyPair+SecureCoding.h"

@interface PEPMediaKeyPair_SecureCoding_Test : XCTestCase

@end

@implementation PEPMediaKeyPair_SecureCoding_Test

- (void)testBasicArchiveUnarchive
{
    NSString * const pattern = @"thePattern";
    NSString * const fingerprint = @"theFingerprint";
    PEPMediaKeyPair *mediaKeyPair1 = [[PEPMediaKeyPair alloc] initWithPattern:pattern
                                                                  fingerprint:fingerprint];
    XCTAssertTrue([mediaKeyPair1 conformsToProtocol:@protocol(NSSecureCoding)]);

    PEPMediaKeyPair *mediaKeyPair2 = [self archiveAndUnarchiveMediaKeyPair:mediaKeyPair1];

    XCTAssertEqualObjects(mediaKeyPair1, mediaKeyPair2);

    XCTAssertEqualObjects(mediaKeyPair1.pattern, mediaKeyPair2.pattern);
    XCTAssertEqualObjects(mediaKeyPair1.fingerprint, mediaKeyPair2.fingerprint);
}

// MARK: - Helper

- (PEPMediaKeyPair *)archiveAndUnarchiveMediaKeyPair:(PEPMediaKeyPair *)mediaKeyPair
{
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mediaKeyPair
                                         requiringSecureCoding:YES
                                                         error:&error];
    XCTAssertNotNil(data);

    PEPMediaKeyPair *unarchivedMediaKeyPair = [NSKeyedUnarchiver
                                               unarchivedObjectOfClass:[PEPMediaKeyPair class]
                                               fromData:data
                                               error:&error];
    XCTAssertNotNil(unarchivedMediaKeyPair);

    return unarchivedMediaKeyPair;
}

@end
