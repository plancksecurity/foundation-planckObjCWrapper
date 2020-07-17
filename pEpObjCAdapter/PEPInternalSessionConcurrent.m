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
#import "PEPInternalSessionConcurrent+PassphraseCache.h"

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

- (PEPDict * _Nullable)decryptMessageDict:(PEPMutableDict * _Nonnull)messageDict
                                    flags:(PEPDecryptFlags * _Nullable)flags
                                   rating:(PEPRating * _Nullable)rating
                                extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                   status:(PEPStatus * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error
{
    if (rating) {
        *rating = PEPRatingUndefined;
    }

    message *_src = PEP_messageDictToStruct(messageDict);
    __block message *_dst = NULL;
    __block stringlist_t *theKeys = NULL;
    __block PEPDecryptFlags theFlags = 0;

    if (flags) {
        theFlags = *flags;
    }

    if (extraKeys && [*extraKeys count]) {
        theKeys = PEP_arrayToStringlist(*extraKeys);
    }

    __block PEPRating internalRating = PEPRatingUndefined;

    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return decrypt_message(session,
                               _src,
                               &_dst,
                               &theKeys,
                               (PEP_rating *) &internalRating,
                               (PEP_decrypt_flags *) &theFlags);
    }];

    if (status) {
        *status = theStatus;
    }

    if ([NSError setError:error fromPEPStatus:theStatus]) {
        decryptMessageDictFree(_src, _dst, theKeys);
        return nil;
    }

    if (flags) {
        *flags = theFlags;
    }

    NSDictionary *dst_;

    if (_dst) {
        dst_ = PEP_messageDictFromStruct(_dst);
    } else {
        dst_ = PEP_messageDictFromStruct(_src);
    }

    if (theFlags & PEP_decrypt_flag_untrusted_server) {
        [messageDict replaceWithMessage:_src];
    }

    if (extraKeys) {
        *extraKeys = PEP_arrayFromStringlist(theKeys);
    }

    decryptMessageDictFree(_src, _dst, theKeys);

    if (rating) {
        *rating = internalRating;
    }

    return dst_;
}

- (PEPMessage * _Nullable)decryptMessage:(PEPMessage *)message
                                   flags:(PEPDecryptFlags * _Nullable)flags
                                  rating:(PEPRating * _Nullable)rating
                               extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPDict *destDict = [self
                         decryptMessageDict:message.mutableDictionary
                         flags:flags
                         rating:rating
                         extraKeys:extraKeys
                         status:status
                         error:error];

    if (destDict) {
        PEPMessage *msg = [PEPMessage new];
        [msg setValuesForKeysWithDictionary:destDict];
        return msg;
    } else {
        return nil;
    }
}

@end
