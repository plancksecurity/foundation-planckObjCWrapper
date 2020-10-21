//
//  PEPMessageUtilTest.m
//  pEpObjCAdapterTests
//
//  Created by Andreas Buff on 26.01.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPMessageUtil.h"
#import "PEPObjCAdapterFramework.h"

@interface PEPMessageUtilTest : XCTestCase
@property pEp_identity *pepIdentitySomeOne;
@property NSDictionary *dictSomeOne;
@property pEp_identity *pepIdentityMe;
@property NSDictionary *dictMe;
@end

@implementation PEPMessageUtilTest

- (void)setUp
{
    // Someones (not "Me") identity as struct and dict.
    self.pepIdentitySomeOne = new_identity("some@some.com",
                                           "SOMEONES-FPR_IS_PRETTY_SHORT",
                                           "SOMEONES-USER-ID",
                                           "Bob 12345");
    self.pepIdentitySomeOne->comm_type = PEP_ct_to_be_checked_confirmed;
    self.pepIdentitySomeOne->me = false;
    self.dictSomeOne = @{kPepAddress:@"some@some.com",
                         kPepFingerprint:@"SOMEONES-FPR_IS_PRETTY_SHORT",
                         kPepUserID:@"SOMEONES-USER-ID",
                         kPepUsername:@"Bob 12345",
                         kPepCommType:[NSNumber numberWithInt: PEP_ct_to_be_checked_confirmed],
                         kPepIsOwn:[NSNumber numberWithBool: NO]};

    // "Me" identity as struct and dict.
    self.pepIdentityMe = new_identity("me@me.com",
                                           "MY-FPR_IS_PRETTY_SHORT",
                                           "MY-USER-ID",
                                           "Me 12345");
    self.pepIdentityMe->comm_type = PEP_ct_confirmed;
    self.pepIdentityMe->me = true;
    self.dictMe = @{kPepAddress:@"me@me.com",
                         kPepFingerprint:@"MY-FPR_IS_PRETTY_SHORT",
                         kPepUserID:@"MY-USER-ID",
                         kPepUsername:@ "Me 12345",
                         kPepCommType:[NSNumber numberWithInt: PEP_ct_confirmed],
                         kPepIsOwn:[NSNumber numberWithBool: YES]};
}

#pragma mark - PEP_identityDictToStruct

- (void)testIdentityDictToStruct_someone
{
    pEp_identity *testee = PEP_identityToStruct(self.dictSomeOne);
    [self assertEqualIdentityStructs:testee second:self.pepIdentitySomeOne shouldFail:NO];
}

- (void)testIdentityDictToStruct_me
{
    pEp_identity *testee= PEP_identityToStruct(self.dictMe);
    [self assertEqualIdentityStructs:testee second:self.pepIdentityMe shouldFail:NO];
}

#pragma mark - PEP_identityDictFromStruct

- (void)testIdentityDictFromStruct_someone
{
    NSDictionary *testee = PEP_identityDictFromStruct(self.pepIdentitySomeOne);
    [self assertEqualIdentityDicts:testee second:self.dictSomeOne shouldFail:NO];
}

- (void)testIdentityDictFromStruct_me
{
    NSDictionary *testee = PEP_identityDictFromStruct(self.pepIdentityMe);
    [self assertEqualIdentityDicts:testee second:self.dictMe shouldFail:NO];
}



#pragma mark - HELPER

- (void)assertEqualIdentityStructs:(pEp_identity *)first
                            second:(pEp_identity *)second
                        shouldFail:(BOOL)shouldFail
{
    XCTAssert(shouldFail
              ? strcmp(first->address, second->address) != 0
              : strcmp(first->address, second->address) == 0);
    XCTAssert(shouldFail
              ? strcmp(first->fpr, second->fpr) != 0
              :  strcmp(first->fpr, second->fpr) == 0);
    XCTAssert(shouldFail
              ? strcmp(first->user_id, second->user_id) != 0
              : strcmp(first->user_id, second->user_id) == 0);
    XCTAssert(shouldFail
              ? strcmp(first->username, second->username) != 0
              :  strcmp(first->username, second->username) == 0);
    XCTAssert(shouldFail
              ? first->comm_type != second->comm_type
              :  first->comm_type == second->comm_type);
    XCTAssert(shouldFail
              ? first->me != second->me
              : first->me == second->me);
}

- (void)assertEqualIdentityDicts:(NSDictionary *)first
                          second:(NSDictionary *)second
                      shouldFail:(BOOL)shouldFail
{
    if (shouldFail) {
        XCTAssertNotEqualObjects(first[kPepAddress], second[kPepAddress]);
        XCTAssertNotEqualObjects(first[kPepFingerprint], second[kPepFingerprint]);
        XCTAssertNotEqualObjects(first[kPepUserID], second[kPepUserID]);
        XCTAssertNotEqualObjects(first[kPepUsername], second[kPepUsername]);
        XCTAssertNotEqualObjects(first[kPepCommType], second[kPepCommType]);
        XCTAssertNotEqualObjects(first[kPepIsOwn], second[kPepIsOwn]);
    } else {
        XCTAssertEqualObjects(first[kPepAddress], second[kPepAddress]);
        XCTAssertEqualObjects(first[kPepFingerprint], second[kPepFingerprint]);
        XCTAssertEqualObjects(first[kPepUserID], second[kPepUserID]);
        XCTAssertEqualObjects(first[kPepUsername], second[kPepUsername]);
        XCTAssertEqualObjects(first[kPepCommType], second[kPepCommType]);
        XCTAssertEqualObjects(first[kPepIsOwn], second[kPepIsOwn]);
    }
}

#pragma mark test the helpers

- (void)testdiffernetIdentityStructsFail
{
    [self assertEqualIdentityStructs:self.pepIdentityMe second:self.pepIdentitySomeOne shouldFail:YES];
}

- (void)testEqualIdentityStructsSucceed
{
    [self assertEqualIdentityStructs:self.pepIdentityMe second:self.pepIdentityMe shouldFail:NO];
}

- (void)testdiffernetIdentityDicsFail
{
    [self assertEqualIdentityDicts:self.dictMe second:self.dictSomeOne shouldFail:YES];
}

- (void)testEqualIdentityDictsSucceed
{
    [self assertEqualIdentityDicts:self.dictMe second:self.dictMe shouldFail:NO];
}

@end
