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

#import "PEPMessageUtil.h"
#import "NSNumber+PEPRating.h"
#import "NSError+PEP+Internal.h"

@implementation PEPSession

#define RETURN_NIL_ON_ERROR(session, error)\
 if (session == nil) { \
   if (error != nil) { \
     *error = [NSError errorWithPEPStatusInternal:PEP_UNKNOWN_ERROR]; \
     return nil; \
   } \
 }

#pragma mark - Public API

+ (void)cleanup
{
    [PEPSessionProvider cleanup];
}

- (PEPDict * _Nullable)decryptMessageDict:(PEPMutableDict * _Nonnull)messageDict
                                    flags:(PEPDecryptFlags * _Nullable)flags
                                   rating:(PEPRating * _Nullable)rating
                                extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                   status:(PEPStatus * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session
            decryptMessageDict:messageDict
            flags:flags
            rating:rating
            extraKeys:extraKeys
            status:status
            error:error];
}

- (PEPMessage * _Nullable)decryptMessage:(PEPMessage * _Nonnull)message
                                   flags:(PEPDecryptFlags * _Nullable)flags
                                  rating:(PEPRating * _Nullable)rating
                               extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session
            decryptMessage:message
            flags:flags
            rating:rating
            extraKeys:extraKeys
            status:status
            error:error];
}

- (BOOL)reEvaluateMessageDict:(PEPDict * _Nonnull)messageDict
                     xKeyList:(PEPStringList * _Nullable)xKeyList
                       rating:(PEPRating * _Nonnull)rating
                       status:(PEPStatus * _Nullable)status
                        error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session reEvaluateMessageDict:messageDict
                                 xKeyList:xKeyList
                                   rating:rating
                                   status:status
                                    error:error];
}

- (BOOL)reEvaluateMessage:(PEPMessage * _Nonnull)message
                 xKeyList:(PEPStringList * _Nullable)xKeyList
                   rating:(PEPRating * _Nonnull)rating
                   status:(PEPStatus * _Nullable)status
                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session reEvaluateMessage:message
                             xKeyList:xKeyList
                               rating:rating
                               status:status
                                error:error];
}

- (PEPDict * _Nullable)encryptMessageDict:(PEPDict * _Nonnull)messageDict
                                    extraKeys:(PEPStringList * _Nullable)extraKeys
                                encFormat:(PEPEncFormat)encFormat
                                   status:(PEPStatus * _Nullable)status
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
                               encFormat:(PEPEncFormat)encFormat
                                  status:(PEPStatus * _Nullable)status
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
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session encryptMessage:message extraKeys:extraKeys status:status error:error];
}

- (PEPDict * _Nullable)encryptMessageDict:(PEPDict * _Nonnull)messageDict
                                  forSelf:(PEPIdentity * _Nonnull)ownIdentity
                                extraKeys:(PEPStringList * _Nullable)extraKeys
                                   status:(PEPStatus * _Nullable)status
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
                                  status:(PEPStatus * _Nullable)status
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

- (PEPDict * _Nullable)encryptMessageDict:(PEPDict * _Nonnull)messageDict
                                    toFpr:(NSString * _Nonnull)toFpr
                                encFormat:(PEPEncFormat)encFormat
                                    flags:(PEPDecryptFlags)flags
                                   status:(PEPStatus * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error __deprecated
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session
            encryptMessageDict:messageDict
            toFpr:toFpr
            encFormat:encFormat
            flags:flags
            status:status
            error:error];
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                                   toFpr:(NSString * _Nonnull)toFpr
                               encFormat:(PEPEncFormat)encFormat
                                   flags:(PEPDecryptFlags)flags
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session
            encryptMessage:message
            toFpr:toFpr
            encFormat:encFormat
            flags:flags
            status:status
            error:error];
}

- (NSNumber * _Nullable)outgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                                           error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session outgoingRatingForMessage:theMessage error:error];
}

- (NSNumber * _Nullable)outgoingRatingPreviewForMessage:(PEPMessage * _Nonnull)theMessage
                                                  error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session outgoingRatingPreviewForMessage:theMessage error:error];
}

- (NSNumber * _Nullable)ratingForIdentity:(PEPIdentity * _Nonnull)identity
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session ratingForIdentity:identity error:error];
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

- (NSArray * _Nullable)importKey:(NSString * _Nonnull)keydata
                           error:(NSError * _Nullable * _Nullable)error
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

- (NSString * _Nullable)getTrustwordsFpr1:(NSString * _Nonnull)fpr1
                                     fpr2:(NSString * _Nonnull)fpr2
                                 language:(NSString * _Nullable)language
                                     full:(BOOL)full
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session getTrustwordsFpr1:fpr1 fpr2:fpr2 language:language full:full error:error];
}

- (NSArray<PEPLanguage *> * _Nullable)languageListWithError:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session languageListWithError:error];
}

- (PEPRating)ratingFromString:(NSString * _Nonnull)string
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session ratingFromString:string];
}

- (NSString * _Nonnull)stringFromRating:(PEPRating)rating
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session stringFromRating:rating];
}

- (NSNumber * _Nullable)isPEPUser:(PEPIdentity * _Nonnull)identity
                            error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session isPEPUser:identity error:error];
}

- (BOOL)setOwnKey:(PEPIdentity * _Nonnull)identity fingerprint:(NSString * _Nonnull)fingerprint
            error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session setOwnKey:identity fingerprint:fingerprint error:error];
}

- (void)configurePassiveModeEnabled:(BOOL)enabled
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session configurePassiveModeEnabled:enabled];
}

- (BOOL)setFlags:(PEPIdentityFlags)flags
     forIdentity:(PEPIdentity *)identity
           error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session setFlags:flags forIdentity:identity error:error];
}

- (BOOL)trustOwnKeyIdentity:(PEPIdentity * _Nonnull)identity
                      error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session trustOwnKeyIdentity:identity error:error];
}

- (BOOL)deliverHandshakeResult:(PEPSyncHandshakeResult)result
             identitiesSharing:(NSArray<PEPIdentity *> * _Nullable)identitiesSharing
                         error:(NSError * _Nullable * _Nullable)error;
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session deliverHandshakeResult:result identitiesSharing:identitiesSharing error:error];
}

- (PEPColor)colorFromRating:(PEPRating)rating
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session colorFromRating:rating];
}

- (BOOL)keyReset:(PEPIdentity * _Nonnull)identity
     fingerprint:(NSString * _Nullable)fingerprint
           error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session keyReset:identity fingerprint:fingerprint error:error];
}

- (BOOL)leaveDeviceGroupError:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    return [session leaveDeviceGroupError:error];
}

@end
