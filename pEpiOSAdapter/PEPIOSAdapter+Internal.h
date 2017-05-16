//
//  PEPIOSAdapter+Internal.h
//  pEpiOSAdapter
//
//  Created by Edouard Tisserant on 11/11/15.
//  Copyright © 2015 p≡p. All rights reserved.
//

#ifndef PEPIOSAdapter_Internal_h
#define PEPIOSAdapter_Internal_h

#import "sync.h"

#import "PEPQueue.h"

@interface PEPiOSAdapter ()

// this messages are for internal use only; do not call

+ (void)registerExamineFunction:(PEP_SESSION)session;
+ (PEPQueue*)getLookupQueue;

+ (PEPQueue*)getSyncQueue;
+ (id <PEPSyncDelegate>)getSyncDelegate;
+ (PEP_SESSION)getSyncSession;

@end

#endif /* PEPIOSAdapter_Internal_h */
