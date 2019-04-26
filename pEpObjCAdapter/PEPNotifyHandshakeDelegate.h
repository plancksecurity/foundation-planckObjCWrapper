//
//  PEPNotifyHandshakeDelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 05.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "sync_api.h"

@class PEPIdentity;

@protocol PEPNotifyHandshakeDelegate <NSObject>

- (PEP_STATUS)notifyHandshake:(void * _Nullable)object
                           me:(PEPIdentity * _Nonnull)me
                      partner:(PEPIdentity * _Nonnull)partner
                       signal:(sync_handshake_signal)signal;

@end
