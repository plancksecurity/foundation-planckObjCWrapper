//
//  PEPSession.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 11.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPSession.h"

#import "PEPInternalSession.h"
#import "PEPSessionProvider.h"
#import "PEPIdentity.h"

@implementation PEPSession

#pragma mark - Public API

+ (void)cleanup
{
    [PEPSessionProvider cleanup];
}

- (PEPDict * _Nullable)decryptMessageDict:(nonnull PEPDict *)src
                                   rating:(PEP_rating * _Nullable)rating
                                     keys:(PEPStringList * _Nullable * _Nullable)keys
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session decryptMessageDict:src rating:rating keys:keys error:error];
}

- (PEPMessage * _Nullable)decryptMessage:(nonnull PEPMessage *)src
                                  rating:(PEP_rating * _Nullable)rating
                                    keys:(PEPStringList * _Nullable * _Nullable)keys
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session decryptMessage:src rating:rating keys:keys error:error];
}

- (BOOL)reEvaluateMessageDict:(nonnull PEPDict *)messageDict
                       rating:(PEP_rating * _Nullable)rating
                        error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session reEvaluateMessageDict:messageDict rating:rating error:error];
}

- (BOOL)reEvaluateMessage:(nonnull PEPMessage *)message
                   rating:(PEP_rating * _Nullable)rating
                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session reEvaluateMessage:message rating:rating error:error];
}

- (PEPDict * _Nullable)encryptMessageDict:(nonnull PEPDict *)src
                                    extraKeys:(nullable PEPStringList *)extraKeys
                                encFormat:(PEP_enc_format)encFormat
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessageDict:src extraKeys:extraKeys encFormat:encFormat error:error];
}

- (PEPMessage * _Nullable)encryptMessage:(nonnull PEPMessage *)src
                                   extraKeys:(nullable PEPStringList *)extraKeys
                               encFormat:(PEP_enc_format)encFormat
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessage:src extraKeys:extraKeys encFormat:encFormat error:error];
}

- (PEPMessage * _Nullable)encryptMessage:(nonnull PEPMessage *)src
                                   extraKeys:(nullable PEPStringList *)extraKeys
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessage:src extraKeys:extraKeys error:error];
}

- (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                        identity:(nonnull PEPIdentity *)identity
                            dest:(PEPDict * _Nullable * _Nullable)dst
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessageDict:src identity:identity dest:dst];
}

- (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                    identity:(nonnull PEPIdentity *)identity
                        dest:(PEPMessage * _Nullable * _Nullable)dst
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessage:src identity:identity dest:dst];
}

- (PEP_rating)outgoingColorForMessage:(nonnull PEPMessage *)message
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session outgoingColorForMessage:message];
}

- (PEP_rating)identityRating:(nonnull PEPIdentity *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session identityRating:identity];
}

- (nonnull NSArray *)trustwords:(nonnull NSString *)fpr forLanguage:(nonnull NSString *)languageID
                      shortened:(BOOL)shortened
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session trustwords:fpr forLanguage:languageID shortened:shortened];
}

- (void)mySelf:(nonnull PEPIdentity *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session mySelf:identity];
}

- (void)updateIdentity:(nonnull PEPIdentity *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session updateIdentity:identity];
}

- (void)trustPersonalKey:(nonnull PEPIdentity *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session trustPersonalKey:identity];
}

- (void)keyMistrusted:(nonnull PEPIdentity *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session keyMistrusted:identity];
}

- (void)keyResetTrust:(nonnull PEPIdentity *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session keyResetTrust:identity];
}

#pragma mark Internal API (testing etc.)

- (void)importKey:(nonnull NSString *)keydata
{
    [PEPSession importKey:keydata];
}

- (void)logTitle:(nonnull NSString *)title entity:(nonnull NSString *)entity
     description:(nullable NSString *)description comment:(nullable NSString *)comment
{
    [PEPSession logTitle:title entity:entity description:description comment:comment];
}

- (nullable NSString *)getLog
{
    return [PEPSession getLog];
}

- (nullable NSString *)getTrustwordsIdentity1:(nonnull PEPIdentity *)identity1
                                    identity2:(nonnull PEPIdentity *)identity2
                                     language:(nullable NSString *)language
                                         full:(BOOL)full
{
    return [PEPSession getTrustwordsIdentity1:identity1
                                        identity2:identity2
                                         language:language
                                             full:full];
}

- (NSArray<PEPLanguage *> * _Nonnull)languageList
{
    return [PEPSession languageList];
}

- (PEP_STATUS)undoLastMistrust
{
    return [PEPSession undoLastMistrust];
}

- (PEP_rating)ratingFromString:(NSString * _Nonnull)string
{
    return [PEPSession ratingFromString:string];
}

- (NSString * _Nonnull)stringFromRating:(PEP_rating)rating
{
    return [PEPSession stringFromRating:rating];
}

- (BOOL)isPEPUser:(PEPIdentity * _Nonnull)identity
{
    return [PEPSession isPEPUser:identity];
}

- (BOOL)setOwnKey:(PEPIdentity * _Nonnull)identity fingerprint:(NSString * _Nonnull)fingerprint
            error:(NSError * _Nullable * _Nullable)error
{
    return [PEPSession setOwnKey:identity fingerprint:fingerprint error:error];
}

#pragma mark Internal API (testing etc.)

+ (void)importKey:(nonnull NSString *)keydata
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session importKey:keydata];
}

+ (void)logTitle:(nonnull NSString *)title entity:(nonnull NSString *)entity
     description:(nullable NSString *)description comment:(nullable NSString *)comment
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session logTitle:title entity:entity description:description comment:comment];
}

+ (nullable NSString *)getLog
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session getLog];
}

+ (nullable NSString *)getTrustwordsIdentity1:(nonnull PEPIdentity *)identity1
                                    identity2:(nonnull PEPIdentity *)identity2
                                     language:(nullable NSString *)language
                                         full:(BOOL)full
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session getTrustwordsIdentity1:identity1 identity2:identity2 language:language full:full];
}

+ (NSArray<PEPLanguage *> * _Nonnull)languageList
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session languageList];
}

+ (PEP_STATUS)undoLastMistrust
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session undoLastMistrust];
}

+ (PEP_rating)ratingFromString:(NSString * _Nonnull)string
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session ratingFromString:string];
}

+ (NSString * _Nonnull)stringFromRating:(PEP_rating)rating
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session stringFromRating:rating];
}

+ (BOOL)isPEPUser:(PEPIdentity * _Nonnull)identity;
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session isPEPUser:identity];
}

+ (BOOL)setOwnKey:(PEPIdentity * _Nonnull)identity fingerprint:(NSString * _Nonnull)fingerprint
            error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session setOwnKey:identity fingerprint:fingerprint error:error];
}

@end
