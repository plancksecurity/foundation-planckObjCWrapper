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
#import "PEPLock.h"
#import "PEPSync_Internal.h"

#import "key_reset.h"

@implementation PEPInternalSession

- (instancetype)init
{
    self = [super init];
    if (self) {
        [PEPInternalSession setupTrustWordsDB];

        NSError *error = nil;
        _session = [PEPSync createSession:&error];

        if (error) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    [PEPSync releaseSession:_session];
}

#pragma mark - CONFIG

- (void)configUnEncryptedSubjectEnabled:(BOOL)enabled;
{
    config_unencrypted_subject(self.session, enabled);
}

#pragma mark - INTERNAL

- (void)lockWrite
{
    [PEPLock lockWrite];
}

- (void)unlockWrite
{
    [PEPLock unlockWrite];
}

+ (void)setupTrustWordsDB
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [PEPObjCAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];
    });
}

#pragma mark - DEBUG UTILS

/**
 Saves the given message dict as a plist to the local filesystem
 (directly under NSApplicationSupportDirectory).
 Since the complete output file will be logged by `debugSaveToFilePath`,
 you can get access to the files easily when it's the simulator.
 */
- (void)debugOutPutMessageDict:(PEPDict * _Nonnull)src
{
    NSString *from = src[kPepFrom][kPepAddress];
    NSArray *tos = src[kPepTo];
    NSString *to = tos[0][kPepAddress];
    NSString *msgID = src[kPepID];
    NSString *fileName = [NSString stringWithFormat:@"%@_from(%@)_%@",
                          to, from, msgID];
    [src debugSaveToFilePath:fileName];
}

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
    message *_dst = NULL;
    stringlist_t *theKeys = NULL;
    PEPDecryptFlags theFlags = 0;

    if (flags) {
        theFlags = *flags;
    }

    if (extraKeys && [*extraKeys count]) {
        theKeys = PEP_arrayToStringlist(*extraKeys);
    }

    PEPRating internalRating = PEPRatingUndefined;

    [self lockWrite];
    PEPStatus theStatus = (PEPStatus) decrypt_message(_session,
                                                      _src,
                                                      &_dst,
                                                      &theKeys,
                                                      (PEP_rating *) &internalRating,
                                                      (PEP_decrypt_flags *) &theFlags);
    [self unlockWrite];

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

    [self lockWrite];
    PEPStatus theStatus = (PEPStatus) re_evaluate_message_rating(_session,
                                                                 _src,
                                                                 theKeys,
                                                                 (PEP_rating) *rating,
                                                                 (PEP_rating *) rating);
    [self unlockWrite];

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
    PEP_encrypt_flags_t flags = 0;

    message *_src = PEP_messageDictToStruct([self removeEmptyRecipients:messageDict]);
    message *_dst = NULL;
    stringlist_t *_keys = PEP_arrayToStringlist(extraKeys);

    [self lockWrite];
    PEPStatus theStatus = (PEPStatus) encrypt_message(
                                                      _session,
                                                      _src,
                                                      _keys,
                                                      &_dst,
                                                      (PEP_enc_format) encFormat,
                                                      flags);
    [self unlockWrite];

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
    PEP_encrypt_flags_t flags = 0;

    message *_src = PEP_messageDictToStruct([self removeEmptyRecipients:messageDict]);
    pEp_identity *ident = PEP_identityToStruct(ownIdentity);
    message *_dst = NULL;

    stringlist_t *keysStringList = PEP_arrayToStringlist(extraKeys);

    [self lockWrite];
    PEPStatus theStatus = (PEPStatus) encrypt_message_for_self(_session,
                                                               ident,
                                                               _src,
                                                               keysStringList,
                                                               &_dst,
                                                               PEP_enc_PGP_MIME,
                                                               flags);
    [self unlockWrite];

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
    message *dst = NULL;

    [self lockWrite];
    PEPStatus theStatus = (PEPStatus)
    encrypt_message_and_add_priv_key(_session, src, &dst,
                                     [[toFpr precomposedStringWithCanonicalMapping] UTF8String],
                                     (PEP_enc_format) encFormat, flags);
    [self unlockWrite];

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

    [self lockWrite];
    PEPStatus status = (PEPStatus) outgoing_message_rating(_session,
                                                           _msg,
                                                           (PEP_rating *) &rating);
    [self unlockWrite];

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

    [self lockWrite];
    PEPStatus status = (PEPStatus) identity_rating(_session, ident, (PEP_rating *) &rating);
    [self unlockWrite];

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
        size_t size;

        PEPStatus status = (PEPStatus) trustword(_session,
                                                 value,
                                                 [[languageID precomposedStringWithCanonicalMapping]
                                                  UTF8String],
                                                 word.charPointerPointer,
                                                 &size);

        if ([NSError setError:error fromPEPStatus:status]) {
            return nil;
        }

        [array addObject:[NSString stringWithUTF8String:word.charPointer]];
    }

    return array;
}

- (BOOL)mySelf:(PEPIdentity * _Nonnull)identity error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = PEP_identityToStruct(identity);

    [self lockWrite];
    PEPStatus status = (PEPStatus) myself(_session, ident);
    [self unlockWrite];

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

        [self lockWrite];
        PEPStatus status = (PEPStatus) update_identity(_session, ident);
        [self unlockWrite];

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

    [self lockWrite];
    PEPStatus status = (PEPStatus) trust_personal_key(_session, ident);
    [self unlockWrite];

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

    [self lockWrite];
    PEPStatus status = (PEPStatus) key_mistrusted(_session, ident);
    [self unlockWrite];

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
    pEp_identity *ident = PEP_identityToStruct(identity);

    [self lockWrite];
    PEPStatus status = (PEPStatus) key_reset_trust(_session, ident);
    [self unlockWrite];

    if ([NSError setError:error fromPEPStatus:status]) {
        free_identity(ident);
        return NO;
    }

    [identity reset];
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);

    return YES;
}

- (NSArray<PEPIdentity *> * _Nullable)importKey:(NSString * _Nonnull)keydata
                                          error:(NSError * _Nullable * _Nullable)error
{
    identity_list *identList = NULL;

    [self lockWrite];
    PEPStatus status = (PEPStatus) import_key(_session,
                                   [[keydata precomposedStringWithCanonicalMapping] UTF8String],
                                   [keydata length], &identList);
    [self unlockWrite];

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
    [self lockWrite];
    PEPStatus status = (PEPStatus) log_event(_session,
                                             [[title precomposedStringWithCanonicalMapping]
                                              UTF8String],
                                             [[entity precomposedStringWithCanonicalMapping]
                                              UTF8String],
                                             [[description precomposedStringWithCanonicalMapping]
                                              UTF8String],
                                             [[comment precomposedStringWithCanonicalMapping]
                                              UTF8String]);
    [self unlockWrite];

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
        [NSError setError:error fromPEPStatusInternal:PEP_UNKNOWN_ERROR];
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

    [self lockWrite];
    status = (PEPStatus) get_trustwords(_session, ident1, ident2,
                                        [[language precomposedStringWithCanonicalMapping]
                                         UTF8String],
                                        trustwords.charPointerPointer, &sizeWritten, full);
    [self unlockWrite];

    free_identity(ident1);
    free_identity(ident2);

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
      [NSNumber numberWithInteger:PEPRatingUndefined]: @"undefined",
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
        return @"undefined";
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

    if (status == PEPStatusOK) {
        return YES;
    } else {
        if (error) {
            *error = [NSError errorWithPEPStatus:status];
        }
        return NO;
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
    free_identity(ident);

    if (status == PEPStatusOK) {
        return YES;
    } else {
        if (error) {
            *error = [NSError errorWithPEPStatus:status];
        }
        return NO;
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

    if (status == PEPStatusOK) {
        return YES;
    } else {
        if (error) {
            *error = [NSError errorWithPEPStatus:status];
        }
        return NO;
    }
}

- (BOOL)trustOwnKeyIdentity:(PEPIdentity * _Nonnull)identity
                      error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = PEP_identityToStruct(identity);
    PEPStatus status = (PEPStatus) trust_own_key(self.session, ident);
    free_identity(ident);

    if (status == PEPStatusOK) {
        return YES;
    } else {
        if (error) {
            *error = [NSError errorWithPEPStatus:status];
        }
        return NO;
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

    PEPStatus status = (PEPStatus) key_reset_identity(self.session, ident, fpr);

    free_identity(ident);

    if (status == PEPStatusOK) {
        return YES;
    } else {
        if (error) {
            *error = [NSError errorWithPEPStatus:status];
        }
        return NO;
    }
}

- (BOOL)leaveDeviceGroupError:(NSError * _Nullable * _Nullable)error
{
    PEPStatus status = (PEPStatus) leave_device_group(self.session);

    if (status == PEPStatusOK) {
        return YES;
    } else {
        if (error) {
            *error = [NSError errorWithPEPStatus:status];
        }
        return NO;
    }
}

@end
