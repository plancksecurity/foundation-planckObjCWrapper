//
//  PEPSync_Internal.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 20.05.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#ifndef PEPSync_Internal_h
#define PEPSync_Internal_h

#import "PEPSync.h"

/**
 Internal methods of PEPSync.
 */
@interface PEPSync (Internal)

/**
 Creates an engine session (PEP_SESSION).

 PEPSync is responsible for engine session creation because the engine
 has mandatory callback parameters on its init, which PEPSync is managing.

 @param error The usual cocoa error handling.
 @return A valid engine PEP_SESSION or NULL if there was an error.
 */
+ (PEP_SESSION _Nullable)createSession:(NSError * _Nullable * _Nullable)error;

/// The one and only sync instance, or nil, if none exists.
+ (PEPSync * _Nullable)sharedInstance;

/// MUST be called whenever a passphrase is configured
- (void)handleNewPassphraseConfigured;

@end

#endif /* PEPSync_Internal_h */
