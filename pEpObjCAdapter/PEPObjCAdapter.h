//
//  pEpiOSAdapter.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPSession.h"

extern const PEP_decrypt_flags PEP_decrypt_flag_none;

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

#pragma mark -

/**
 The HOME URL, where all pEp related files will be stored.
 */
+ (NSURL * _Nonnull)homeURL;

+ (void)setupTrustWordsDB;
+ (void)setupTrustWordsDB:(NSBundle * _Nonnull)rootBundle;

@end
