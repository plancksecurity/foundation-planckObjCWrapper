//
//  PEPIOSAdapter+Internal.h
//  pEpiOSAdapter
//
//  Created by Edouard Tisserant on 11/11/15.
//  Copyright © 2015 p≡p. All rights reserved.
//

#ifndef PEPIOSAdapter_Internal_h
#define PEPIOSAdapter_Internal_h

#import "PEPQueue.h"
#import "PEPInternalSession.h"

@interface PEPObjCAdapter ()

/**
 The lock that should be used for locking all session init() and release().
 */
+ (NSLock *)initLock;

// this messages are for internal use only; do not call

+ (void)registerExamineFunction:(PEP_SESSION)session;
+ (PEPQueue*)getLookupQueue;

@end

#endif /* PEPIOSAdapter_Internal_h */
