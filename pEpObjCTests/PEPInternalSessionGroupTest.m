//
//  PEPInternalSessionGroupTest.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 08.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPObjCAdapterTypes_iOS.h"
#import "PEPObjCAdapter_iOS.h"

#import "PEPSessionProvider.h"
#import "PEPInternalSession.h"
#import "PEPTestUtils.h"

@interface PEPInternalSessionGroupTest : XCTestCase

@end

@implementation PEPInternalSessionGroupTest

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
    PEPInternalSession *session = [PEPSessionProvider session];

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
        XCTAssertTrue([session mySelf:ident error:&error]);
        XCTAssertNil(error);
    }

    for (PEPIdentity *ident in @[identityManager, identityMember1]) {
        error = nil;
        XCTAssertTrue([session updateIdentity:ident error:&error]);
        XCTAssertNil(error);
    }

    error = nil;

    PEPGroup *group = [session groupCreateGroupIdentity:identityGroup
                                        managerIdentity:identityManager
                                       memberIdentities:@[identityMember1]
                                                  error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);

    XCTAssertNotNil(group);
}

- (void)testGroupJoinNoMember
{
    PEPInternalSession *session = [PEPSessionProvider session];

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
        XCTAssertTrue([session mySelf:ident error:&error]);
        XCTAssertNil(error);
    }

    for (PEPIdentity *ident in @[identityManager, identityMember1]) {
        error = nil;
        XCTAssertTrue([session updateIdentity:ident error:&error]);
        XCTAssertNil(error);
    }

    error = nil;

    PEPGroup *group = [session groupCreateGroupIdentity:identityGroup
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
    XCTAssertTrue([session mySelf:identityMember2 error:&error]);
    XCTAssertNil(error);

    XCTAssertFalse([session groupJoinGroupIdentity:identityGroup
                                    memberIdentity:identityMember2
                                             error:&error]);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, PEP_NO_MEMBERSHIP_STATUS_FOUND);
}

- (void)testGroupDissolve
{
    PEPInternalSession *session = [PEPSessionProvider session];

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
        XCTAssertTrue([session mySelf:ident error:&error]);
        XCTAssertNil(error);
    }

    for (PEPIdentity *ident in @[identityManager, identityMember1]) {
        error = nil;
        XCTAssertTrue([session updateIdentity:ident error:&error]);
        XCTAssertNil(error);
    }

    error = nil;

    PEPGroup *group = [session groupCreateGroupIdentity:identityGroup
                                        managerIdentity:identityManager
                                       memberIdentities:@[identityMember1]
                                                  error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);

    XCTAssertNotNil(group);

    error = nil;

    XCTAssertTrue([session groupDissolveGroupIdentity:identityGroup
                                      managerIdentity:identityManager
                                                error:&error]);
    XCTAssertNil(error);
}

- (void)testGroupInviteMemberNoTrust
{
    PEPInternalSession *session = [PEPSessionProvider session];

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
        XCTAssertTrue([session mySelf:ident error:&error]);
        XCTAssertNil(error);
    }

    for (PEPIdentity *ident in @[identityManager, identityMember1]) {
        error = nil;
        XCTAssertTrue([session updateIdentity:ident error:&error]);
        XCTAssertNil(error);
    }

    error = nil;

    PEPGroup *group = [session groupCreateGroupIdentity:identityGroup
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
    XCTAssertTrue([session mySelf:identityMember2 error:&error]);
    XCTAssertNil(error);

    XCTAssertFalse([session groupInviteMemberGroupIdentity:identityGroup
                                            memberIdentity:identityMember2
                                                     error:&error]);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, PEP_NO_TRUST);
}

- (void)testGroupRemoveMember
{
    PEPInternalSession *session = [PEPSessionProvider session];

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
        XCTAssertTrue([session mySelf:ident error:&error]);
        XCTAssertNil(error);
    }

    for (PEPIdentity *ident in @[identityManager, identityMember1]) {
        error = nil;
        XCTAssertTrue([session updateIdentity:ident error:&error]);
        XCTAssertNil(error);
    }

    error = nil;

    PEPGroup *group = [session groupCreateGroupIdentity:identityGroup
                                        managerIdentity:identityManager
                                       memberIdentities:@[identityMember1]
                                                  error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);

    XCTAssertNotNil(group);

    error = nil;
    XCTAssertTrue([session groupRemoveMemberGroupIdentity:identityGroup
                                           memberIdentity:identityMember1
                                                    error:&error]);
    XCTAssertNil(error);
}

- (void)testGroupRating
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identityGroup = [[PEPIdentity alloc]
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

    for (PEPIdentity *ident in @[identityGroup]) {
        error = nil;
        XCTAssertTrue([session mySelf:ident error:&error]);
        XCTAssertNil(error);
    }

    for (PEPIdentity *ident in @[identyManager, identityMember1]) {
        error = nil;
        XCTAssertTrue([session updateIdentity:ident error:&error]);
        XCTAssertNil(error);
    }

    error = nil;

    PEPGroup *group = [session groupCreateGroupIdentity:identityGroup
                                        managerIdentity:identyManager
                                       memberIdentities:@[identityMember1]
                                                  error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);

    XCTAssertNotNil(group);

    error = nil;
    NSNumber *ratingNumber = [session groupRatingGroupIdentity:identityGroup
                                               managerIdentity:identyManager
                                                         error:&error];
    XCTAssertNotNil(ratingNumber);
    XCTAssertNil(error);
}

@end
