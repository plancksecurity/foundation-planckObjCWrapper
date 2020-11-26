//
//  PEPObjCAdapter.h
//  PEPObjCAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPPassphraseProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class PEPLanguage;

@interface PEPObjCAdapter : NSObject

#pragma mark - Configuration

/**
 Sets Engine config for unecryptedSubjectEnabled to the given value on all Sessions created by
 this adapter.

 @param enabled Whether or not mail subjects should be encrypted
 */
+ (void)setUnEncryptedSubjectEnabled:(BOOL)enabled;

/**
 Enable or disable passive mode for all sessions.
 */
+ (void)setPassiveModeEnabled:(BOOL)enabled;

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

/// Sets a passphrase provider.
///
/// @note The reference is strong, so the caller can relinquish ownership if needed.
+ (void)setPassphraseProvider:(id<PEPPassphraseProviderProtocol> _Nullable)passphraseProvider;

#pragma mark -

/**
 The HOME URL, where all pEp related files will be stored.
 */
+ (NSURL *)homeURL;

+ (void)setupTrustWordsDB;
+ (void)setupTrustWordsDB:(NSBundle *)rootBundle;

/**
 The directory where pEp stores user-specific data.

 @return An NSString denoting the directory where user-specific data gets stored by the engine.
 */
+ (NSString *)perUserDirectoryString;

/**
 The directory where pEp stores data for all users on this machine.

 @return An NSString denoting the directory where global data (for all users of this machine
         or device) gets stored by the engine.
 */
+ (NSString *)perMachineDirectoryString;

@end

NS_ASSUME_NONNULL_END
