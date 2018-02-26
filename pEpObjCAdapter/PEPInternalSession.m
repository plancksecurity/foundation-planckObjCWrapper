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
- (void)debugOutPutMessageDict:(nonnull PEPDict *)src
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

- (PEP_rating)decryptMessageDict:(nonnull PEPDict *)src
                            dest:(PEPDict * _Nullable * _Nullable)dst
                            keys:(PEPStringList * _Nullable * _Nullable)keys
{
    message *_src = PEP_messageDictToStruct(src);
    message *_dst = NULL;
    stringlist_t *_keys = NULL;
    PEP_rating color = PEP_rating_undefined;
    PEP_decrypt_flags_t flags = 0;

    [self lockWrite];
    decrypt_message(_session, _src, &_dst, &_keys, &color, &flags);
    [self unlockWrite];

    NSDictionary *dst_;

    if (_dst) {
        dst_ = PEP_messageDictFromStruct(_dst);
    }
    else {
        dst_ = PEP_messageDictFromStruct(_src);
    }

    NSArray *keys_ = nil;
    if (_keys)
        keys_ = PEP_arrayFromStringlist(_keys);

    free_message(_src);
    free_message(_dst);
    free_stringlist(_keys);

    if (dst) {
        *dst = dst_;
    }
    if (keys) {
        *keys = keys_;
    }
    return color;
}

- (PEP_rating)decryptMessage:(nonnull PEPMessage *)src
                        dest:(PEPMessage * _Nullable * _Nullable)dst
                        keys:(PEPStringList * _Nullable * _Nullable)keys
{
    PEPDict *destDict;
    PEP_rating rating = [self decryptMessageDict:(PEPDict *)src dest:&destDict keys:keys];

    if (dst) {
        PEPMessage *msg = [PEPMessage new];
        [msg setValuesForKeysWithDictionary:destDict];
        *dst = msg;
    }

    return rating;
}

- (PEP_rating)reEvaluateMessageRating:(nonnull PEPDict *)src
{
    message *_src = PEP_messageDictToStruct(src);
    PEP_rating color = PEP_rating_undefined;

    [self lockWrite];
    re_evaluate_message_rating(_session, _src, NULL, PEP_rating_undefined, &color);
    [self unlockWrite];

    free_message(_src);

    return color;
}

- (PEP_rating)reEvaluateRatingForMessage:(nonnull PEPMessage *)src
{
    return [self reEvaluateMessageRating:(PEPDict *) src];
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

- (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                           extra:(nullable NSArray *)keys
                       encFormat:(PEP_enc_format)encFormat
                            dest:(PEPDict * _Nullable * _Nullable)dst
{
    PEP_STATUS status;
    PEP_encrypt_flags_t flags = 0;

    message *_src = PEP_messageDictToStruct([self removeEmptyRecipients:src]);
    message *_dst = NULL;
    stringlist_t *_keys = PEP_arrayToStringlist(keys);

    [self lockWrite];
    status = encrypt_message(_session, _src, _keys, &_dst, encFormat, flags);
    [self unlockWrite];

    NSDictionary *dst_;

    if (_dst) {
        dst_ = PEP_messageDictFromStruct(_dst);
    }
    else {
        dst_ = PEP_messageDictFromStruct(_src);
    }
    if (dst) {
        *dst = dst_;
    }

    free_message(_src);
    free_message(_dst);
    free_stringlist(_keys);

    return status;
}

- (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                       extra:(nullable PEPStringList *)keys
                        dest:(PEPMessage * _Nullable * _Nullable)dst
{
    return [self encryptMessage:src extra:keys encFormat:PEP_enc_PEP dest:dst];
}

- (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                       extra:(nullable PEPStringList *)keys
                   encFormat:(PEP_enc_format)encFormat
                        dest:(PEPMessage * _Nullable * _Nullable)dst
{
    PEPDict *target;
    PEP_STATUS status = [self encryptMessageDict:(NSDictionary *) src
                                           extra:keys
                                       encFormat: encFormat
                                            dest:&target];
    if (dst) {
        PEPMessage *encrypted = [PEPMessage new];
        [encrypted setValuesForKeysWithDictionary:target];
        *dst = encrypted;
    }
    return status;
}

- (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                        identity:(nonnull PEPIdentity *)identity
                            dest:(PEPDict * _Nullable * _Nullable)dst
{
    PEP_STATUS status;
    PEP_encrypt_flags_t flags = 0;

    message *_src = PEP_messageDictToStruct([self removeEmptyRecipients:src]);
    pEp_identity *ident = PEP_identityToStruct(identity);
    message *_dst = NULL;

    [self lockWrite];
    status = encrypt_message_for_self(_session, ident, _src, &_dst, PEP_enc_PGP_MIME, flags);
    [self unlockWrite];

    NSDictionary *dst_;

    if (_dst) {
        dst_ = PEP_messageDictFromStruct(_dst);
    }
    else {
        dst_ = PEP_messageDictFromStruct(_src);
    }

    if (dst) {
        *dst = dst_;
    }

    free_message(_src);
    free_message(_dst);
    free_identity(ident);

    return status;
}

- (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                    identity:(nonnull PEPIdentity *)identity
                        dest:(PEPMessage * _Nullable * _Nullable)dst
{
    PEPDict *target;
    PEP_STATUS status = [self encryptMessageDict:src.dictionary identity:identity dest:&target];
    if (dst) {
        PEPMessage *encrypted = [PEPMessage new];
        [encrypted setValuesForKeysWithDictionary:target];
        *dst = encrypted;
    }
    return status;
}

- (PEP_rating)outgoingMessageColor:(PEPDict *)msg
{
    message *_msg = PEP_messageDictToStruct(msg);
    PEP_rating color = PEP_rating_undefined;

    [self lockWrite];
    outgoing_message_rating(_session, _msg, &color);
    [self unlockWrite];

    free_message(_msg);

    return color;
}

- (PEP_rating)outgoingColorForMessage:(nonnull PEPMessage *)message
{
    return [self outgoingMessageColor:(NSDictionary *) message];
}

- (PEP_rating)identityRating:(nonnull PEPIdentity *)identity
{
    pEp_identity *ident = PEP_identityToStruct(identity);
    PEP_rating color = PEP_rating_undefined;

    [self lockWrite];
    identity_rating(_session, ident, &color);
    [self unlockWrite];

    free_identity(ident);

    return color;
}

DYNAMIC_API PEP_STATUS identity_rating(PEP_SESSION session, pEp_identity *ident, PEP_rating *color);

- (NSArray *)trustwords:(NSString *)fpr forLanguage:(NSString *)languageID shortened:(BOOL)shortened
{
    NSMutableArray *array = [NSMutableArray array];

    for (int i = 0; i < [fpr length]; i += 4) {
        if (shortened && i >= 20)
            break;

        NSString *str = [fpr substringWithRange:NSMakeRange(i, 4)];

        unsigned int value;
        [[NSScanner scannerWithString:str] scanHexInt:&value];

        char *word;
        size_t size;

        @synchronized (self) {
            trustword(_session, value, [languageID UTF8String], &word, &size);
        }

        [array addObject:[NSString stringWithUTF8String:word]];
        free(word);
    }

    return array;
}

- (void)mySelf:(PEPIdentity *)identity
{
    NSString *userID = identity.userID;
    pEp_identity *ident = PEP_identityToStruct(identity);

    [self lockWrite];
    myself(_session, ident);
    [self unlockWrite];

    [identity reset];
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);

    identity.userID = userID;
}

- (void)updateIdentity:(PEPIdentity *)identity
{
    pEp_identity *ident = PEP_identityToStruct(identity);

    [self lockWrite];
    update_identity(_session, ident);
    [self unlockWrite];

    [identity reset];
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)trustPersonalKey:(PEPIdentity *)identity
{
    pEp_identity *ident = PEP_identityToStruct(identity);

    [self lockWrite];
    trust_personal_key(_session, ident);
    [self unlockWrite];

    [identity reset];
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)keyResetTrust:(PEPIdentity *)identity
{
    pEp_identity *ident = PEP_identityToStruct(identity);

    [self lockWrite];
    key_reset_trust(_session, ident);
    [self unlockWrite];

    [identity reset];
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)keyMistrusted:(PEPIdentity *)identity
{
    pEp_identity *ident = PEP_identityToStruct(identity);

    [self lockWrite];
    key_mistrusted(_session, ident);
    [self unlockWrite];

    [identity reset];
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)importKey:(NSString *)keydata
{
    [self lockWrite];
    import_key(_session, [keydata UTF8String], [keydata length], NULL);
    [self unlockWrite];

}

- (void)logTitle:(nonnull NSString *)title entity:(nonnull NSString *)entity
     description:(nullable NSString *)description comment:(nullable NSString *)comment
{
    [self lockWrite];
    log_event(_session, [[title precomposedStringWithCanonicalMapping] UTF8String],
              [[entity precomposedStringWithCanonicalMapping] UTF8String],
              [[description precomposedStringWithCanonicalMapping] UTF8String],
              [[comment precomposedStringWithCanonicalMapping] UTF8String]);
    [self unlockWrite];
}

- (nullable NSString *)getLog
{
    char *theChars = NULL;
    @synchronized(self) {
        get_crashdump_log(_session, 0, &theChars);
    }

    if (theChars) {
        return [NSString stringWithUTF8String:theChars];
    } else {
        return nil;
    }
}

- (nullable NSString *)getTrustwordsIdentity1:(nonnull PEPIdentity *)identity1
                                    identity2:(nonnull PEPIdentity *)identity2
                                     language:(nullable NSString *)language
                                         full:(BOOL)full
{
    NSString *result = nil;
    char *trustwords = nil;
    size_t sizeWritten = 0;

    pEp_identity *ident1 = PEP_identityToStruct(identity1);
    pEp_identity *ident2 = PEP_identityToStruct(identity2);
    PEP_STATUS status;

    [self lockWrite];
    status = get_trustwords(_session, ident1, ident2,
                            [[language precomposedStringWithCanonicalMapping]
                             UTF8String],
                            &trustwords, &sizeWritten, full);
    [self unlockWrite];

    if (status == PEP_STATUS_OK) {
        result = [NSString stringWithCString:trustwords
                                    encoding:NSUTF8StringEncoding];
    }
    if (trustwords) {
        free(trustwords);
    }
    return result;
}

- (NSArray<PEPLanguage *> * _Nonnull)languageList
{
    char *chLangs;
    @synchronized(self) {
        get_languagelist(_session, &chLangs);
    }
    NSString *parserInput = [NSString stringWithUTF8String:chLangs];

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

- (PEP_STATUS)undoLastMistrust
{
    [self lockWrite];
    PEP_STATUS status = undo_last_mistrust(_session);
    [self unlockWrite];

    return status;
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

- (BOOL)isPEPUser:(PEPIdentity * _Nonnull)identity
{
    pEp_identity *ident = PEP_identityToStruct(identity);
    bool isPEP;
    PEP_STATUS status = is_pep_user(self.session, ident, &isPEP);
    if (status == PEP_STATUS_OK) {
        return isPEP;
    } else {
        return NO;
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
