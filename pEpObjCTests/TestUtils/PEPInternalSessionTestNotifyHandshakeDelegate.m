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
                          me:(PEPIdentity * _Nullable)me
                     partner:(PEPIdentity * _Nullable)partner
                      signal:(PEPSyncHandshakeSignal)signal
{
    if (partner == nil && signal == PEPSyncHandshakeSignalPassphraseRequired) {
        self.notifyHandshakePassphraseRequired = YES;
    } else if (signal == PEPSyncHandshakeSignalStop) {
        self.engineDidShutdownKeySync = YES;
    }

    return PEPStatusOK;
}

@end
