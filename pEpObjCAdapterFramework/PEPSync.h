//
//  PEPSync.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPSendMessageDelegate.h"
#import "PEPNotifyHandshakeDelegate.h"

@class PEPSyncSendMessageDelegate;

/**
 @see libpEpAdapter: Adapter.{cc|hh}
 @see sync_codec.h
 */
@interface PEPSync : NSObject

- (instancetype _Nonnull)initWithSendMessageDelegate:(id <PEPSendMessageDelegate>
                                                      _Nonnull)sendMessageDelegate
                             notifyHandshakeDelegate:(id<PEPNotifyHandshakeDelegate>
                                                      _Nonnull)notifyHandshakeDelegate;

- (void)startup;

- (void)shutdown;

@end
