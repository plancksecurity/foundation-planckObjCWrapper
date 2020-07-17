//
//  PEPIOSAdapter+Internal.h
//  pEpiOSAdapter
//
//  Created by Edouard Tisserant on 11/11/15.
//  Copyright © 2015 p≡p. All rights reserved.
//

#ifndef PEPIOSAdapter_Internal_h
#define PEPIOSAdapter_Internal_h

#import "PEPObjCAdapter.h"

#import "PEPQueue.h"
#import "PEPInternalSession.h"
#import "PEPPassphraseProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

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

/// The passphrase to be used for new own keys, can be `nil`.
+ (NSString * _Nullable)passphraseForNewKeys;

/// Get the currently set passphrase provider.
+ (id<PEPPassphraseProviderProtocol> _Nullable)passphraseProvider;

@end

NS_ASSUME_NONNULL_END

#endif /* PEPIOSAdapter_Internal_h */
