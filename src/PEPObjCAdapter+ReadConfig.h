//
//  PEPIOSAdapter+ReadConfig.h
//  pEpiOSAdapter
//
//  Created by Edouard Tisserant on 11/11/15.
//  Copyright © 2015 p≡p. All rights reserved.
//

#ifndef PEPIOSAdapter_ReadConfig_h
#define PEPIOSAdapter_ReadConfig_h

#import "PEPObjCAdapter.h"

#import "PEPPassphraseProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPObjCAdapter (ReadConfig)

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

#endif /* PEPIOSAdapter_ReadConfig_h */
