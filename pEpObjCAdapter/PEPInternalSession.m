//
//  PEPSession.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 08.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "PEPInternalSession.h"

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

#import "key_reset.h"

PEPPassphraseCache * _Nullable g_passphraseCache;

@implementation PEPInternalSession

- (_Nullable instancetype)init
{
    self = [super init];
    if (self) {
        [PEPInternalSession setupTrustWordsDB];

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

#pragma mark - DEBUG UTILS

#pragma mark - PEPSessionProtocol

void decryptMessageDictFree(message *src, message *dst, stringlist_t *extraKeys)
{
    free_message(src);
    free_message(dst);
    free_stringlist(extraKeys);
}

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

- (PEPMessage * _Nullable)decryptMessage:(PEPMessage * _Nonnull)message
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

- (BOOL)reEvaluateMessageDict:(PEPDict * _Nonnull)messageDict
                     xKeyList:(PEPStringList * _Nullable)xKeyList
                       rating:(PEPRating * _Nonnull)rating
                       status:(PEPStatus * _Nullable)status
                        error:(NSError * _Nullable * _Nullable)error
{
    message *_src = PEP_messageDictToStruct(messageDict);

    stringlist_t *theKeys = NULL;
    if ([xKeyList count]) {
        theKeys = PEP_arrayToStringlist(xKeyList);
    }

    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return re_evaluate_message_rating(session,
                                          _src,
                                          theKeys,
                                          (PEP_rating) *rating,
                                          (PEP_rating *) rating);
    }];

    free_message(_src);
    free_stringlist(theKeys);

    if (status) {
        *status = theStatus;
    }

    if ([NSError setError:error fromPEPStatus:theStatus]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)reEvaluateMessage:(PEPMessage * _Nonnull)message
                 xKeyList:(PEPStringList * _Nullable)xKeyList
                   rating:(PEPRating * _Nonnull)rating
                   status:(PEPStatus * _Nullable)status
                    error:(NSError * _Nullable * _Nullable)error
{
    return [self reEvaluateMessageDict:(PEPDict *) message
                              xKeyList:xKeyList
                                rating:rating
                                status:status
                                 error:error];
}

- (void)removeEmptyArrayKey:(NSString *)key inDict:(PEPMutableDict *)dict
{
    if ([[dict objectForKey:key] count] == 0) {
        [dict removeObjectForKey:key];
    }
}

- (NSDictionary *)removeEmptyRecipients:(PEPDict *)src
{
    NSMutableDictionary *dest = src.mutableCopy;

    [self removeEmptyArrayKey:kPepTo inDict:dest];
    [self removeEmptyArrayKey:kPepCC inDict:dest];
    [self removeEmptyArrayKey:kPepBCC inDict:dest];

    return dest;
}

- (PEPDict * _Nullable)encryptMessageDict:(PEPDict * _Nonnull)messageDict
                                extraKeys:(PEPStringList * _Nullable)extraKeys
                                encFormat:(PEPEncFormat)encFormat
                                   status:(PEPStatus * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error
{
    __block PEP_encrypt_flags_t flags = 0;

    __block message *_src = PEP_messageDictToStruct([self removeEmptyRecipients:messageDict]);
    __block message *_dst = NULL;
    __block stringlist_t *_keys = PEP_arrayToStringlist(extraKeys);

    PEPStatus theStatus = [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return encrypt_message(session,
                               _src,
                               _keys,
                               &_dst,
                               (PEP_enc_format) encFormat,
                               flags);
    }];

    if (status) {
        *status = theStatus;
    }

    if ([NSError setError:error fromPEPStatus:theStatus]) {
        return nil;
    }

    NSDictionary *dst_;

    if (_dst) {
        dst_ = PEP_messageDictFromStruct(_dst);
    }
    else {
        dst_ = PEP_messageDictFromStruct(_src);
    }

    free_message(_src);
    free_message(_dst);
    free_stringlist(_keys);

    return dst_;
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                               encFormat:(PEPEncFormat)encFormat
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPDict *encryptedDict = [self encryptMessageDict:(NSDictionary *) message
                                            extraKeys:extraKeys
                                            encFormat:encFormat
                                               status:status
                                                error:error];
    if (encryptedDict) {
        PEPMessage *encrypted = [PEPMessage new];
        [encrypted setValuesForKeysWithDictionary:encryptedDict];
        return encrypted;
    } else {
        return nil;
    }
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    return [self
            encryptMessage:message
            extraKeys:extraKeys
            encFormat:PEPEncFormatPEP
            status:status
            error:error];
}

- (PEPDict * _Nullable)encryptMessageDict:(PEPDict * _Nonnull)messageDict
                                  forSelf:(PEPIdentity * _Nonnull)ownIdentity
                                extraKeys:(PEPStringList * _Nullable)extraKeys
                                   status:(PEPStatus * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error
{
    __block PEP_encrypt_flags_t flags = 0;

    __block message *_src = PEP_messageDictToStruct([self removeEmptyRecipients:messageDict]);
    __block pEp_identity *ident = PEP_identityToStruct(ownIdentity);
    __block message *_dst = NULL;

    __block stringlist_t *keysStringList = PEP_arrayToStringlist(extraKeys);

    PEPStatus theStatus = [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return encrypt_message_for_self(session,
                                        ident,
                                        _src,
                                        keysStringList,
                                        &_dst,
                                        PEP_enc_PGP_MIME,
                                        flags);
    }];

    free_stringlist(keysStringList);

    if (status) {
        *status = theStatus;
    }

    if ([NSError setError:error fromPEPStatus:theStatus]) {
        return nil;
    }

    NSDictionary *dst_;

    if (_dst) {
        dst_ = PEP_messageDictFromStruct(_dst);
    }
    else {
        dst_ = PEP_messageDictFromStruct(_src);
    }

    free_message(_src);
    free_message(_dst);
    free_identity(ident);

    return dst_;
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                                 forSelf:(PEPIdentity * _Nonnull)ownIdentity
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPDict *target = [self
                       encryptMessageDict:message.dictionary
                       forSelf:ownIdentity
                       extraKeys:extraKeys
                       status:status
                       error:error];
    if (target) {
        PEPMessage *encrypted = [PEPMessage new];
        [encrypted setValuesForKeysWithDictionary:target];
        return encrypted;
    } else {
        return nil;
    }
}


- (PEPDict * _Nullable)encryptMessageDict:(PEPDict * _Nonnull)messageDict
                                    toFpr:(NSString * _Nonnull)toFpr
                                encFormat:(PEPEncFormat)encFormat
                                    flags:(PEPDecryptFlags)flags
                                   status:(PEPStatus * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error __deprecated
{
    message *src = PEP_messageDictToStruct([self removeEmptyRecipients:messageDict]);
    __block message *dst = NULL;

    PEPStatus theStatus = [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return encrypt_message_and_add_priv_key(session,
                                                src,
                                                &dst,
                                                [[toFpr precomposedStringWithCanonicalMapping] UTF8String],
                                                (PEP_enc_format) encFormat,
                                                flags);
    }];

    if (status) {
        *status = theStatus;
    }

    if ([NSError setError:error fromPEPStatus:theStatus]) {
        return nil;
    }

    if (dst) {
        return PEP_messageDictFromStruct(dst);
    }

    return nil;
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                                   toFpr:(NSString * _Nonnull)toFpr
                               encFormat:(PEPEncFormat)encFormat
                                   flags:(PEPDecryptFlags)flags
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPDict *target = [self
                       encryptMessageDict:message.dictionary
                       toFpr:toFpr
                       encFormat:encFormat
                       flags:flags
                       status:status
                       error:error];

    if (target) {
        PEPMessage *encrypted = [PEPMessage new];
        [encrypted setValuesForKeysWithDictionary:target];
        return encrypted;
    } else {
        return nil;
    }
}

typedef PEP_STATUS (* rating_function_type)(PEP_SESSION session, message *msg, PEP_rating *rating);

- (NSNumber * _Nullable)helperOutgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                                        ratingFunction:(rating_function_type)ratingFunction
                                                 error:(NSError * _Nullable * _Nullable)error
{
    message *_msg = PEP_messageToStruct(theMessage);
    PEPRating rating = PEPRatingUndefined;

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return ratingFunction(session, _msg, (PEP_rating *) &rating);
    }];

    free_message(_msg);

    if ([NSError setError:error fromPEPStatus:status]) {
        return nil;
    }

    return [NSNumber numberWithPEPRating:rating];
}

- (NSNumber * _Nullable)outgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                                           error:(NSError * _Nullable * _Nullable)error
{
    return [self
            helperOutgoingRatingForMessage:theMessage
            ratingFunction:&outgoing_message_rating
            error:error];
}

- (NSNumber * _Nullable)outgoingRatingPreviewForMessage:(PEPMessage * _Nonnull)theMessage
                                                  error:(NSError * _Nullable * _Nullable)error
{
    return [self
            helperOutgoingRatingForMessage:theMessage
            ratingFunction:&outgoing_message_rating_preview
            error:error];
}

- (NSNumber * _Nullable)ratingForIdentity:(PEPIdentity * _Nonnull)identity
                                    error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = PEP_identityToStruct(identity);
    PEPRating rating = PEPRatingUndefined;

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return identity_rating(session, ident, (PEP_rating *) &rating);
    }];

    free_identity(ident);

    if ([NSError setError:error fromPEPStatus:status]) {
        return nil;
    }

    return [NSNumber numberWithPEPRating:rating];
}

- (NSArray * _Nullable)trustwordsForFingerprint:(NSString * _Nonnull)fingerprint
                                     languageID:(NSString * _Nonnull)languageID
                                      shortened:(BOOL)shortened
                                          error:(NSError * _Nullable * _Nullable)error
{
    NSMutableArray *array = [NSMutableArray array];

    for (int i = 0; i < [fingerprint length]; i += 4) {
        if (shortened && i >= 20)
            break;

        NSString *str = [fingerprint substringWithRange:NSMakeRange(i, 4)];

        unsigned int value;
        [[NSScanner scannerWithString:str] scanHexInt:&value];

        PEPAutoPointer *word = [PEPAutoPointer new];
        __block size_t size = 0;

        PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
            return trustword(session,
                             value,
                             [[languageID precomposedStringWithCanonicalMapping]
                              UTF8String],
                             word.charPointerPointer,
                             &size);
        }];

        if ([NSError setError:error fromPEPStatus:status]) {
            return nil;
        }

        [array addObject:[NSString stringWithUTF8String:word.charPointer]];
    }

    return array;
}

- (BOOL)mySelf:(PEPIdentity * _Nonnull)identity
         error:(NSError * _Nullable * _Nullable)error {
    pEp_identity *ident = PEP_identityToStruct(identity);

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return myself(session, ident);
    }];

    if ([NSError setError:error fromPEPStatus:status]) {
        free_identity(ident);
        return NO;
    }

    [identity reset];
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);

    return YES;
}

- (BOOL)updateIdentity:(PEPIdentity * _Nonnull)identity error:(NSError * _Nullable * _Nullable)error
{
    if (identity.isOwn) {
        return [self mySelf:identity error:error];
    } else {
        pEp_identity *ident = PEP_identityToStruct(identity);

        PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
            return update_identity(session, ident);
        }];

        if ([NSError setError:error fromPEPStatus:status]) {
            free_identity(ident);
            return NO;
        }

        [identity reset];
        [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
        free_identity(ident);

        return YES;
    }
}

- (BOOL)trustPersonalKey:(PEPIdentity * _Nonnull)identity
                   error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = PEP_identityToStruct(identity);

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return trust_personal_key(session, ident);
    }];

    if ([NSError setError:error fromPEPStatus:status]) {
        free_identity(ident);
        return NO;
    }

    [identity reset];
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
    return YES;
}

- (BOOL)keyMistrusted:(PEPIdentity *)identity error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = PEP_identityToStruct(identity);

    PEPStatus status = (PEPStatus) key_mistrusted(_session, ident);

    if ([NSError setError:error fromPEPStatus:status]) {
        free_identity(ident);
        return NO;
    }

    [identity reset];
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);

    return YES;
}

- (BOOL)keyResetTrust:(PEPIdentity * _Nonnull)identity
                error:(NSError * _Nullable * _Nullable)error
{
    __block pEp_identity *ident = PEP_identityToStruct(identity);

    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return key_reset_trust(session, ident);
    }];

    if ([NSError setError:error fromPEPStatus:theStatus]) {
        free_identity(ident);
        return NO;
    }

    [identity reset];
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);

    return YES;
}

- (BOOL)enableSyncForIdentity:(PEPIdentity * _Nonnull)identity
                        error:(NSError * _Nullable * _Nullable)error
{
    if (!identity.isOwn) {
        [NSError setError:error fromPEPStatus:PEPStatusIllegalValue];
        return NO;
    }

    pEp_identity *ident = PEP_identityToStruct(identity);

    PEPStatus status = (PEPStatus) enable_identity_for_sync(_session, ident);

    if ([NSError setError:error fromPEPStatus:status]) {
        free_identity(ident);
        return NO;
    }

    free_identity(ident);

    return YES;
}

- (BOOL)disableSyncForIdentity:(PEPIdentity * _Nonnull)identity
                         error:(NSError * _Nullable * _Nullable)error
{
    if (!identity.isOwn) {
        [NSError setError:error fromPEPStatus:PEPStatusIllegalValue];
        return NO;
    }

    pEp_identity *ident = PEP_identityToStruct(identity);

    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return disable_identity_for_sync(session, ident);
    }];

    if ([NSError setError:error fromPEPStatus:theStatus]) {
        free_identity(ident);
        return NO;
    }

    free_identity(ident);

    return YES;
}

- (NSNumber * _Nullable)queryKeySyncEnabledForIdentity:(PEPIdentity * _Nonnull)identity
                                                 error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = PEP_identityToStruct(identity);

    if (!identity.isOwn) {
        [NSError setError:error fromPEPStatus:PEPStatusIllegalValue];
        return nil;
    }

    PEPStatus status = (PEPStatus) myself(_session, ident);

    if ([NSError setError:error fromPEPStatus:status]) {
        free_identity(ident);
        return nil;
    }

    identity_flags_t flags = ident->flags;

    free_identity(ident);

    if (flags & PEP_idf_not_for_sync) {
        return [NSNumber numberWithBool:NO];
    } else {
        return [NSNumber numberWithBool:YES];
    }
}

- (NSArray<PEPIdentity *> * _Nullable)importKey:(NSString * _Nonnull)keydata
                                          error:(NSError * _Nullable * _Nullable)error
{
    identity_list *identList = NULL;

    PEPStatus status = (PEPStatus) import_key(_session,
                                              [[keydata precomposedStringWithCanonicalMapping] UTF8String],
                                              [keydata length], &identList);

    if ([NSError setError:error fromPEPStatus:status]) {
        free(identList);
        return nil;
    }

    NSArray *idents = PEP_arrayFromIdentityList(identList);
    free(identList);

    return idents;
}

- (BOOL)logTitle:(NSString * _Nonnull)title
          entity:(NSString * _Nonnull)entity
     description:(NSString * _Nullable)description
         comment:(NSString * _Nullable)comment
           error:(NSError * _Nullable * _Nullable)error
{
    PEPStatus status = (PEPStatus) log_event(_session,
                                             [[title precomposedStringWithCanonicalMapping]
                                              UTF8String],
                                             [[entity precomposedStringWithCanonicalMapping]
                                              UTF8String],
                                             [[description precomposedStringWithCanonicalMapping]
                                              UTF8String],
                                             [[comment precomposedStringWithCanonicalMapping]
                                              UTF8String]);

    if ([NSError setError:error fromPEPStatus:status]) {
        return NO;
    } else {
        return YES;
    }
}

- (NSString * _Nullable)getLogWithError:(NSError * _Nullable * _Nullable)error
{
    char *theChars = NULL;
    PEPStatus status = (PEPStatus) get_crashdump_log(_session, 0, &theChars);

    if ([NSError setError:error fromPEPStatus:status]) {
        return nil;
    }

    if (theChars) {
        return [NSString stringWithUTF8String:theChars];
    } else {
        [NSError setError:error fromPEPStatus:(PEPStatus) PEP_UNKNOWN_ERROR];
        return nil;
    }
}

- (NSString * _Nullable)getTrustwordsIdentity1:(PEPIdentity * _Nonnull)identity1
                                     identity2:(PEPIdentity * _Nonnull)identity2
                                      language:(NSString * _Nullable)language
                                          full:(BOOL)full
                                         error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident1 = PEP_identityToStruct(identity1);
    pEp_identity *ident2 = PEP_identityToStruct(identity2);
    PEPStatus status;

    PEPAutoPointer *trustwords = [PEPAutoPointer new];
    size_t sizeWritten = 0;

    status = (PEPStatus) get_trustwords(_session, ident1, ident2,
                                        [[language precomposedStringWithCanonicalMapping]
                                         UTF8String],
                                        trustwords.charPointerPointer, &sizeWritten, full);

    free_identity(ident1);
    free_identity(ident2);

    NSString *result = nil;

    if (![NSError setError:error fromPEPStatus:status]) {
        result = [NSString stringWithUTF8String:trustwords.charPointer];
    }

    return result;
}

- (NSString * _Nullable)getTrustwordsFpr1:(NSString * _Nonnull)fpr1
                                     fpr2:(NSString * _Nonnull)fpr2
                                 language:(NSString * _Nullable)language
                                     full:(BOOL)full
                                    error:(NSError * _Nullable * _Nullable)error
{
    const char *_fpr1 = [fpr1 UTF8String]; // fprs are NFC normalized anyway
    const char *_fpr2 = [fpr2 UTF8String];
    
    PEPStatus status;
    
    PEPAutoPointer *trustwords = [PEPAutoPointer new];
    size_t sizeWritten = 0;

    status = (PEPStatus) get_trustwords_for_fprs(_session, _fpr1, _fpr2,
                                                 [[language precomposedStringWithCanonicalMapping]
                                                  UTF8String],
                                                 trustwords.charPointerPointer, &sizeWritten, full);
    
    NSString *result = nil;
    
    if (![NSError setError:error fromPEPStatus:status]) {
        result = [NSString stringWithUTF8String:trustwords.charPointer];
    }
    
    return result;
}

- (NSArray<PEPLanguage *> * _Nullable)languageListWithError:(NSError * _Nullable * _Nullable)error
{
    PEPAutoPointer *chLangs = [PEPAutoPointer new];
    PEPStatus status = (PEPStatus) get_languagelist(_session, chLangs.charPointerPointer);

    if ([NSError setError:error fromPEPStatus:status]) {
        return nil;
    }

    NSString *parserInput = [NSString stringWithUTF8String:chLangs.charPointer];

    NSMutableArray<NSString *> *tokens = [NSMutableArray array];
    PEPCSVScanner *scanner = [[PEPCSVScanner alloc] initWithString:parserInput];
    while (YES) {
        NSString *token = [scanner nextString];
        if (!token) {
            break;
        }
        [tokens addObject:token];
    }
    
    NSArray *theTokens = [NSArray arrayWithArray:tokens];
    NSMutableArray<PEPLanguage *> *langs = [NSMutableArray new];
    while (YES) {
        ArrayTake *take = [theTokens takeOrNil:3];
        if (!take) {
            break;
        }
        NSArray *elements = take.elements;
        PEPLanguage *lang = [[PEPLanguage alloc]
                             initWithCode:[elements objectAtIndex:0]
                             name:[elements objectAtIndex:1]
                             sentence:[elements objectAtIndex:2]];
        [langs addObject:lang];
        theTokens = take.rest;
    }
    
    return [NSArray arrayWithArray:langs];
}

static NSDictionary *ratingToString;
static NSDictionary *stringToRating;

+ (void)initialize
{
    NSDictionary *ratingToStringIntern =
    @{
      [NSNumber numberWithInteger:PEPRatingCannotDecrypt]: @"cannot_decrypt",
      [NSNumber numberWithInteger:PEPRatingHaveNoKey]: @"have_no_key",
      [NSNumber numberWithInteger:PEPRatingUnencrypted]: @"unencrypted",
      [NSNumber numberWithInteger:PEPRatingUnencryptedForSome]: @"unencrypted_for_some",
      [NSNumber numberWithInteger:PEPRatingUnreliable]: @"unreliable",
      [NSNumber numberWithInteger:PEPRatingReliable]: @"reliable",
      [NSNumber numberWithInteger:PEPRatingTrusted]: @"trusted",
      [NSNumber numberWithInteger:PEPRatingTrustedAndAnonymized]: @"trusted_and_anonymized",
      [NSNumber numberWithInteger:PEPRatingFullyAnonymous]: @"fully_anonymous",
      [NSNumber numberWithInteger:PEPRatingMistrust]: @"mistrust",
      [NSNumber numberWithInteger:PEPRatingB0rken]: @"b0rken",
      [NSNumber numberWithInteger:PEPRatingUnderAttack]: @"under_attack",
      [NSNumber numberWithInteger:PEPRatingUndefined]: kUndefined,
      };
    NSMutableDictionary *stringToRatingMutable = [NSMutableDictionary
                                                  dictionaryWithCapacity:
                                                  ratingToStringIntern.count];
    for (NSNumber *ratingNumber in ratingToStringIntern.allKeys) {
        NSString *ratingName = [ratingToStringIntern objectForKey:ratingNumber];
        [stringToRatingMutable setObject:ratingNumber forKey:ratingName];
    }
    ratingToString = ratingToStringIntern;
    stringToRating = [NSDictionary dictionaryWithDictionary:stringToRatingMutable];
}

- (PEPRating)ratingFromString:(NSString * _Nonnull)string
{
    NSNumber *num = [stringToRating objectForKey:string];
    if (num) {
        return (PEPRating) [num integerValue];
    } else {
        return PEPRatingUndefined;
    }
}

- (NSString * _Nonnull)stringFromRating:(PEPRating)rating
{
    NSString *stringRating = [ratingToString objectForKey:[NSNumber numberWithInteger:rating]];
    if (stringRating) {
        return stringRating;
    } else {
        return kUndefined;
    }
}

- (NSNumber * _Nullable)isPEPUser:(PEPIdentity * _Nonnull)identity
                            error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = PEP_identityToStruct(identity);
    bool isPEP;
    PEPStatus status = (PEPStatus) is_pEp_user(self.session, ident, &isPEP);

    free_identity(ident);

    if ([NSError setError:error fromPEPStatus:status]) {
        return nil;
    } else {
        return [NSNumber numberWithBool:isPEP];
    }
}

- (BOOL)setOwnKey:(PEPIdentity * _Nonnull)identity fingerprint:(NSString * _Nonnull)fingerprint
            error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = PEP_identityToStruct(identity);
    PEPStatus status = (PEPStatus) set_own_key(self.session, ident,
                                               [[fingerprint precomposedStringWithCanonicalMapping]
                                                UTF8String]);
    free_identity(ident);

    if ([NSError setError:error fromPEPStatus:status]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)configurePassiveModeEnabled:(BOOL)enabled
{
    config_passive_mode(_session, enabled);
}

- (BOOL)setFlags:(PEPIdentityFlags)flags
     forIdentity:(PEPIdentity *)identity
           error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = PEP_identityToStruct(identity);
    PEPStatus status = (PEPStatus) set_identity_flags(self.session, ident, flags);

    if ([NSError setError:error fromPEPStatus:status]) {
        free_identity(ident);
        return NO;
    } else {
        [identity reset];
        [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
        free_identity(ident);
        return YES;
    }
}

- (BOOL)deliverHandshakeResult:(PEPSyncHandshakeResult)result
             identitiesSharing:(NSArray<PEPIdentity *> * _Nullable)identitiesSharing
                         error:(NSError * _Nullable * _Nullable)error;
{
    identity_list *identitiesSharingData = NULL;

    if (identitiesSharing) {
        identitiesSharingData = PEP_identityArrayToList(identitiesSharing);
    }

    PEPStatus status = (PEPStatus) deliverHandshakeResult(self.session,
                                                          (sync_handshake_result) result,
                                                          identitiesSharingData);

    free(identitiesSharingData);

    if ([NSError setError:error fromPEPStatus:status]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)trustOwnKeyIdentity:(PEPIdentity * _Nonnull)identity
                      error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = PEP_identityToStruct(identity);
    PEPStatus status = (PEPStatus) trust_own_key(self.session, ident);
    free_identity(ident);

    if ([NSError setError:error fromPEPStatus:status]) {
        return NO;
    } else {
        return YES;
    }
}

- (PEPColor)colorFromRating:(PEPRating)rating
{
    return (PEPColor) color_from_rating((PEP_rating) rating);
}


- (BOOL)keyReset:(PEPIdentity * _Nonnull)identity
     fingerprint:(NSString * _Nullable)fingerprint
           error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = PEP_identityToStruct(identity);
    const char *fpr = [[fingerprint precomposedStringWithCanonicalMapping] UTF8String];

    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return key_reset_user(session, ident->user_id, fpr);
    }];

    free_identity(ident);

    if ([NSError setError:error fromPEPStatus:theStatus]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)leaveDeviceGroup:(NSError * _Nullable * _Nullable)error
{
    PEPStatus status = (PEPStatus) leave_device_group(self.session);

    if ([NSError setError:error fromPEPStatus:status]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)keyResetAllOwnKeysError:(NSError * _Nullable * _Nullable)error
{
    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return key_reset_all_own_keys(self.session);
    }];

    if ([NSError setError:error fromPEPStatus:theStatus]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)configurePassphrase:(NSString * _Nonnull)passphrase
                      error:(NSError * _Nullable * _Nullable)error
{
    if (error) {
        *error = nil;
    }

    NSString *normalizedPassphrase = [passphrase normalizedPassphraseWithError:error];

    if (normalizedPassphrase == nil) {
        return NO;
    }

    [self.passphraseCache addPassphrase:normalizedPassphrase];

    PEP_STATUS status = config_passphrase(_session, [normalizedPassphrase UTF8String]);

    if ([NSError setError:error fromPEPStatus:(PEPStatus) status]) {
        return NO;
    }
    [PEPSync.sharedInstance handleNewPassphraseConfigured];

    return YES;
}

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

@end
