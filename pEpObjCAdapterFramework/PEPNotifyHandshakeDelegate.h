//
//  PEPNotifyHandshakeDelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 05.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PEPObjCAdapterFramework/PEPEngineTypes.h>

@class PEPIdentity;

/**
 Handles notifications from the engine to the app that involve UI.
 */
@protocol PEPNotifyHandshakeDelegate <NSObject>

/// Requests the app to show a handshake dialog, or change the icon that represents
/// the key-sync state (as in, grouped, or sole, etc.).
///
/// After the dialog has been shown, the user's choices can be communicated back to the engine
/// via [PEPSessionProtocol deliverHandshakeResult:identitiesSharing:error].
///
/// @param object This can be used to thread information from the app through the sync-loop back to
///   the app. Currently unused and always nil.
/// @param me The own identity.
///   Note that in some cases, only the most essential properties are set.
/// @param partner The partner identity.
///   Note that in some cases, only the most essential properties are set, or it
///   can be nil in the case of PEPSyncHandshakeSignalPassphraseRequired.
/// @param signal The kind of action that is happening or requested.
/// @return A status indicating errors in the immediate/synchronous handling of the call.
///   The (delayed) response from the user are communicated to the engine
///   via separate method calls, as noted in the discussion.
- (PEPStatus)notifyHandshake:(void * _Nullable)object
                          me:(PEPIdentity * _Nonnull)me
                     partner:(PEPIdentity * _Nullable)partner
                      signal:(PEPSyncHandshakeSignal)signal;

/// Sent when the sync loop was shut down by the engine,
/// e.g. in response to leving the device group
- (void)engineShutdownKeySync;

@end
