//
//  PEPSessionTestNotifyHandshakeDelegate.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 29.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPSessionTestNotifyHandshakeDelegate.h"

@implementation PEPSessionTestNotifyHandshakeDelegate

- (PEP_STATUS)nofifyHandshake:(void *)object me:(PEPIdentity * _Nonnull)me partner:(PEPIdentity * _Nonnull)partner signal:(sync_handshake_signal)signal {
    return PEP_STATUS_OK;
}

@end
