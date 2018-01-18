//
//  PEPSyncTest.m
//  pEpObjCAdapterTests
//
//  Created by Andreas Buff on 17.01.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPIdentity.h"
#import "PEPObjCAdapter.h"

// Commented. See testSyncSession
// MARK: - PEPSyncDelegate

@interface SomeSyncDelegate : NSObject<PEPSyncDelegate>

- (BOOL)waitUntilSent:(time_t)maxSec;

@property (nonatomic) bool sendWasCalled;
@property (nonatomic, strong) NSCondition *cond;

@end

@implementation SomeSyncDelegate

//- (id)init
//{
//    if (self = [super init])  {
//        self.sendWasCalled = false;
//        self.cond = [[NSCondition alloc] init];
//    }
//    return self;
//}
//
//- (PEP_STATUS)notifyHandshakeWithSignal:(sync_handshake_signal)signal me:(id)me
//                                partner:(id)partner
//{
//    return PEP_STATUS_OK;
//}
//
//- (PEP_STATUS)sendMessage:(id)msg //never used afaics. Delete?
//{
//    [_cond lock];
//
//    self.sendWasCalled = true;
//    [_cond signal];
//    [_cond unlock];
//
//    return PEP_STATUS_OK;
//}
//
//- (PEP_STATUS)fastPolling:(bool)isfast
//{
//    return PEP_STATUS_OK;
//}
//
//- (BOOL)waitUntilSent:(time_t)maxSec
//{
//    bool res;
//    [_cond lock];
//    [_cond waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:maxSec]];
//    res = _sendWasCalled;
//    [_cond unlock];
//    return res;
//}
//
//@end
//
//@interface PEPSyncTest : XCTestCase
//
//@end
//
//@implementation PEPSyncTest
//
////BUFF: ?? commented due to: Can't currently work, engine doesn't contain sync.
//- (void)testSyncSession
//{
//    PEPSession *session = [PEPSession new];
//    SomeSyncDelegate *syncDelegate = [[SomeSyncDelegate alloc] init];
//    [self pEpSetUp];
//
//    // This should attach session just created
//    [PEPObjCAdapter startSync:syncDelegate];
//
//    PEPIdentity *identMe = [[PEPIdentity alloc]
//                            initWithAddress:@"pep.test.iosgenkey@pep-project.org"
//                            userID:@"Me"
//                            userName:@"pEp Test iOS GenKey"
//                            isOwn:YES];
//
//    [session mySelf:identMe];
//
//    bool res = [syncDelegate waitUntilSent:1];
//
//    // Can't currently work, engine doesn't contain sync.
//    XCTAssertFalse(res);
//
//    // This should detach session just created
//    [PEPObjCAdapter stopSync];
//
//    [self pEpCleanUp];
//}
//}

@end
