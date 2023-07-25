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
#import "PEPInternalSessionTestSendMessageDelegate.h"

@interface PEPInternalSessionGroupTest : XCTestCase

@property (nonatomic) PEPSync *sync;
@property (nonatomic) PEPInternalSessionTestSendMessageDelegate *sendMessageDelegate;

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

#pragma mark - Key Sync Helper

- (void)startKeySync
{
    self.sendMessageDelegate = [PEPInternalSessionTestSendMessageDelegate new];
    self.sync = [[PEPSync alloc]
                 initWithSendMessageDelegate:self.sendMessageDelegate
                 notifyHandshakeDelegate:nil];
}

#pragma mark - Group API

- (void)testGroupCreate
{
    [self startKeySync];

    PEPInternalSession *session = [PEPSessionProvider session];

    PEPIdentity *identityManager = [self
                                  checkMySelfImportingKeyFilePath:@"Harry Bryant (76BAD98F) – Secret.asc"
                                  address:@"bryant@planck.security"
                                  fingerPrint:@"027C C235 A7C1 0EC3 5CB5  9DE6 3DE8 EBB3 76BA D98F"
                                  session:session];
    XCTAssertNotNil(identityManager);

    PEPIdentity *identityGroup = [self
                                  checkImportingKeyFilePath:@"Six Replicants on the Run (55F4F533) – Public.asc"
                                  address:@"replicants@planck.security"
                                  userID:@"replicants"
                                  fingerPrint:@"5047 9D55 150B 788A 9798  0104 D0E6 EA77 55F4 F533"
                                  session:session];
    XCTAssertNotNil(identityGroup);

    PEPIdentity *identityMember1 = [self
                                    checkImportingKeyFilePath:@"Rickard Deckard (C92BF6F7) – Public.asc"
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

@end
