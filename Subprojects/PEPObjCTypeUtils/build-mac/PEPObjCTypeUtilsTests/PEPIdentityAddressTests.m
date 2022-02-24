//
//  PEPIdentityAddressTests.m
//  PEPObjCTypeUtilsTests_macOS
//
//  Created by Martín Brude on 10/2/22.
//

#import <XCTest/XCTest.h>
#import "PEPIdentity+URIAddressScheme.h"

@interface PEPIdentityAddressTests : XCTestCase

@end

NSString *defaultSctpScheme = @"sctp";
NSString *defaultIPV4 = @"1.2.3.4";
NSString *defaultIPV6 = @"1::2::3::4::5::6::7::8";
NSUInteger defaultPort = 666;
NSString *defaultUserID = @"1";

@implementation PEPIdentityAddressTests

- (void)testIdentityWithSchemeOnly {
    NSString *address = [NSString stringWithFormat:@"%@:%@", defaultSctpScheme, @"WHATEVERVALUE"];
    PEPIdentity *identity = [[PEPIdentity alloc] initWithAddress:address];
    XCTAssertNil([identity getPort]);
    XCTAssertNil([identity getIPV4]);
    XCTAssertNil([identity getIPV6]);
    XCTAssertNil([identity getScheme]);
}

- (void)testIdentityWithIPV4 {
    PEPIdentity *identity = [[PEPIdentity alloc] initWithUserID:defaultUserID scheme:defaultSctpScheme ipV4:defaultIPV4 port:defaultPort];
    XCTAssertEqual(defaultPort, [[identity getPort] longLongValue]);

    NSString *ipV4 = [identity getIPV4];
    XCTAssertTrue([defaultIPV4 isEqualToString:ipV4], @"Strings are not equal %@ %@", defaultIPV4, ipV4);

    NSString *scheme = [identity getScheme];
    XCTAssertTrue([defaultSctpScheme isEqualToString:scheme], @"Strings are not equal %@ %@", defaultSctpScheme, scheme);
}

- (void)testIdentityWithIPV4ButExpectingIPV6 {
    PEPIdentity *identity = [[PEPIdentity alloc] initWithUserID:defaultUserID scheme:defaultSctpScheme ipV4:defaultIPV4 port:defaultPort];

    NSString *ipV6 = [identity getIPV6];
    XCTAssertNil(ipV6);
}

- (void)testIdentityWithIPV6 {
    PEPIdentity *identity = [[PEPIdentity alloc] initWithUserID:defaultUserID scheme:defaultSctpScheme ipV6:defaultIPV6 port:defaultPort];
    XCTAssertEqual(defaultPort, [[identity getPort] longLongValue]);

    NSString *ipV6 = [identity getIPV6];
    XCTAssertTrue([defaultIPV6 isEqualToString:ipV6], @"Strings are not equal %@ %@", defaultIPV6, ipV6);

    NSString *scheme = [identity getScheme];
    XCTAssertTrue([defaultSctpScheme isEqualToString:scheme], @"Strings are not equal %@ %@", defaultSctpScheme, scheme);
}

- (void)testIdentityWithIPV6ButExpectingIPV4 {
    PEPIdentity *identity = [[PEPIdentity alloc] initWithUserID:defaultUserID scheme:defaultSctpScheme ipV6:defaultIPV6 port:defaultPort];
    NSString *ipV4 = [identity getIPV4];
    XCTAssertNil(ipV4);
}

@end
