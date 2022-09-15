//
//  PEPObjCAdapterConfigurationProtocol.h
//  pEpObjCAdapter
//
//  Created by David Alarcon on 16/6/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPObjCAdapterConfigurationProtocol+Echo.h"
#import "PEPObjCAdapterConfigurationProtocol+MediaKeys.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PEPObjCAdapterConfigurationProtocol <PEPObjCAdapterEchoConfigurationProtocol, PEPObjCAdapterMediaKeysConfigurationProtocol>

/// Sets Engine config for unecryptedSubjectEnabled to the given value on all Sessions created by
/// this adapter.
///
/// @param enabled Whether or not mail subjects should be encrypted
+ (void)setUnEncryptedSubjectEnabled:(BOOL)enabled;

/// Enable or disable passive mode for all sessions.
+ (void)setPassiveModeEnabled:(BOOL)enabled;

/// Sets a passphrase (with a maximum of 250 code points) for
/// (own) secret keys generated from now on.
///
/// @discussion You can add as many passphrases to the cache as needed by calling this method.
/// Every passphrase is valid for 10 min (default, compile-time configurable),
/// after that it gets removed from memory. The maximum count of passphrases is 20.
/// Setting the 21st replaces the 1st.
/// On error, `NO` is returned and the (optional) parameter `error`
/// is set to the error that occurred.
/// On every engine call that returns PEPStatusPassphraseRequired, or PEPStatusWrongPassphrase,
/// the adapter will automatically repeat the call after setting the next cached passphrase
/// (using the engine's `config_passphrase`). The first attempet as always with an empty password.
/// This will be repeated until the call either succeeds, or until
/// the adapter runs out of usable passwords.
/// When the adapter runs out of passwords to try, PEPStatusWrongPassphrase will be thrown.
/// If the engine indicates PEPStatusPassphraseRequired, and there are no passwords,
/// the adapter will throw PEPStatusPassphraseRequired.
/// The passphrase can have a "maximum number of code points of 250", which is
/// approximated by checking the string length.
/// If the passphrase exceeds this limit, the adapter throws PEPAdapterErrorPassphraseTooLong
/// with a domain of PEPObjCAdapterErrorDomain.
/// Sets a passphrase (with a maximum of 250 code points) for
/// (own) secret keys generated from now on.
///
/// A `nil` password means disable own passwords for future keys,
/// which is the default.
///
/// The password will be kept in memory until overwritten by another,
/// which includes `nil`. It will be set or unset to _each_ session,
/// similar to other configurable options in the adapter.
///
/// @Throws PEPAdapterErrorPassphraseTooLong (with a domain of PEPObjCAdapterErrorDomain)
+ (BOOL)configurePassphraseForNewKeys:(NSString * _Nullable)passphrase
                                error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
