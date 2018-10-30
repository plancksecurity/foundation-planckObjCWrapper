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

typedef PEP_STATUS (* t_messageToSendCallback)(struct _message *msg);
typedef int (* t_injectSyncCallback)(SYNC_EVENT ev, void *management);

@class PEPSyncSendMessageDelegate;

/**
 @see libpEpAdapter: Adapter.{cc|hh}
 @see sync_codec.h
 */
@interface PEPSync : NSObject

/**
 @Return: The callback for message sending that should be used on every session init.
 */
+ (t_messageToSendCallback)messageToSendCallback;

/**
 @Return: The callback for injectiong sync messages that should be used on every session init.
 */
+ (t_injectSyncCallback)injectSyncCallback;

- (instancetype)initWithSyncSendMessageDelegate:(id<PEPSyncSendMessageDelegate>
                                                 _Nonnull)syncSendMessageDelegate
                        notifyHandshakeDelegate:(id<PEPNotifyHandshakeDelegate>
                                                 _Nonnull)notifyHandshakeDelegate;

- (void)startup;

- (void)shutdown;

@end
