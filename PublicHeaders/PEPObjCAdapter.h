//
//  PEPObjCAdapter.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPObjCAdapterConfigurationProtocol.h"
#import "PEPSession.h"
#import "PEPNotifyHandshakeDelegate.h"
#import "PEPSendMessageDelegate.h"
#import "PEPSync.h"
#import "NSNumber+PEPRating.h"
#import "PEPConstants.h"
#import "PEPPassphraseProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class PEPLanguage;

@interface PEPObjCAdapter : NSObject <PEPObjCAdapterConfigurationProtocol>

#pragma mark - Configuration

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
