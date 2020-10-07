//
//  PEPInternalSessionTestNotifyHandshakeDelegate.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 29.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPInternalSessionTestNotifyHandshakeDelegate.h"

@implementation PEPInternalSessionTestNotifyHandshakeDelegate

- (PEPStatus)notifyHandshake:(void * _Nullable)object
                          me:(PEPIdentity * _Nonnull)me
                     partner:(PEPIdentity * _Nullable)partner
                      signal:(PEPSyncHandshakeSignal)signal
{
    if (partner == nil && signal == PEPSyncHandshakeSignalPassphraseRequired) {
        self.notifyHandshakePassphraseRequired = YES;
    }

    return PEPStatusOK;
}

- (void)engineShutdownKeySync
{
    self.engineDidShutdownKeySync = YES;
}

@end
