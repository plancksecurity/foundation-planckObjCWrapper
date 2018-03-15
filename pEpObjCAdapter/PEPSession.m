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

- (PEPDict * _Nullable)decryptMessageDict:(nonnull PEPDict *)messageDict
                                   rating:(PEP_rating * _Nullable)rating
                                extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                   status:(PEP_STATUS * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session
            decryptMessageDict:messageDict
            rating:rating
            extraKeys:extraKeys
            status:status
            error:error];
}

- (PEPMessage * _Nullable)decryptMessage:(nonnull PEPMessage *)message
                                  rating:(PEP_rating * _Nullable)rating
                               extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session
            decryptMessage:message
            rating:rating
            extraKeys:extraKeys
            status:status
            error:error];
}

- (BOOL)reEvaluateMessageDict:(nonnull PEPDict *)messageDict
                       rating:(PEP_rating * _Nullable)rating
                       status:(PEP_STATUS * _Nullable)status
                        error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session reEvaluateMessageDict:messageDict rating:rating status:status error:error];
}

- (BOOL)reEvaluateMessage:(nonnull PEPMessage *)message
                   rating:(PEP_rating * _Nullable)rating
                   status:(PEP_STATUS * _Nullable)status
                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session reEvaluateMessage:message rating:rating status:status error:error];
}

- (PEPDict * _Nullable)encryptMessageDict:(nonnull PEPDict *)messageDict
                                    extraKeys:(nullable PEPStringList *)extraKeys
                                encFormat:(PEP_enc_format)encFormat
                                   status:(PEP_STATUS * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session
            encryptMessageDict:messageDict
            extraKeys:extraKeys
            encFormat:encFormat
            status:status
            error:error];
}

- (PEPMessage * _Nullable)encryptMessage:(nonnull PEPMessage *)message
                               extraKeys:(nullable PEPStringList *)extraKeys
                               encFormat:(PEP_enc_format)encFormat
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session
            encryptMessage:message
            extraKeys:extraKeys
            encFormat:encFormat
            status:status
            error:error];
}

- (PEPMessage * _Nullable)encryptMessage:(nonnull PEPMessage *)message
                               extraKeys:(nullable PEPStringList *)extraKeys
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessage:message extraKeys:extraKeys status:status error:error];
}

- (PEPDict * _Nullable)encryptMessageDict:(nonnull PEPDict *)messageDict
                                 identity:(nonnull PEPIdentity *)identity
                                   status:(PEP_STATUS * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessageDict:messageDict identity:identity status:status error:error];
}

- (PEPMessage * _Nullable)encryptMessage:(nonnull PEPMessage *)message
                                identity:(nonnull PEPIdentity *)identity
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessage:message identity:identity status:status error:error];
}

- (BOOL)outgoingRating:(PEP_rating * _Nonnull)rating
            forMessage:(PEPMessage * _Nonnull)message
                 error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session outgoingRating:rating forMessage:message error:error];
}

- (BOOL)rating:(PEP_rating * _Nonnull)rating
   forIdentity:(PEPIdentity * _Nonnull)identity
         error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session rating:rating forIdentity:identity error:error];
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
