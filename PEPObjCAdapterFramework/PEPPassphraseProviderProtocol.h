//
//  PEPPassphraseProviderProtocol.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 08.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Callback an app can use to provide a passphrase to the adapter after user input.
///
/// A nil passphrase means to throw the original error
/// (PEPStatusPassphraseRequired or PEPStatusWrongPassphrase), otherwise
/// the current call is tried again with the given passphrase.
typedef void (^PEPPassphraseProviderCallback)(NSString * _Nullable passphrase);

@protocol PEPPassphraseProviderProtocol <NSObject>

- (void)passphraseRequiredCompletion:(PEPPassphraseProviderCallback)completion;
- (void)wrongPassphraseCompletion:(PEPPassphraseProviderCallback)completion;
- (void)passphraseTooLong:(PEPPassphraseProviderCallback)completion;

@end

NS_ASSUME_NONNULL_END
