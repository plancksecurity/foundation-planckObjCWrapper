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

- (PEPDict * _Nullable)decryptMessageDict:(PEPDict * _Nonnull)messageDict
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

- (PEPMessage * _Nullable)decryptMessage:(PEPMessage * _Nonnull)message
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

- (BOOL)reEvaluateMessageDict:(PEPDict * _Nonnull)messageDict
                       rating:(PEP_rating * _Nullable)rating
                       status:(PEP_STATUS * _Nullable)status
                        error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session reEvaluateMessageDict:messageDict rating:rating status:status error:error];
}

- (BOOL)reEvaluateMessage:(PEPMessage * _Nonnull)message
                   rating:(PEP_rating * _Nullable)rating
                   status:(PEP_STATUS * _Nullable)status
                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session reEvaluateMessage:message rating:rating status:status error:error];
}

- (PEPDict * _Nullable)encryptMessageDict:(PEPDict * _Nonnull)messageDict
                                    extraKeys:(PEPStringList * _Nullable)extraKeys
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

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
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

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessage:message extraKeys:extraKeys status:status error:error];
}

- (PEPDict * _Nullable)encryptMessageDict:(PEPDict * _Nonnull)messageDict
                                  forSelf:(PEPIdentity * _Nonnull)ownIdentity
                                extraKeys:(PEPStringList * _Nullable)extraKeys
                                   status:(PEP_STATUS * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session
            encryptMessageDict:messageDict
            forSelf:ownIdentity
            extraKeys:extraKeys
            status:status
            error:error];
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                                 forSelf:(PEPIdentity * _Nonnull)ownIdentity
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session
            encryptMessage:message
            forSelf:ownIdentity
            extraKeys:extraKeys
            status:status
            error:error];
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

- (NSArray * _Nullable)trustwordsForFingerprint:(NSString * _Nonnull)fingerprint
                                     languageID:(NSString * _Nonnull)languageID
                                      shortened:(BOOL)shortened
                                          error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session
            trustwordsForFingerprint:fingerprint
            languageID:languageID
            shortened:shortened
            error:error];
}

- (BOOL)mySelf:(PEPIdentity * _Nonnull)identity error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session mySelf:identity error:error];
}

- (BOOL)updateIdentity:(PEPIdentity * _Nonnull)identity
                 error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session updateIdentity:identity error:error];
}

- (BOOL)trustPersonalKey:(PEPIdentity * _Nonnull)identity
                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session trustPersonalKey:identity error:error];
}

- (BOOL)keyMistrusted:(PEPIdentity * _Nonnull)identity
                error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session keyMistrusted:identity error:error];
}

- (BOOL)keyResetTrust:(PEPIdentity * _Nonnull)identity
                error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session keyResetTrust:identity error:error];
}

#pragma mark Internal API (testing etc.)

- (BOOL)importKey:(NSString * _Nonnull)keydata error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session importKey:keydata error:error];
}

- (BOOL)logTitle:(NSString * _Nonnull)title
          entity:(NSString * _Nonnull)entity
     description:(NSString * _Nullable)description
         comment:(NSString * _Nullable)comment
           error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session
            logTitle:title
            entity:entity
            description:description
            comment:comment
            error:error];
}

- (NSString * _Nullable)getLogWithError:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session getLogWithError:error];
}

- (NSString * _Nullable)getTrustwordsIdentity1:(PEPIdentity * _Nonnull)identity1
                                     identity2:(PEPIdentity * _Nonnull)identity2
                                      language:(NSString * _Nullable)language
                                          full:(BOOL)full
                                         error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session getTrustwordsIdentity1:identity1
                                 identity2:identity2
                                  language:language
                                      full:full
                                     error:error];
}

- (NSArray<PEPLanguage *> * _Nullable)languageListWithError:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session languageListWithError:error];
}

- (BOOL)undoLastMistrustWithError:(NSError * _Nullable * _Nullable)error;
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session undoLastMistrustWithError:error];
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
