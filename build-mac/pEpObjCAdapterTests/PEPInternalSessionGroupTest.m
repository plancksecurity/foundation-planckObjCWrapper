//
//  PEPInternalSessionGroupTest.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 08.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

@import PEPObjCAdapter;

#import "PEPSessionProvider.h"
#import "PEPInternalSession.h"
#import "PEPTestUtils.h"

#import "XCTestCase+PEPSession.h"

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

- (void)testGroupCreateFail
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identityGroup = [[PEPIdentity alloc]
                                  initWithAddress:@"group@planck.security"
                                  userID:@"group"
                                  userName:@"group"
                                  isOwn:YES];

    PEPIdentity *identityManager = [[PEPIdentity alloc]
                                    initWithAddress:@"manager@planck.security"
                                    userID:@"manager"
                                    userName:@"manager"
                                    isOwn:NO];

    PEPIdentity *identityMember1 = [[PEPIdentity alloc]
                                    initWithAddress:@"member1@planck.security"
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

    XCTAssertNil(group);
    XCTAssertEqual(error.code, PEP_CANNOT_ADD_GROUP_MEMBER);

}

- (void)testGroupCreate
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identityGroup = [self
                                  checkMySelfImportingKeyFilePath:@"Six Replicants on the Run (55F4F533) – Secreta.asc"
                                  address:@"replicants@planck.security"
                                  userID:@"replicants"
                                  fingerPrint:@"5047 9D55 150B 788A 9798  0104 D0E6 EA77 55F4 F533"
                                  session:session];
    XCTAssertNotNil(identityGroup);

    PEPIdentity *identityManager = [self
                                  checkMySelfImportingKeyFilePath:@"Harry Bryant (76BAD98F) – Secreta.asc"
                                  address:@"bryant@planck.security"
                                  userID:@"bryant"
                                  fingerPrint:@"027C C235 A7C1 0EC3 5CB5  9DE6 3DE8 EBB3 76BA D98F"
                                  session:session];
    XCTAssertNotNil(identityManager);

    PEPIdentity *identityMember1 = [self
                                    checkImportingKeyFilePath:@"Rickard Deckard (C92BF6F7) – Pública.asc"
                                    address:@"deckard@planck.security"
                                    userID:@"deckard"
                                    fingerPrint:@"04F9 58A9 ECAB 1097 6F28  E0C9 8100 4C00 C92B F6F7"
                                    session:session];
    XCTAssertNotNil(identityMember1);

    NSError *error = nil;
    PEPGroup *group = [session groupCreateGroupIdentity:identityGroup
                                        managerIdentity:identityManager
                                       memberIdentities:@[identityMember1]
                                                  error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);
}

- (void)testGroupJoinNoMember
{
    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identityGroup = [[PEPIdentity alloc]
                                  initWithAddress:@"group@planck.security"
                                  userID:@"group"
                                  userName:@"group"
                                  isOwn:YES];

    PEPIdentity *identityManager = [[PEPIdentity alloc]
                                    initWithAddress:@"manager@planck.security"
                                    userID:@"manager"
                                    userName:@"manager"
                                    isOwn:NO];

    PEPIdentity *identityMember1 = [[PEPIdentity alloc]
                                    initWithAddress:@"member1@planck.security"
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
                                    initWithAddress:@"member2@planck.security"
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
                                  initWithAddress:@"group@planck.security"
                                  userID:@"group"
                                  userName:@"group"
                                  isOwn:YES];

    PEPIdentity *identityManager = [[PEPIdentity alloc]
                                    initWithAddress:@"manager@planck.security"
                                    userID:@"manager"
                                    userName:@"manager"
                                    isOwn:NO];

    PEPIdentity *identityMember1 = [[PEPIdentity alloc]
                                    initWithAddress:@"member1@planck.security"
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
                                  initWithAddress:@"group@planck.security"
                                  userID:@"group"
                                  userName:@"group"
                                  isOwn:YES];

    PEPIdentity *identityManager = [[PEPIdentity alloc]
                                    initWithAddress:@"manager@planck.security"
                                    userID:@"manager"
                                    userName:@"manager"
                                    isOwn:NO];

    PEPIdentity *identityMember1 = [[PEPIdentity alloc]
                                    initWithAddress:@"member1@planck.security"
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
                                    initWithAddress:@"member2@planck.security"
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
                                  initWithAddress:@"group@planck.security"
                                  userID:@"group"
                                  userName:@"group"
                                  isOwn:YES];

    PEPIdentity *identityManager = [[PEPIdentity alloc]
                                    initWithAddress:@"manager@planck.security"
                                    userID:@"manager"
                                    userName:@"manager"
                                    isOwn:NO];

    PEPIdentity *identityMember1 = [[PEPIdentity alloc]
                                    initWithAddress:@"member1@planck.security"
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
                                  initWithAddress:@"group@planck.security"
                                  userID:@"group"
                                  userName:@"group"
                                  isOwn:YES];

    PEPIdentity *identityManager = [[PEPIdentity alloc]
                                    initWithAddress:@"manager@planck.security"
                                    userID:@"manager"
                                    userName:@"manager"
                                    isOwn:NO];

    PEPIdentity *identityMember1 = [[PEPIdentity alloc]
                                    initWithAddress:@"member1@planck.security"
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
    NSNumber *ratingNumber = [session groupRatingGroupIdentity:identityGroup
                                               managerIdentity:identityManager
                                                         error:&error];
    XCTAssertNotNil(ratingNumber);
    XCTAssertNil(error);
}

@end
