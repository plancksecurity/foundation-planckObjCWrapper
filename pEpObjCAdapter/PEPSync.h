//
//  PEPSync.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "pEpEngine.h"

@class PEPSyncSendMessageDelegate, PEPNotifyHandshakeDelegate;

PEP_STATUS messageToSendObjc(struct _message *msg);
int inject_sync_eventObjc(SYNC_EVENT ev, void *management);

@class PEPSyncSendMessageDelegate;

/**
 @see libpEpAdapter: Adapter.{cc|hh}
 @see sync_codec.h
 */
@interface PEPSync : NSObject

- (instancetype)initWithSyncSendMessageDelegate:(PEPSyncSendMessageDelegate *
                                                 _Nonnull)syncSendMessageDelegate
                        notifyHandshakeDelegate:(PEPNotifyHandshakeDelegate *
                                                 _Nonnull)notifyHandshakeDelegate;

@end
