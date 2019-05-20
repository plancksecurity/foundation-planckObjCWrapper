//
//  PEPSessionTestNotifyHandshakeDelegate.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 29.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPSessionTestNotifyHandshakeDelegate.h"

@implementation PEPSessionTestNotifyHandshakeDelegate

- (PEPStatus)notifyHandshake:(void * _Nullable)object me:(PEPIdentity * _Nonnull)me
                     partner:(PEPIdentity * _Nonnull)partner signal:(PEPSyncHandshakeResult)signal
{
    return PEPStatusOK;
}

@end
