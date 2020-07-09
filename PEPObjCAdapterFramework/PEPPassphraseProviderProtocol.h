//
//  PEPPassphraseProviderProtocol.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 08.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Delegate methods that an app can utilize to provide passphrases to the adapter after
/// asking the user.
///
/// If this delegate (passphrase provider) exists (see `+ [PEPObjCAdapter passphraseProvider]`),
/// then any supported engine call that returns the engine equivalent of
/// PEPStatusPassphraseRequired or PEPStatusWrongPassphrase
/// leads to an invocation of the delegate, which then can indicate the user's respone
/// via the given callback.
///
/// If no passphrase provider exists, the error status is thrown directly to
/// the caller.
typedef void (^PEPPassphraseProviderCallback)(NSString * _Nullable passphrase);

@protocol PEPPassphraseProviderProtocol <NSObject>

/// Called by the adapter when the engine signals PEPStatusPassphraseRequired.
///
/// See `PEPPassphraseProviderProtocol` for a general description.
///
/// @param completion Callback that either retries the engine call that lead
/// to the adapter calling into the PEPPassphraseProviderProtocol delegate,
/// or, if the given passphrase is nil, return the error to the caller.
- (void)passphraseRequiredCompletion:(PEPPassphraseProviderCallback)completion;

/// Called by the adapter when the engine signals PEPStatusWrongPassphrase.
///
/// See `PEPPassphraseProviderProtocol` for a general description.
///
/// @param completion Callback that either retries the engine call that lead
/// to the adapter calling into the PEPPassphraseProviderProtocol delegate,
/// or, if the given passphrase is nil, return the error to the caller.
- (void)wrongPassphraseCompletion:(PEPPassphraseProviderCallback)completion;

/// Signals that the passphrase indicated by the callback in one of the calls of
/// this delegate was too long and cannot be used.
- (void)passphraseTooLong:(PEPPassphraseProviderCallback)completion;

@end

NS_ASSUME_NONNULL_END
