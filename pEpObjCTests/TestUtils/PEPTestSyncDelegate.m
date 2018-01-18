//
//  PEPTestSyncDelegate.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 18.01.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPTestSyncDelegate.h"

@implementation PEPTestSyncDelegate

- (id)init
{
    if (self = [super init])  {
        self.sendWasCalled = false;
        self.cond = [[NSCondition alloc] init];
    }
    return self;
}

- (PEP_STATUS)notifyHandshakeWithSignal:(sync_handshake_signal)signal me:(id)me
partner:(id)partner
{
    return PEP_STATUS_OK;
}

- (PEP_STATUS)sendMessage:(id)msg
{
    [_cond lock];

    self.sendWasCalled = true;
    [_cond signal];
    [_cond unlock];

    return PEP_STATUS_OK;
}

- (PEP_STATUS)fastPolling:(bool)isfast
{
    return PEP_STATUS_OK;
}

- (BOOL)waitUntilSent:(time_t)maxSec
{
    bool res;
    [_cond lock];
    [_cond waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:maxSec]];
    res = _sendWasCalled;
    [_cond unlock];
    return res;
}

@end
