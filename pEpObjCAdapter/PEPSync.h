//
//  PEPSync.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "pEpEngine.h"

#import "PEPSendMessageDelegate.h"
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
+ (PEP_SESSION _Nullable)createSession:(NSError * _Nullable * _Nullable)error;

/**
 Releases an engine session that was created by `createSession`.
 */
+ (void)releaseSession:(PEP_SESSION _Nullable)session;

- (instancetype _Nonnull)initWithSendMessageDelegate:(id <PEPSendMessageDelegate>
                                                      _Nonnull)sendMessageDelegate
                             notifyHandshakeDelegate:(id<PEPNotifyHandshakeDelegate>
                                                      _Nonnull)notifyHandshakeDelegate;

- (void)startup;

- (void)shutdown;

@end
