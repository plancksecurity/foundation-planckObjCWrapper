//
//  PEPInternalSessionConcurrent.m
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 17.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPInternalSessionConcurrent.h"

#import "PEPConstants.h"

#import "PEPObjCAdapter.h"
#import "PEPObjCAdapter+Internal.h"
#import "PEPMessageUtil.h"
#import "PEPLanguage.h"
#import "PEPCSVScanner.h"
#import "NSArray+Extension.h"
#import "NSDictionary+CommType.h"
#import "NSDictionary+Debug.h"
#import "PEPIdentity.h"
#import "PEPMessage.h"
#import "NSError+PEP+Internal.h"
#import "PEPAutoPointer.h"
#import "NSNumber+PEPRating.h"
#import "NSMutableDictionary+PEP.h"
#import "PEPSync.h"
#import "PEPSync_Internal.h" // for [PEPSync createSession:]
#import "PEPInternalConstants.h"
#import "PEPPassphraseCache.h"
#import "PEPInternalSession+PassphraseCache.h"
#import "NSString+NormalizePassphrase.h"
#import "PEPObjCAdapter.h"
#import "PEPInternalSession+PassphraseCache.h"

#import "pEpEngine.h"
#import "key_reset.h"
#import "sync_api.h"

@implementation PEPInternalSessionConcurrent

- (_Nullable instancetype)init
{
    self = [super init];
    if (self) {
        [PEPInternalSessionConcurrent setupTrustWordsDB];

        // Get an engine session from PEPSync, because its creation requires callbacks
        // that PEPSync is responsible for.
        _session = [PEPSync createSession:nil];

        // [PEPSync createSession:] has already logged any errors.
        if (!_session) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    if (_session != nil) {
        release(_session);
    }
}

#pragma mark - CONFIG

- (void)configUnEncryptedSubjectEnabled:(BOOL)enabled;
{
    config_unencrypted_subject(self.session, enabled);
}

#pragma mark - INTERNAL

+ (void)setupTrustWordsDB
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [PEPObjCAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];
    });
}

#pragma mark - Passphrases

extern PEPPassphraseCache * _Nullable g_passphraseCache;

- (PEPPassphraseCache * _Nonnull)passphraseCache
{
    return [PEPInternalSession passphraseCache];
}

+ (PEPPassphraseCache * _Nonnull)passphraseCache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_passphraseCache = [[PEPPassphraseCache alloc] init];
    });

    return g_passphraseCache;
}

#pragma mark - Helpers

static void decryptMessageDictFree(message *src, message *dst, stringlist_t *extraKeys)
{
    free_message(src);
    free_message(dst);
    free_stringlist(extraKeys);
}

#pragma mark - PEPSessionProtocol

@end
