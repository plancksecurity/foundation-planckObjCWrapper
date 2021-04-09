//
//  PEPSessionGroupTest.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 09.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "XCTestCase+PEPSession.h"
#import "PEPTestUtils.h"
#import "PEPObjCAdapter_iOS.h"

@interface PEPSessionGroupTest : XCTestCase

@end

@implementation PEPSessionGroupTest

- (void)setUp
{
    [super setUp];
    [self pEpCleanUp];
}

- (void)tearDown
{
    [self pEpCleanUp];
    [super tearDown];
}

- (void)pEpCleanUp
{
    [PEPTestUtils cleanUp];
}

#pragma mark - Group API

- (void)testGroupCreate
{
    PEPIdentity *identyGroup = [[PEPIdentity alloc]
                                initWithAddress:@"group@pep.security"
                                userID:@"group"
                                userName:@"group"
                                isOwn:YES];

    PEPIdentity *identyManager = [[PEPIdentity alloc]
                                  initWithAddress:@"manager@pep.security"
                                  userID:@"manager"
                                  userName:@"manager"
                                  isOwn:NO];

    PEPIdentity *identityMember1 = [[PEPIdentity alloc]
                                    initWithAddress:@"member1@pep.security"
                                    userID:@"member1"
                                    userName:@"member1"
                                    isOwn:NO];

    NSError *error = nil;

    for (PEPIdentity *ident in @[identyGroup]) {
        error = nil;
        XCTAssertTrue([self mySelf:ident error:&error]);
        XCTAssertNil(error);
    }

    for (PEPIdentity *ident in @[identyManager, identityMember1]) {
        error = nil;
        XCTAssertTrue([self updateIdentity:ident error:&error]);
        XCTAssertNil(error);
    }

    error = nil;

    PEPGroup *group = [self groupCreateGroupIdentity:identyGroup
                                             manager:identyManager
                                             members:@[identityMember1]
                                               error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);

    XCTAssertNotNil(group);
}

@end
