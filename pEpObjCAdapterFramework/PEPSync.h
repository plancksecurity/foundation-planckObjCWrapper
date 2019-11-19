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
 Manages the key-sync loop.
 */
@interface PEPSync : NSObject

/// Is the sync loop running?
@property (nonatomic) BOOL isRunning;

@property (nonatomic, nullable, weak) id<PEPSendMessageDelegate> sendMessageDelegate;
@property (nonatomic, nullable, weak) id<PEPNotifyHandshakeDelegate> notifyHandshakeDelegate;

/**
 Manages the key-sync loop, and other key-sync related elements.

 @note This object should only exist once per app.

 @param sendMessageDelegate Will be called on behalf of the engine for outgoing messages,
                            needed e.g. in case of key rest, or for key-sync.
 @param notifyHandshakeDelegate Called whever there is a key-sync related information that
                                should be displayed to the user.
 @return The object that binds the delegates given in the constructor and can be used to control
         the key-sync loop.
 */
- (instancetype _Nonnull)initWithSendMessageDelegate:(id <PEPSendMessageDelegate>
                                                      _Nullable)sendMessageDelegate
                             notifyHandshakeDelegate:(id<PEPNotifyHandshakeDelegate>
                                                      _Nullable)notifyHandshakeDelegate;

/**
 Start the key-sync loop in its own, separate thread.
 */
- (void)startup;

/**
 Shuts the key-sync loop down.
 */
- (void)shutdown;

@end
