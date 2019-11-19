//
//  PEPSync_Internal.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 20.05.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#ifndef PEPSync_Internal_h
#define PEPSync_Internal_h

#import "pEpEngine.h"

/// Is pEp sync running or not?
extern BOOL g_isKeySyncEnabled;

/**
 Internal methods of PEPSync.
 */
@interface PEPSync()

/**
 Creates an engine session (PEP_SESSION).

 PEPSync is responsible for engine session creation because the engine
 has mandatory callback parameters on its init, which PEPSync is managing.

 @param error The usual cocoa error handling.
 @return A valid engine PEP_SESSION or NULL if there was an error.
 */
+ (PEP_SESSION _Nullable)createSession:(NSError * _Nullable * _Nullable)error;

@property (nonatomic) BOOL isRunning;

@end

#endif /* PEPSync_Internal_h */
