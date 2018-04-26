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
#import "PEPInternalSession.h"

@interface PEPObjCAdapter ()

/**
 unecryptedSubjectEnabled value to use for all sessions created.

 @return Whether or not mail subjects should be encrypted
 */
+ (BOOL)unEncryptedSubjectEnabled;

// this messages are for internal use only; do not call

+ (void)registerExamineFunction:(PEP_SESSION)session;
+ (PEPQueue*)getLookupQueue;

+ (PEPQueue*)getSyncQueue;
+ (id <PEPSyncDelegate>)getSyncDelegate;
+ (void)bindSession:(PEPInternalSession*)session;
+ (void)unbindSession:(PEPInternalSession*)session;

/**
 Locks for (potential) sqlite writes.
 */
+ (void)lockWrite;

/**
 Unlocks (potential) sqlite writes.
 */
+ (void)unlockWrite;

@end

#endif /* PEPIOSAdapter_Internal_h */
