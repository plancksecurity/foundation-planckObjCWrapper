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

    PEPIdentity *identityManager = [[PEPIdentity alloc]
                                    initWithAddress:@"bryant@planck.security"
                                    userID:@"bryant"
                                    userName:@"Harry Bryant (Group Manager)"
                                    isOwn:YES];
    NSError *error = nil;
    XCTAssertTrue([session mySelf:identityManager error:&error]);
    XCTAssertNil(error);

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

    PEPGroup *group = [session groupCreateGroupIdentity:identityGroup
                                        managerIdentity:identityManager
                                       memberIdentities:@[identityMember1]
                                                  error:&error];

    XCTAssertNotNil(group);
    XCTAssertNil(error);

    PEPMessage *messageReliable = [PEPMessage new];
    messageReliable.direction = PEPMsgDirectionOutgoing;
    messageReliable.from = identityManager;
    messageReliable.to = @[identityGroup];
    messageReliable.shortMessage = @"Reliable";

    error = nil;
    NSNumber *ratingNum = [session outgoingRatingForMessage:messageReliable error:&error];
    XCTAssertNotNil(ratingNum);
    XCTAssertNil(error);
    XCTAssertEqual([ratingNum pEpRating], PEPRatingReliable);

    PEPMessage *messageMixed = [PEPMessage new];
    messageMixed.direction = PEPMsgDirectionOutgoing;
    messageMixed.from = identityManager;
    messageMixed.to = @[identityGroup, identityManager];
    messageMixed.shortMessage = @"Also reliable";

    error = nil;
    NSNumber *ratingNumMixed = [session outgoingRatingForMessage:messageMixed error:&error];
    XCTAssertNotNil(ratingNumMixed);
    XCTAssertNil(error);
    XCTAssertEqual([ratingNumMixed pEpRating], PEPRatingReliable);
}

@end
