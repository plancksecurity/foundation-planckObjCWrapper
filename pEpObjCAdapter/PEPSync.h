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

@class PEPSyncSendMessageDelegate;

/**
 @see libpEpAdapter: Adapter.{cc|hh}
 @see sync_codec.h
 */
@interface PEPSync : NSObject

/**
 Creates an engine session.
 */
+ (PEP_SESSION)createSession:(NSError **)error;

/**
 Releases an engine session that was created by `createSession`.
 */
+ (void)releaseSession:(PEP_SESSION)session;

- (instancetype)initWithSyncSendMessageDelegate:(id<PEPSyncSendMessageDelegate>
                                                 _Nonnull)syncSendMessageDelegate
                        notifyHandshakeDelegate:(id<PEPNotifyHandshakeDelegate>
                                                 _Nonnull)notifyHandshakeDelegate;

- (void)startup;

- (void)shutdown;

@end
