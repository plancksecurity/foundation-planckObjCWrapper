//
//  PEPPassphraseCache.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 25.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern const NSUInteger PEPPassphraseCacheMaxNumberOfPassphrases;

/// Caches passwords the app sets after asking the user, for some time.
/// - Note: The passwords are expected to be Unicode Normalization Form C,
/// in order to meet the engine's requirement of being UTF-8 NFC strings.
@interface PEPPassphraseCache : NSObject

+ (instancetype)sharedInstance;

/// Add a new password.
- (void)addPassphrase:(NSString *)passphrase;

/// Retrieve the current list of cached passwords, including the empty one (`@""`),
/// in the order "last added (or successfully used) first"
/// (except the empty password, which is _always_ first).
- (NSArray<NSString *> *)passphrases;

/// Indicate that the given passphrase was just successfully used and its timeout
/// should be reset.
- (void)resetTimeoutForPassphrase:(NSString *)passphrase;

@end

NS_ASSUME_NONNULL_END
