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

@implementation PEPSession

#pragma mark - Public API

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Trigger provider to make sure a internal session is kept for the current thread.
        [PEPSessionProvider session];
    }
    return self;
}

- (void)cleanup
{
    [PEPSessionProvider cleanup];
}

- (PEP_rating)decryptMessageDict:(nonnull PEPDict *)src
                            dest:(PEPDict * _Nullable * _Nullable)dst
                            keys:(PEPStringList * _Nullable * _Nullable)keys
{
    return [PEPSession decryptMessageDict:src dest:(PEPDict * _Nullable * _Nullable)dst
                                         keys:(PEPStringList * _Nullable * _Nullable)keys];
}

- (PEP_rating)reEvaluateMessageRating:(nonnull PEPDict *)src
{
    return [PEPSession reEvaluateMessageRating:src];
}

- (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                           extra:(nullable PEPStringList *)keys
                            dest:(PEPDict * _Nullable * _Nullable)dst
{
    return [PEPSession encryptMessageDict:src extra:keys dest:dst];
}

- (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                        identity:(nonnull PEPDict *)identity
                            dest:(PEPDict * _Nullable * _Nullable)dst
{
    return [PEPSession encryptMessageDict:src identity:identity dest:dst];
}

- (PEP_rating)outgoingMessageColor:(nonnull PEPDict *)msg
{
    return [PEPSession outgoingMessageColor:msg];
}

- (PEP_rating)identityRating:(nonnull PEPDict *)identity
{
    return [PEPSession identityRating:identity];
}

- (nonnull NSArray *)trustwords:(nonnull NSString *)fpr forLanguage:(nonnull NSString *)languageID
                      shortened:(BOOL)shortened
{
    return [PEPSession trustwords:fpr forLanguage:languageID shortened:shortened];
}

- (void)mySelf:(nonnull PEPMutableDict *)identity
{
    [PEPSession mySelf:identity];
}

- (void)updateIdentity:(nonnull PEPMutableDict *)identity
{
    [PEPSession updateIdentity:identity];
}

- (void)trustPersonalKey:(nonnull PEPMutableDict *)identity
{
    [PEPSession trustPersonalKey:identity];
}

- (void)keyMistrusted:(nonnull PEPMutableDict *)identity
{
    [PEPSession keyMistrusted:identity];
}

- (void)keyResetTrust:(nonnull PEPMutableDict *)identity
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

- (nonnull NSString *)getLog
{
    return [PEPSession getLog];
}

- (nullable NSString *)getTrustwordsIdentity1:(nonnull PEPDict *)identity1
                                    identity2:(nonnull PEPDict *)identity2
                                     language:(nullable NSString *)language
                                         full:(BOOL)full
{
    return [PEPSession getTrustwordsIdentity1:identity1
                                        identity2:identity2
                                         language:language
                                             full:full];
}

- (nullable NSString *)getTrustwordsMessageDict:(nonnull PEPDict *)messageDict
                                   receiverDict:(nonnull PEPDict *)receiverDict
                                      keysArray:(PEPStringList * _Nullable)keysArray
                                       language:(nullable NSString *)language
                                           full:(BOOL)full
                                resultingStatus:(PEP_STATUS * _Nullable)resultingStatus
{
    return [PEPSession getTrustwordsMessageDict:messageDict
                                       receiverDict:receiverDict
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

#pragma mark - Static 

+ (PEP_rating)decryptMessageDict:(nonnull PEPDict *)src
                            dest:(PEPDict * _Nullable * _Nullable)dst
                            keys:(PEPStringList * _Nullable * _Nullable)keys
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session decryptMessageDict:src dest:dst keys:keys];
}

+ (PEP_rating)reEvaluateMessageRating:(nonnull PEPDict *)src
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session reEvaluateMessageRating:src];
}

+ (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                           extra:(nullable PEPStringList *)keys
                            dest:(PEPDict * _Nullable * _Nullable)dst
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessageDict:src extra:keys dest:dst];
}

+ (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                        identity:(nonnull PEPDict *)identity
                            dest:(PEPDict * _Nullable * _Nullable)dst
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessageDict:src identity:identity dest:dst];
}

+ (PEP_rating)outgoingMessageColor:(nonnull PEPDict *)msg
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session outgoingMessageColor:msg];
}

+ (PEP_rating)identityRating:(nonnull PEPDict *)identity
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

+ (void)mySelf:(nonnull PEPMutableDict *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session mySelf:identity];
}

+ (void)updateIdentity:(nonnull PEPMutableDict *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session updateIdentity:identity];
}

+ (void)trustPersonalKey:(nonnull PEPMutableDict *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session trustPersonalKey:identity];
}

+ (void)keyMistrusted:(nonnull PEPMutableDict *)identity
{
    PEPInternalSession *session = [PEPSessionProvider session];
    [session keyMistrusted:identity];
}

+ (void)keyResetTrust:(nonnull PEPMutableDict *)identity
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

+ (nonnull NSString *)getLog
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session getLog];
}

+ (nullable NSString *)getTrustwordsIdentity1:(nonnull PEPDict *)identity1
                                    identity2:(nonnull PEPDict *)identity2
                                     language:(nullable NSString *)language
                                         full:(BOOL)full
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session getTrustwordsIdentity1:identity1 identity2:identity2 language:language full:full];
}

+ (nullable NSString *)getTrustwordsMessageDict:(nonnull PEPDict *)messageDict
                                   receiverDict:(nonnull PEPDict *)receiverDict
                                      keysArray:(PEPStringList * _Nullable)keysArray
                                       language:(nullable NSString *)language
                                           full:(BOOL)full
                                resultingStatus:(PEP_STATUS * _Nullable)resultingStatus
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session getTrustwordsMessageDict:messageDict receiverDict:receiverDict keysArray:keysArray language:language full:full resultingStatus:resultingStatus];
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

@end
