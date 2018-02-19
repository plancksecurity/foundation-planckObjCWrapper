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

- (PEP_rating)decryptMessageDict:(nonnull PEPDict *)src
                            dest:(PEPDict * _Nullable * _Nullable)dst
                            keys:(PEPStringList * _Nullable * _Nullable)keys
{
    return [PEPSession decryptMessageDict:src dest:dst keys:keys];
}

- (PEP_rating)decryptMessage:(nonnull PEPMessage *)src
                        dest:(PEPMessage * _Nullable * _Nullable)dst
                        keys:(PEPStringList * _Nullable * _Nullable)keys
{
    return [PEPSession decryptMessage:src dest:dst keys:keys];
}

- (PEP_rating)reEvaluateMessageRating:(nonnull PEPDict *)src
{
    return [PEPSession reEvaluateMessageRating:src];
}

- (PEP_rating)reEvaluateRatingForMessage:(nonnull PEPMessage *)src
{
    return [PEPSession reEvaluateRatingForMessage:src];
}

- (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                           extra:(nullable PEPStringList *)keys
                       encFormat:(PEP_enc_format)encFormat
                            dest:(PEPDict * _Nullable * _Nullable)dst
{
    return [PEPSession encryptMessageDict:src extra:keys encFormat:encFormat dest:dst];
}

- (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                       extra:(nullable PEPStringList *)keys
                        dest:(PEPMessage * _Nullable * _Nullable)dst
{
    return [PEPSession encryptMessage:src extra:keys dest:dst];
}

- (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                       extra:(nullable PEPStringList *)keys
                   encFormat:(PEP_enc_format)encFormat
                        dest:(PEPMessage * _Nullable * _Nullable)dst
{
    return [PEPSession encryptMessage:src extra:keys encFormat:encFormat dest:dst];
}

- (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                        identity:(nonnull PEPIdentity *)identity
                            dest:(PEPDict * _Nullable * _Nullable)dst
{
    return [PEPSession encryptMessageDict:src identity:identity dest:dst];
}

- (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                    identity:(nonnull PEPIdentity *)identity
                        dest:(PEPMessage * _Nullable * _Nullable)dst
{
    return [PEPSession encryptMessage:src identity:identity dest:dst];
}

- (PEP_rating)outgoingColorForMessage:(nonnull PEPMessage *)message
{
    return [PEPSession outgoingColorForMessage:message];
}

- (PEP_rating)identityRating:(nonnull PEPIdentity *)identity
{
    return [PEPSession identityRating:identity];
}

- (nonnull NSArray *)trustwords:(nonnull NSString *)fpr forLanguage:(nonnull NSString *)languageID
                      shortened:(BOOL)shortened
{
    return [PEPSession trustwords:fpr forLanguage:languageID shortened:shortened];
}

- (void)mySelf:(nonnull PEPIdentity *)identity
{
    [PEPSession mySelf:identity];
}

- (void)updateIdentity:(nonnull PEPIdentity *)identity
{
    if (identity.isOwn) {
        [PEPSession mySelf:identity];
    } else {
        [PEPSession updateIdentity:identity];
    }
}

- (void)trustPersonalKey:(nonnull PEPIdentity *)identity
{
    [PEPSession trustPersonalKey:identity];
}

- (void)keyMistrusted:(nonnull PEPIdentity *)identity
{
    [PEPSession keyMistrusted:identity];
}

- (void)keyResetTrust:(nonnull PEPIdentity *)identity
{
    [PEPSession keyResetTrust:identity];
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

- (nullable NSString *)getTrustwordsMessageDict:(nonnull PEPDict *)messageDict
                                   receiver:(nonnull PEPIdentity *)receiver
                                      keysArray:(PEPStringList * _Nullable)keysArray
                                       language:(nullable NSString *)language
                                           full:(BOOL)full
                                resultingStatus:(PEP_STATUS * _Nullable)resultingStatus
{
    return [PEPSession getTrustwordsMessageDict:messageDict
                                       receiver:receiver
                                          keysArray:keysArray
                                           language:language
                                               full:full
                                    resultingStatus:resultingStatus];
}

- (nullable NSString *)getTrustwordsForMessage:(nonnull PEPMessage *)message
                                      receiver:(nonnull PEPIdentity *)receiver
                                     keysArray:(PEPStringList * _Nullable)keysArray
                                      language:(nullable NSString *)language
                                          full:(BOOL)full
                               resultingStatus:(PEP_STATUS * _Nullable)resultingStatus
{
    return [PEPSession getTrustwordsForMessage:message
                                      receiver:receiver
                                     keysArray:keysArray
                                      language:language
                                          full:full
                               resultingStatus:resultingStatus];
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

#pragma mark - Static

+ (PEP_rating)decryptMessageDict:(nonnull PEPDict *)src
                            dest:(PEPDict * _Nullable * _Nullable)dst
                            keys:(PEPStringList * _Nullable * _Nullable)keys
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session decryptMessageDict:src dest:dst keys:keys];
}

+ (PEP_rating)decryptMessage:(nonnull PEPMessage *)src
                        dest:(PEPMessage * _Nullable * _Nullable)dst
                        keys:(PEPStringList * _Nullable * _Nullable)keys
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session decryptMessage:src dest:dst keys:keys];
}

+ (PEP_rating)reEvaluateMessageRating:(nonnull PEPDict *)src
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session reEvaluateMessageRating:src];
}

+ (PEP_rating)reEvaluateRatingForMessage:(nonnull PEPMessage *)src
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session reEvaluateRatingForMessage:src];
}

+ (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                           extra:(nullable PEPStringList *)keys
                       encFormat:(PEP_enc_format)encFormat
                            dest:(PEPDict * _Nullable * _Nullable)dst
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessageDict:src extra:keys encFormat:encFormat dest:dst];
}

+ (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                           extra:(nullable PEPStringList *)keys
                            dest:(PEPMessage * _Nullable * _Nullable)dst
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessage:src extra:keys dest:dst];
}

+ (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                       extra:(nullable PEPStringList *)keys
                   encFormat:(PEP_enc_format)encFormat
                        dest:(PEPMessage * _Nullable * _Nullable)dst
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessage:src extra:keys encFormat:encFormat dest:dst];
}

+ (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                        identity:(nonnull PEPIdentity *)identity
                            dest:(PEPDict * _Nullable * _Nullable)dst
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessageDict:src identity:identity dest:dst];
}

+ (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                    identity:(nonnull PEPIdentity *)identity
                        dest:(PEPMessage * _Nullable * _Nullable)dst
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessage:src identity:identity dest:dst];
}

+ (PEP_rating)outgoingColorForMessage:(nonnull PEPMessage *)message
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session outgoingColorForMessage:message];
}

+ (PEP_rating)identityRating:(nonnull PEPIdentity *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session identityRating:identity];
}

+ (nonnull NSArray *)trustwords:(nonnull NSString *)fpr forLanguage:(nonnull NSString *)languageID
                      shortened:(BOOL)shortened
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session trustwords:fpr forLanguage:languageID shortened:shortened];
}

+ (void)mySelf:(nonnull PEPIdentity *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session mySelf:identity];
}

+ (void)updateIdentity:(nonnull PEPIdentity *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session updateIdentity:identity];
}

+ (void)trustPersonalKey:(nonnull PEPIdentity *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session trustPersonalKey:identity];
}

+ (void)keyMistrusted:(nonnull PEPIdentity *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session keyMistrusted:identity];
}

+ (void)keyResetTrust:(nonnull PEPIdentity *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session keyResetTrust:identity];
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

+ (nullable NSString *)getTrustwordsMessageDict:(nonnull PEPDict *)messageDict
                                   receiver:(nonnull PEPIdentity *)receiver
                                      keysArray:(PEPStringList * _Nullable)keysArray
                                       language:(nullable NSString *)language
                                           full:(BOOL)full
                                resultingStatus:(PEP_STATUS * _Nullable)resultingStatus
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session getTrustwordsMessageDict:messageDict receiver:receiver keysArray:keysArray language:language full:full resultingStatus:resultingStatus];
}

+ (nullable NSString *)getTrustwordsForMessage:(nonnull PEPMessage *)message
                                      receiver:(nonnull PEPIdentity *)receiver
                                     keysArray:(PEPStringList * _Nullable)keysArray
                                      language:(nullable NSString *)language
                                          full:(BOOL)full
                               resultingStatus:(PEP_STATUS * _Nullable)resultingStatus
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session getTrustwordsForMessage:message receiver:receiver keysArray:keysArray
                                   language:language full:full resultingStatus:resultingStatus];
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

@end
