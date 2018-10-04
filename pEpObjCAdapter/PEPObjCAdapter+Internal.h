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
 unecryptedSubjectEnabled value to use for all sessions created.

 @return Whether or not mail subjects should be encrypted
 */
+ (BOOL)unEncryptedSubjectEnabled;

/**
 @note That global value is used for all new sessions
 @return The current status of passive mode (enabled or not)
 */
+ (BOOL)passiveModeEnabled;

@end

#endif /* PEPIOSAdapter_Internal_h */
