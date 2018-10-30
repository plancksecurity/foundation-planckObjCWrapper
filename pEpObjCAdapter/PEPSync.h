//
//  PEPSync.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "pEpEngine.h"

#import "PEPSyncSendMessageDelegate.h"
#import "PEPNotifyHandshakeDelegate.h"

PEP_STATUS messageToSendObjc(struct _message *msg);
int inject_sync_eventObjc(SYNC_EVENT ev, void *management);

@class PEPSyncSendMessageDelegate;

/**
 @see libpEpAdapter: Adapter.{cc|hh}
 @see sync_codec.h
 */
@interface PEPSync : NSObject

- (instancetype)initWithSyncSendMessageDelegate:(id<PEPSyncSendMessageDelegate>
                                                 _Nonnull)syncSendMessageDelegate
                        notifyHandshakeDelegate:(id<PEPNotifyHandshakeDelegate>
                                                 _Nonnull)notifyHandshakeDelegate;

- (void)startup;

- (void)shutdown;

@end
