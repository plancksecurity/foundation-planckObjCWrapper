//
//  PEPSession.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 08.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "PEPInternalSession.h"
#import "PEPObjCAdapter.h"
#import "PEPObjCAdapter+Internal.h"
#import "PEPMessageUtil.h"
#import "PEPLanguage.h"
#import "PEPCSVScanner.h"
#import "NSArray+Extension.h"
#import "NSDictionary+Extension.h"
#import "PEPIdentity.h"
#import "PEPMessage.h"
#import "NSError+PEP.h"
#import "PEPAutoPointer.h"
#import "NSNumber+PEPRating.h"

@implementation PEPInternalSession

- (instancetype)init
{
    self = [super init];
    if (self) {
        [PEPInternalSession setupTrustWordsDB];

        [self lockWrite];
        PEP_STATUS status = init(&_session);
        [self unlockWrite];

        if (status != PEP_STATUS_OK) {
            return nil;
        }

        [PEPObjCAdapter bindSession:self];
    }
    return self;
}

- (void)dealloc
{
    [PEPObjCAdapter unbindSession:self];

    [self lockWrite];
    release(_session);
    [self unlockWrite];
}

#pragma mark - CONFIG

- (void)configUnencryptedSubjectEnabled:(BOOL)enabled;
{
    config_unencrypted_subject(self.session, enabled);
}

#pragma mark - INTERNAL

- (void)lockWrite
{
    [PEPObjCAdapter lockWrite];
}

- (void)unlockWrite
{
    [PEPObjCAdapter unlockWrite];
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

- (PEPDict * _Nullable)decryptMessageDict:(PEPDict * _Nonnull)messageDict
                                    flags:(PEP_decrypt_flags * _Nullable)flags
                                   rating:(PEP_rating * _Nullable)rating
                                extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                   status:(PEP_STATUS * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error
{
    if (rating) {
        *rating = PEP_rating_undefined;
    }

    message *_src = PEP_messageDictToStruct(messageDict);
    message *_dst = NULL;
    stringlist_t *_keys = NULL;
    PEP_decrypt_flags theFlags = 0;

    if (flags) {
        theFlags = *flags;
    }

    PEP_rating internalRating = PEP_rating_undefined;

    [self lockWrite];
    PEP_STATUS theStatus = decrypt_message(_session,
                                           _src,
                                           &_dst,
                                           &_keys,
                                           &internalRating,
                                           &theFlags);
    [self unlockWrite];

    if (status) {
        *status = theStatus;
    }

    if ([NSError setError:error fromPEPStatus:theStatus]) {
        decryptMessageDictFree(_src, _dst, _keys);
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

    NSArray *keys_ = nil;
    if (_keys)
        keys_ = PEP_arrayFromStringlist(_keys);

    decryptMessageDictFree(_src, _dst, _keys);

    if (extraKeys) {
        *extraKeys = keys_;
    }

    if (rating) {
        *rating = internalRating;
    }

    return dst_;
}

- (PEPMessage * _Nullable)decryptMessage:(PEPMessage * _Nonnull)message
                                   flags:(PEP_decrypt_flags * _Nullable)flags
                                  rating:(PEP_rating * _Nullable)rating
                               extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPDict *destDict = [self
                         decryptMessageDict:(PEPDict *)message
                         flags:flags
                         rating:rating
                         extraKeys:extraKeys
                         status:status
                         error:error];

    if (!destDict) {
        return nil;
    } else {
        PEPMessage *msg = [PEPMessage new];
        [msg setValuesForKeysWithDictionary:destDict];
        return msg;
    }
}

- (BOOL)reEvaluateMessageDict:(PEPDict * _Nonnull)messageDict
                       rating:(PEP_rating * _Nullable)rating
                       status:(PEP_STATUS * _Nullable)status
                        error:(NSError * _Nullable * _Nullable)error
{
    message *_src = PEP_messageDictToStruct(messageDict);
    PEP_rating ratingByEngine = PEP_rating_undefined;

    [self lockWrite];
    PEP_STATUS theStatus = re_evaluate_message_rating(_session,
                                                      _src,
                                                      NULL,
                                                      PEP_rating_undefined,
                                                      &ratingByEngine);
    [self unlockWrite];

    free_message(_src);

    if (status) {
        *status = theStatus;
    }

    if ([NSError setError:error fromPEPStatus:theStatus]) {
        return NO;
    } else {
        if (rating) {
            *rating = ratingByEngine;
        }
        return YES;
    }
}

- (BOOL)reEvaluateMessage:(PEPMessage * _Nonnull)message
                   rating:(PEP_rating * _Nullable)rating
                   status:(PEP_STATUS * _Nullable)status
                    error:(NSError * _Nullable * _Nullable)error
{
    return [self reEvaluateMessageDict:(PEPDict *) message
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
                                encFormat:(PEP_enc_format)encFormat
                                   status:(PEP_STATUS * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEP_encrypt_flags_t flags = 0;

    message *_src = PEP_messageDictToStruct([self removeEmptyRecipients:messageDict]);
    message *_dst = NULL;
    stringlist_t *_keys = PEP_arrayToStringlist(extraKeys);

    [self lockWrite];
    PEP_STATUS theStatus = encrypt_message(_session, _src, _keys, &_dst, encFormat, flags);
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
                               encFormat:(PEP_enc_format)encFormat
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPDict *encryptedDict = [self encryptMessageDict:(NSDictionary *) message
                                            extraKeys:extraKeys
                                            encFormat:encFormat
                                               status:status
                                                error:error];
    PEPMessage *encrypted = [PEPMessage new];
    [encrypted setValuesForKeysWithDictionary:encryptedDict];
    return encrypted;
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                                   extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    return [self
            encryptMessage:message
            extraKeys:extraKeys
            encFormat:PEP_enc_PEP
            status:status
            error:error];
}

- (PEPDict * _Nullable)encryptMessageDict:(PEPDict * _Nonnull)messageDict
                                  forSelf:(PEPIdentity * _Nonnull)ownIdentity
                                extraKeys:(PEPStringList * _Nullable)extraKeys
                                   status:(PEP_STATUS * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEP_encrypt_flags_t flags = 0;

    message *_src = PEP_messageDictToStruct([self removeEmptyRecipients:messageDict]);
    pEp_identity *ident = PEP_identityToStruct(ownIdentity);
    message *_dst = NULL;

    stringlist_t *keysStringList = PEP_arrayToStringlist(extraKeys);

    [self lockWrite];
    PEP_STATUS theStatus = encrypt_message_for_self(_session,
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
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPDict *target = [self
                       encryptMessageDict:message.dictionary
                       forSelf:ownIdentity
                       extraKeys:extraKeys
                       status:status
                       error:error];

    PEPMessage *encrypted = [PEPMessage new];
    [encrypted setValuesForKeysWithDictionary:target];
    return encrypted;
}

- (NSNumber * _Nullable)outgoingRatingForMessageDict:(PEPDict * _Nonnull)messageDict
                                               error:(NSError * _Nullable * _Nullable)error
{
    message *_msg = PEP_messageDictToStruct(messageDict);
    PEP_rating rating = PEP_rating_b0rken;

    [self lockWrite];
    PEP_STATUS status = outgoing_message_rating(_session, _msg, &rating);
    [self unlockWrite];

    free_message(_msg);

    if ([NSError setError:error fromPEPStatus:status]) {
        return nil;
    }

    return [NSNumber numberWithPEPRating:rating];
}

- (NSNumber * _Nullable)outgoingRatingForMessage:(PEPMessage * _Nonnull)message
                                           error:(NSError * _Nullable * _Nullable)error
{
    return [self outgoingRatingForMessageDict:(NSDictionary *) message error:error];
}

- (NSNumber * _Nullable)ratingForIdentity:(PEPIdentity * _Nonnull)identity
                                    error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = PEP_identityToStruct(identity);
    PEP_rating rating = PEP_rating_undefined;

    [self lockWrite];
    PEP_STATUS status = identity_rating(_session, ident, &rating);
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

        PEP_STATUS status = trustword(_session,
                                      value,
                                      [languageID UTF8String],
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
    PEP_STATUS status = myself(_session, ident);
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
        PEP_STATUS status = update_identity(_session, ident);
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
    PEP_STATUS status = trust_personal_key(_session, ident);
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
    PEP_STATUS status = key_mistrusted(_session, ident);
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
    PEP_STATUS status = key_reset_trust(_session, ident);
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

- (BOOL)importKey:(NSString * _Nonnull)keydata error:(NSError * _Nullable * _Nullable)error
{
    [self lockWrite];
    PEP_STATUS status = import_key(_session, [keydata UTF8String], [keydata length], NULL);
    [self unlockWrite];

    if ([NSError setError:error fromPEPStatus:status]) {
        return NO;
    }

    return YES;
}

- (BOOL)logTitle:(NSString * _Nonnull)title
          entity:(NSString * _Nonnull)entity
     description:(NSString * _Nullable)description
         comment:(NSString * _Nullable)comment
           error:(NSError * _Nullable * _Nullable)error
{
    [self lockWrite];
    PEP_STATUS status = log_event(_session,
                                  [[title precomposedStringWithCanonicalMapping] UTF8String],
                                  [[entity precomposedStringWithCanonicalMapping] UTF8String],
                                  [[description precomposedStringWithCanonicalMapping] UTF8String],
                                  [[comment precomposedStringWithCanonicalMapping] UTF8String]);
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
    PEP_STATUS status = get_crashdump_log(_session, 0, &theChars);

    if ([NSError setError:error fromPEPStatus:status]) {
        return nil;
    }

    if (theChars) {
        return [NSString stringWithUTF8String:theChars];
    } else {
        [NSError setError:error fromPEPStatus:PEP_UNKNOWN_ERROR];
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
    PEP_STATUS status;

    PEPAutoPointer *trustwords = [PEPAutoPointer new];
    size_t sizeWritten = 0;

    [self lockWrite];
    status = get_trustwords(_session, ident1, ident2,
                            [[language precomposedStringWithCanonicalMapping]
                             UTF8String],
                            trustwords.charPointerPointer, &sizeWritten, full);
    [self unlockWrite];

    NSString *result = nil;

    if (![NSError setError:error fromPEPStatus:status]) {
        result = [NSString stringWithCString:trustwords.charPointer
                                    encoding:NSUTF8StringEncoding];
    }

    return result;
}

- (NSArray<PEPLanguage *> * _Nullable)languageListWithError:(NSError * _Nullable * _Nullable)error
{
    PEPAutoPointer *chLangs = [PEPAutoPointer new];
    PEP_STATUS status = get_languagelist(_session, chLangs.charPointerPointer);

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

- (BOOL)undoLastMistrustWithError:(NSError * _Nullable * _Nullable)error;
{
    [self lockWrite];
    PEP_STATUS status = undo_last_mistrust(_session);
    [self unlockWrite];

    if ([NSError setError:error fromPEPStatus:status]) {
        return NO;
    }

    return YES;
}

static NSDictionary *ratingToString;
static NSDictionary *stringToRating;

+ (void)initialize
{
    NSDictionary *ratingToStringIntern =
    @{
      [NSNumber numberWithInteger:PEP_rating_cannot_decrypt]: @"cannot_decrypt",
      [NSNumber numberWithInteger:PEP_rating_have_no_key]: @"have_no_key",
      [NSNumber numberWithInteger:PEP_rating_unencrypted]: @"unencrypted",
      [NSNumber numberWithInteger:PEP_rating_unencrypted_for_some]: @"unencrypted_for_some",
      [NSNumber numberWithInteger:PEP_rating_unreliable]: @"unreliable",
      [NSNumber numberWithInteger:PEP_rating_reliable]: @"reliable",
      [NSNumber numberWithInteger:PEP_rating_trusted]: @"trusted",
      [NSNumber numberWithInteger:PEP_rating_trusted_and_anonymized]: @"trusted_and_anonymized",
      [NSNumber numberWithInteger:PEP_rating_fully_anonymous]: @"fully_anonymous",
      [NSNumber numberWithInteger:PEP_rating_mistrust]: @"mistrust",
      [NSNumber numberWithInteger:PEP_rating_b0rken]: @"b0rken",
      [NSNumber numberWithInteger:PEP_rating_under_attack]: @"under_attack",
      [NSNumber numberWithInteger:PEP_rating_undefined]: @"undefined",
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

- (PEP_rating)ratingFromString:(NSString * _Nonnull)string
{
    NSNumber *num = [stringToRating objectForKey:string];
    if (num) {
        return (PEP_rating) [num integerValue];
    } else {
        return PEP_rating_undefined;
    }
}

- (NSString * _Nonnull)stringFromRating:(PEP_rating)rating
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
    PEP_STATUS status = is_pep_user(self.session, ident, &isPEP);

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
    PEP_STATUS status = set_own_key(self.session, ident,
                                    [[fingerprint precomposedStringWithCanonicalMapping]
                                     UTF8String]);
    if (status == PEP_STATUS_OK) {
        return YES;
    } else {
        if (error) {
            *error = [NSError errorWithPEPStatus:status];
        }
        return NO;
    }
}

@end
