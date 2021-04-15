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
#import "XCTestCase+PEPSession.h"

#import "pEpEngine.h"

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
    PEPIdentity *identityGroup = [[PEPIdentity alloc]
                                  initWithAddress:@"group@pep.security"
                                  userID:@"group"
                                  userName:@"group"
                                  isOwn:YES];

    PEPIdentity *identityManager = [[PEPIdentity alloc]
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

    for (PEPIdentity *ident in @[identityGroup]) {
        error = nil;
        XCTAssertTrue([self mySelf:ident error:&error]);
        XCTAssertNil(error);
    }

    for (PEPIdentity *ident in @[identityManager, identityMember1]) {
        error = nil;
        XCTAssertTrue([self updateIdentity:ident error:&error]);
        XCTAssertNil(error);
    }

    error = nil;

    PEPGroup *group = [self groupCreateGroupIdentity:identityGroup
                                     managerIdentity:identityManager
                                    memberIdentities:@[identityMember1]
                                               error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);

    XCTAssertNotNil(group);
}

- (void)testGroupJoinNoMember
{
    PEPIdentity *identityGroup = [[PEPIdentity alloc]
                                  initWithAddress:@"group@pep.security"
                                  userID:@"group"
                                  userName:@"group"
                                  isOwn:YES];

    PEPIdentity *identityManager = [[PEPIdentity alloc]
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

    for (PEPIdentity *ident in @[identityGroup]) {
        error = nil;
        XCTAssertTrue([self mySelf:ident error:&error]);
        XCTAssertNil(error);
    }

    for (PEPIdentity *ident in @[identityManager, identityMember1]) {
        error = nil;
        XCTAssertTrue([self updateIdentity:ident error:&error]);
        XCTAssertNil(error);
    }

    error = nil;

    PEPGroup *group = [self groupCreateGroupIdentity:identityGroup
                                     managerIdentity:identityManager
                                    memberIdentities:@[identityMember1]
                                               error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);

    XCTAssertNotNil(group);

    PEPIdentity *identityMember2 = [[PEPIdentity alloc]
                                    initWithAddress:@"member2@pep.security"
                                    userID:@"member2"
                                    userName:@"member2"
                                    isOwn:YES];


    error = nil;
    XCTAssertTrue([self mySelf:identityMember2 error:&error]);
    XCTAssertNil(error);

    XCTAssertFalse([self groupJoinGroupIdentity:identityGroup
                                 memberIdentity:identityMember2
                                          error:&error]);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, PEP_NO_MEMBERSHIP_STATUS_FOUND);
}

- (void)testGroupDissolve
{
    PEPIdentity *identityGroup = [[PEPIdentity alloc]
                                  initWithAddress:@"group@pep.security"
                                  userID:@"group"
                                  userName:@"group"
                                  isOwn:YES];

    PEPIdentity *identityManager = [[PEPIdentity alloc]
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

    for (PEPIdentity *ident in @[identityGroup]) {
        error = nil;
        XCTAssertTrue([self mySelf:ident error:&error]);
        XCTAssertNil(error);
    }

    for (PEPIdentity *ident in @[identityManager, identityMember1]) {
        error = nil;
        XCTAssertTrue([self updateIdentity:ident error:&error]);
        XCTAssertNil(error);
    }

    error = nil;

    PEPGroup *group = [self groupCreateGroupIdentity:identityGroup
                                     managerIdentity:identityManager
                                    memberIdentities:@[identityMember1]
                                               error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);

    XCTAssertNotNil(group);

    error = nil;

    XCTAssertTrue([self groupDissolveGroupIdentity:identityGroup
                                   managerIdentity:identityManager
                                             error:&error]);
    XCTAssertNil(error);
}

- (void)testGroupInviteMemberNoTrust
{
    PEPIdentity *identityGroup = [[PEPIdentity alloc]
                                  initWithAddress:@"group@pep.security"
                                  userID:@"group"
                                  userName:@"group"
                                  isOwn:YES];

    PEPIdentity *identityManager = [[PEPIdentity alloc]
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

    for (PEPIdentity *ident in @[identityGroup]) {
        error = nil;
        XCTAssertTrue([self mySelf:ident error:&error]);
        XCTAssertNil(error);
    }

    for (PEPIdentity *ident in @[identityManager, identityMember1]) {
        error = nil;
        XCTAssertTrue([self updateIdentity:ident error:&error]);
        XCTAssertNil(error);
    }

    error = nil;

    PEPGroup *group = [self groupCreateGroupIdentity:identityGroup
                                     managerIdentity:identityManager
                                    memberIdentities:@[identityMember1]
                                               error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);

    XCTAssertNotNil(group);

    PEPIdentity *identityMember2 = [[PEPIdentity alloc]
                                    initWithAddress:@"member2@pep.security"
                                    userID:@"member2"
                                    userName:@"member2"
                                    isOwn:YES];


    error = nil;
    identityMember2 = [self mySelf:identityMember2 error:&error];
    XCTAssertNotNil(identityMember2);
    XCTAssertNil(error);

    XCTAssertFalse([self groupInviteMemberGroupIdentity:identityGroup
                                         memberIdentity:identityMember2
                                                  error:&error]);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, PEP_NO_TRUST);
}

- (void)testGroupRemoveMember
{
    PEPIdentity *identityGroup = [[PEPIdentity alloc]
                                  initWithAddress:@"group@pep.security"
                                  userID:@"group"
                                  userName:@"group"
                                  isOwn:YES];

    PEPIdentity *identityManager = [[PEPIdentity alloc]
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

    identityGroup = [self mySelf:identityGroup error:&error];
    XCTAssertNotNil(identityGroup);
    XCTAssertNil(error);

    error = nil;
    identityManager = [self updateIdentity:identityManager error:&error];
    XCTAssertNotNil(identityManager);
    XCTAssertNil(error);

    error = nil;
    identityMember1 = [self updateIdentity:identityMember1 error:&error];
    XCTAssertNotNil(identityMember1);
    XCTAssertNil(error);

    error = nil;

    PEPGroup *group = [self groupCreateGroupIdentity:identityGroup
                                     managerIdentity:identityManager
                                    memberIdentities:@[identityMember1]
                                               error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);

    XCTAssertNotNil(group);

    error = nil;
    XCTAssertTrue([self groupRemoveMemberGroupIdentity:identityGroup
                                        memberIdentity:identityMember1
                                                 error:&error]);
    XCTAssertNil(error);
}

- (void)testGroupRating
{
    PEPIdentity *identityGroup = [[PEPIdentity alloc]
                                  initWithAddress:@"group@pep.security"
                                  userID:@"group"
                                  userName:@"group"
                                  isOwn:YES];

    PEPIdentity *identityManager = [[PEPIdentity alloc]
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

    identityGroup = [self mySelf:identityGroup error:&error];
    XCTAssertNotNil(identityGroup);
    XCTAssertNil(error);

    identityManager = [self updateIdentity:identityManager error:&error];
    XCTAssertNotNil(identityManager);
    XCTAssertNil(error);

    for (PEPIdentity *ident in @[identityMember1]) {
        error = nil;
        XCTAssertTrue([self updateIdentity:ident error:&error]);
        XCTAssertNil(error);
    }

    error = nil;

    PEPGroup *group = [self groupCreateGroupIdentity:identityGroup
                                     managerIdentity:identityManager
                                    memberIdentities:@[identityMember1]
                                               error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);

    XCTAssertNotNil(group);

    error = nil;
    NSNumber *ratingNumber = [self groupRatingGroupIdentity:identityGroup
                                            managerIdentity:identityManager
                                                      error:&error];
    XCTAssertNotNil(ratingNumber);
    XCTAssertNil(error);
}

@end
