//
//  PEPSession.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 08.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

@import PEPObjCTypeUtils_iOS;
@import PEPObjCTypes_iOS;

#import "PEPInternalSession.h"

#import "PEPConstants.h"
#import "PEPObjCAdapter.h"
#import "PEPObjCAdapter+ReadConfig.h"
#import "PEPCSVScanner.h"
#import "NSArray+Take.h"
#import "PEPAutoPointer.h"
#import "NSNumber+PEPRating.h"
#import "PEPSync.h"
#import "PEPSync_Internal.h" // for [PEPSync createSession:]
#import "PEPInternalConstants.h"
#import "PEPPassphraseCache.h"
#import "PEPInternalSession+PassphraseCache.h"
#import "NSString+NormalizePassphrase.h"
#import "PEPIdentity+Reset.h"
#import "PEPMessage+PEPConvert.h"
#import "PEPIdentity+PEPConvert.h"
#import "NSArray+PEPConvert.h"
#import "NSArray+PEPIdentityList.h"

#import "key_reset.h"
#import "media_key.h"

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

void decryptMessageFree(message *src, message *dst, stringlist_t *extraKeys)
{
    free_message(src);
    free_message(dst);
    free_stringlist(extraKeys);
}

#pragma mark - API

- (PEPMessage * _Nullable)decryptMessage:(PEPMessage * _Nonnull)theMessage
                                   flags:(PEPDecryptFlags * _Nullable)flags
                               extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    message *src = [theMessage toStruct];
    __block message *dst = NULL;
    __block stringlist_t *theKeys = NULL;
    __block PEPDecryptFlags theFlags = 0;

    if (flags) {
        theFlags = *flags;
    }

    if (extraKeys && [*extraKeys count]) {
        theKeys = [*extraKeys toStringList];
    }

    // Note: According to the engine docs for decrypt_message_2, the destination
    // message will be NULL on error, and the source message rating will be set regardless.
    // Since we derive our returned messages from either the destination message or source,
    // we'll have a correct rating in the returned result regardless.
    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return decrypt_message_2(session,
                                 src,
                                 &dst,
                                 &theKeys,
                                 (PEP_decrypt_flags *) &theFlags);
    }];

    if (status) {
        *status = theStatus;
    }

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:theStatus]) {
        decryptMessageFree(src, dst, theKeys);
        return nil;
    }

    if (flags) {
        *flags = theFlags;
    }

    PEPMessage *dstMessage;

    if (dst) {
        // Decryption was successful
        dstMessage = [PEPMessage fromStruct:dst];
    } else {
        dstMessage = [PEPMessage fromStruct:src];
    }

    if (theFlags & PEP_decrypt_flag_src_modified) {
        [PEPMessage overwritePEPMessageObject:theMessage withValuesFromStruct:src];
    }

    if (extraKeys) {
        *extraKeys = [NSArray fromStringlist:theKeys];
    }

    decryptMessageFree(src, dst, theKeys);

    return dstMessage;
}

- (BOOL)reEvaluateMessage:(PEPMessage * _Nonnull)theMessage
                 xKeyList:(PEPStringList * _Nullable)xKeyList
                   rating:(PEPRating * _Nonnull)rating
                   status:(PEPStatus * _Nullable)status
                    error:(NSError * _Nullable * _Nullable)error
{
    message *_src = [theMessage toStruct];

    stringlist_t *theKeys = NULL;
    if ([xKeyList count]) {
        theKeys = [xKeyList toStringList];
    }

    PEPRating originalRating = *rating;
    __block PEPRating resultRating = PEPRatingUndefined;

    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        PEP_STATUS tmpStatus = re_evaluate_message_rating(session,
                                                          _src,
                                                          theKeys,
                                                          (PEP_rating) originalRating,
                                                          (PEP_rating *) &resultRating);
        *rating = resultRating;
        return tmpStatus;
    }];

    free_message(_src);
    free_stringlist(theKeys);

    if (status) {
        *status = theStatus;
    }

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:theStatus]) {
        return NO;
    } else {
        return YES;
    }
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)theMessage
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                               encFormat:(PEPEncFormat)encFormat
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    // Don't change the original
    PEPMessage *messageCopy = [[PEPMessage alloc] initWithMessage:theMessage];

    __block PEP_encrypt_flags_t flags = 0;

    __block message *_src = [[PEPMessage pEpMessageWithEmptyRecipientsRemovedFromPEPMessage:messageCopy] toStruct];
    __block message *_dst = NULL;
    __block stringlist_t *_keys = [extraKeys toStringList];

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

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:theStatus]) {
        return nil;
    }

    PEPMessage *dst_;

    if (_dst) {
        dst_ = [PEPMessage fromStruct:_dst];
    }
    else {
        dst_ = [PEPMessage fromStruct:_src];
    }

    free_message(_src);
    free_message(_dst);
    free_stringlist(_keys);

    return dst_;
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

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)theMessage
                                 forSelf:(PEPIdentity * _Nonnull)ownIdentity
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    // Don't change the original
    PEPMessage *messageCopy = [[PEPMessage alloc] initWithMessage:theMessage];

    __block PEP_encrypt_flags_t flags = 0;

    __block message *_src = [[PEPMessage pEpMessageWithEmptyRecipientsRemovedFromPEPMessage:messageCopy] toStruct];
    __block pEp_identity *ident = [ownIdentity toStruct];
    __block message *_dst = NULL;

    __block stringlist_t *keysStringList = [extraKeys toStringList];

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

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:theStatus]) {
        return nil;
    }

    PEPMessage *dst_;

    if (_dst) {
        dst_ = [PEPMessage fromStruct:_dst];
    }
    else {
        dst_ = [PEPMessage fromStruct:_src];
    }

    free_message(_src);
    free_message(_dst);
    free_identity(ident);

    return dst_;
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)theMessage
                                   toFpr:(NSString * _Nonnull)toFpr
                               encFormat:(PEPEncFormat)encFormat
                                   flags:(PEPDecryptFlags)flags
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    // Don't change the original
    PEPMessage *messageCopy = [[PEPMessage alloc] initWithMessage:theMessage];

    message *src = [[PEPMessage pEpMessageWithEmptyRecipientsRemovedFromPEPMessage:messageCopy] toStruct];
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

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:theStatus]) {
        return nil;
    }

    if (dst) {
        // As long as dst is non-nil, the result is also non-nil
        PEPMessage *result = [PEPMessage fromStruct:dst];
        return result;
    }

    return nil;
}

- (NSNumber * _Nullable)outgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                                           error:(NSError * _Nullable * _Nullable)error
{
    message *_msg = [theMessage toStruct];
    __block PEPRating rating = PEPRatingUndefined;

    PEPStatus status = [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return outgoing_message_rating(session, _msg, (PEP_rating *) &rating);
    }];

    free_message(_msg);

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
        return nil;
    }

    return [NSNumber numberWithPEPRating:rating];
}

- (NSNumber * _Nullable)outgoingRatingPreviewForMessage:(PEPMessage * _Nonnull)theMessage
                                                  error:(NSError * _Nullable * _Nullable)error
{
    message *_msg = [theMessage toStruct];
    PEPRating rating = PEPRatingUndefined;

    PEPStatus status = (PEPStatus) outgoing_message_rating_preview(_session,
                                                                   _msg,
                                                                   (PEP_rating *) &rating);

    free_message(_msg);

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
        return nil;
    }

    return [NSNumber numberWithPEPRating:rating];
}

- (NSNumber * _Nullable)ratingForIdentity:(PEPIdentity * _Nonnull)identity
                                    error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = [identity toStruct];
    __block PEPRating rating = PEPRatingUndefined;

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return identity_rating(session, ident, (PEP_rating *) &rating);
    }];

    free_identity(ident);

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
        return nil;
    }

    return [NSNumber numberWithPEPRating:rating];
}

- (NSArray<NSString *> * _Nullable)trustwordsForFingerprint:(NSString * _Nonnull)fingerprint
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
        __block size_t size;

        PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
            return trustword(session,
                             value,
                             [[languageID precomposedStringWithCanonicalMapping]
                              UTF8String],
                             word.charPointerPointer,
                             &size);
        }];

        if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
            return nil;
        }

        [array addObject:[NSString stringWithUTF8String:word.charPointer]];
    }

    return array;
}

- (BOOL)mySelf:(PEPIdentity * _Nonnull)identity error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = [identity toStruct];

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return myself(session, ident);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
        free_identity(ident);
        return NO;
    }

    [identity reset];
    [PEPIdentity overwritePEPIdentityObject:identity withValuesFromStruct:ident];
    free_identity(ident);

    return YES;
}

- (BOOL)updateIdentity:(PEPIdentity * _Nonnull)identity error:(NSError * _Nullable * _Nullable)error
{
    if (identity.isOwn) {
        return [self mySelf:identity error:error];
    } else {
        pEp_identity *ident = [identity toStruct];

        PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
            return update_identity(session, ident);
        }];

        if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
            free_identity(ident);
            return NO;
        }

        [identity reset];
        [PEPIdentity overwritePEPIdentityObject:identity withValuesFromStruct:ident];
        free_identity(ident);

        return YES;
    }
}

- (BOOL)trustPersonalKey:(PEPIdentity * _Nonnull)identity
                   error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = [identity toStruct];

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return trust_personal_key(session, ident);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
        free_identity(ident);
        return NO;
    }

    free_identity(ident);

    return YES;
}

- (BOOL)keyMistrusted:(PEPIdentity *)identity error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = [identity toStruct];

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return key_mistrusted(session, ident);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
        free_identity(ident);
        return NO;
    }

    free_identity(ident);

    return YES;
}

- (BOOL)keyResetTrust:(PEPIdentity * _Nonnull)identity
                error:(NSError * _Nullable * _Nullable)error
{
    __block pEp_identity *ident = [identity toStruct];

    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return key_reset_trust(session, ident);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:theStatus]) {
        free_identity(ident);
        return NO;
    }

    free_identity(ident);

    return YES;
}

- (BOOL)enableSyncForIdentity:(PEPIdentity * _Nonnull)identity
                        error:(NSError * _Nullable * _Nullable)error
{
    if (!identity.isOwn) {
        [PEPStatusNSErrorUtil setError:error fromPEPStatus:PEPStatusIllegalValue];
        return NO;
    }

    pEp_identity *ident = [identity toStruct];

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return enable_identity_for_sync(session, ident);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
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
        [PEPStatusNSErrorUtil setError:error fromPEPStatus:PEPStatusIllegalValue];
        return NO;
    }

    pEp_identity *ident = [identity toStruct];

    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return disable_identity_for_sync(session, ident);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:theStatus]) {
        free_identity(ident);
        return NO;
    }

    free_identity(ident);

    return YES;
}

- (NSArray<PEPIdentity *> * _Nullable)importKey:(NSString * _Nonnull)keydata
                                          error:(NSError * _Nullable * _Nullable)error
{
    __block identity_list *identList = NULL;

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return import_key(session,
                          [[keydata precomposedStringWithCanonicalMapping] UTF8String],
                          [keydata length], &identList);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
        free(identList);
        return nil;
    }

    NSArray *idents = [NSArray fromIdentityList:identList];
    free(identList);

    return idents;
}

- (NSString * _Nullable)getLogWithError:(NSError * _Nullable * _Nullable)error
{
    __block char *theChars = NULL;
    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return get_crashdump_log(session, 0, &theChars);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
        return nil;
    }

    if (theChars) {
        return [NSString stringWithUTF8String:theChars];
    } else {
        [PEPStatusNSErrorUtil setError:error fromPEPStatus:(PEPStatus) PEP_UNKNOWN_ERROR];
        return nil;
    }
}

- (NSString * _Nullable)getTrustwordsIdentity1:(PEPIdentity * _Nonnull)identity1
                                     identity2:(PEPIdentity * _Nonnull)identity2
                                      language:(NSString * _Nullable)language
                                          full:(BOOL)full
                                         error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident1 = [identity1 toStruct];
    pEp_identity *ident2 = [identity2 toStruct];

    PEPAutoPointer *trustwords = [PEPAutoPointer new];
    __block size_t sizeWritten = 0;

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return get_trustwords(session, ident1, ident2,
                              [[language precomposedStringWithCanonicalMapping]
                               UTF8String],
                              trustwords.charPointerPointer, &sizeWritten, full);
    }];

    free_identity(ident1);
    free_identity(ident2);

    NSString *result = nil;

    if (![PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
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
    
    PEPAutoPointer *trustwords = [PEPAutoPointer new];
    __block size_t sizeWritten = 0;

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return get_trustwords_for_fprs(session, _fpr1, _fpr2,
                                       [[language precomposedStringWithCanonicalMapping]
                                        UTF8String],
                                       trustwords.charPointerPointer, &sizeWritten, full);
    }];
    
    NSString *result = nil;
    
    if (![PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
        result = [NSString stringWithUTF8String:trustwords.charPointer];
    }
    
    return result;
}

- (NSArray<PEPLanguage *> * _Nullable)languageListWithError:(NSError * _Nullable * _Nullable)error
{
    PEPAutoPointer *chLangs = [PEPAutoPointer new];
    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return get_languagelist(session, chLangs.charPointerPointer);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
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
    if (num != nil) {
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
    pEp_identity *ident = [identity toStruct];
    __block bool isPEP;
    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return is_pEp_user(session, ident, &isPEP);
    }];

    free_identity(ident);

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
        return nil;
    } else {
        return [NSNumber numberWithBool:isPEP];
    }
}

- (BOOL)setOwnKey:(PEPIdentity * _Nonnull)identity fingerprint:(NSString * _Nonnull)fingerprint
            error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = [identity toStruct];

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return set_own_key(session,
                           ident,
                           [[fingerprint precomposedStringWithCanonicalMapping]
                            UTF8String]);
    }];

    free_identity(ident);

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
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
    pEp_identity *ident = [identity toStruct];

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return set_identity_flags(session, ident, flags);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
        free_identity(ident);
        return NO;
    } else {
        [identity reset];
        [PEPIdentity overwritePEPIdentityObject:identity withValuesFromStruct:ident];
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
        identitiesSharingData = [identitiesSharing toIdentityList];
    }

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return deliverHandshakeResult(session,
                                      (sync_handshake_result) result,
                                      identitiesSharingData);
    }];

    free(identitiesSharingData);

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)trustOwnKeyIdentity:(PEPIdentity * _Nonnull)identity
                      error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = [identity toStruct];

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return trust_own_key(session, ident);
    }];

    free_identity(ident);

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
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
    pEp_identity *ident = [identity toStruct];
    const char *fpr = [[fingerprint precomposedStringWithCanonicalMapping] UTF8String];

    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return key_reset_user(session, ident->user_id, fpr);
    }];

    free_identity(ident);

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:theStatus]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)leaveDeviceGroup:(NSError * _Nullable * _Nullable)error
{
    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return leave_device_group(session);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:status]) {
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

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:theStatus]) {
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

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:(PEPStatus) status]) {
        return NO;
    }
    [PEPSync.sharedInstance handleNewPassphraseConfigured];

    return YES;
}

- (PEPPassphraseCache * _Nonnull)passphraseCache
{
    return [PEPPassphraseCache sharedInstance];
}

- (BOOL)disableAllSyncChannels:(NSError * _Nullable * _Nullable)error
{
    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return disable_all_sync_channels(self.session);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:theStatus]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)syncReinit:(NSError * _Nullable * _Nullable)error
{
    PEPStatus theStatus = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return sync_reinit(self.session);
    }];

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:theStatus]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Media Key / Echo Protocol

stringpair_list_t *stringListFromMediaKeys(NSArray<PEPMediaKeyPair *> *mediaKeys)
{
    stringpair_list_t *engineList = NULL;
    stringpair_list_t *engineListStart = NULL;

    for (PEPMediaKeyPair *pair in mediaKeys) {
        stringpair_t *engineStringPair = new_stringpair([pair.pattern UTF8String],
                                                        [pair.fingerprint UTF8String]);

        engineList = stringpair_list_add(engineList, engineStringPair);

        if (engineListStart == NULL) {
            engineListStart = engineList;
        }
    }

    return engineListStart;
}

- (BOOL)configureMediaKeys:(NSArray<PEPMediaKeyPair *> *)mediaKeys
                     error:(NSError * _Nullable * _Nullable)error
{
    if (error) {
        *error = nil;
    }

    PEPStatus theStatus = (PEPStatus) config_media_keys(self.session,
                                                        stringListFromMediaKeys(mediaKeys));

    if ([PEPStatusNSErrorUtil setError:error fromPEPStatus:theStatus]) {
        return NO;
    }

    return YES;
}

- (void)configureEchoProtocolEnabled:(BOOL)enabled
{
    config_enable_echo_protocol(self.session, enabled);
}

- (void)configureEchoInOutgoingMessageRatingPreviewEnabled:(BOOL)enabled
{
    config_enable_echo_in_outgoing_message_rating_preview(self.session, enabled);
}

@end
