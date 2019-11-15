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
#import "PEPInternalConstants.h"

@implementation PEPSession

/**
 Macro for causing a return if the given session is nil, optionally setting an error.

 @param session A session object that will be checked for being nil or not.
 @param error If non-nil, will receive PEP_UNKNOWN_ERROR when the session is nil.
 @param what The value to return in case of an error (session is nil).
 */
#define RETURN_ON_ERROR(session, error, what)\
  if (session == nil) { \
    if (error != nil) { \
      *error = [NSError errorWithPEPStatusInternal:PEP_UNKNOWN_ERROR]; \
      return what; \
    } \
  }

#pragma mark - Public API

+ (void)cleanup
{
    [PEPSessionProvider cleanup];
}

- (PEPMessage * _Nullable)decryptMessage:(PEPMessage * _Nonnull)message
                                   flags:(PEPDecryptFlags * _Nullable)flags
                                  rating:(PEPRating * _Nullable)rating
                               extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, nil);
    return [session
            decryptMessage:message
            flags:flags
            rating:rating
            extraKeys:extraKeys
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
    RETURN_ON_ERROR(session, error, NO);
    return [session reEvaluateMessage:message
                             xKeyList:xKeyList
                               rating:rating
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
    RETURN_ON_ERROR(session, error, nil);
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
    RETURN_ON_ERROR(session, error, nil);
    return [session encryptMessage:message extraKeys:extraKeys status:status error:error];
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                                 forSelf:(PEPIdentity * _Nonnull)ownIdentity
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, nil);
    return [session
            encryptMessage:message
            forSelf:ownIdentity
            extraKeys:extraKeys
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
    RETURN_ON_ERROR(session, error, nil);
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
    RETURN_ON_ERROR(session, error, nil);
    return [session outgoingRatingForMessage:theMessage error:error];
}

- (NSNumber * _Nullable)outgoingRatingPreviewForMessage:(PEPMessage * _Nonnull)theMessage
                                                  error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, nil);
    return [session outgoingRatingPreviewForMessage:theMessage error:error];
}

- (NSNumber * _Nullable)ratingForIdentity:(PEPIdentity * _Nonnull)identity
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, nil);
    return [session ratingForIdentity:identity error:error];
}

- (NSArray * _Nullable)trustwordsForFingerprint:(NSString * _Nonnull)fingerprint
                                     languageID:(NSString * _Nonnull)languageID
                                      shortened:(BOOL)shortened
                                          error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, nil);
    return [session
            trustwordsForFingerprint:fingerprint
            languageID:languageID
            shortened:shortened
            error:error];
}

- (BOOL)mySelf:(PEPIdentity * _Nonnull)identity error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
    return [session mySelf:identity error:error];
}

- (BOOL)updateIdentity:(PEPIdentity * _Nonnull)identity
                 error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
    return [session updateIdentity:identity error:error];
}

- (BOOL)trustPersonalKey:(PEPIdentity * _Nonnull)identity
                   error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
    return [session trustPersonalKey:identity error:error];
}

- (BOOL)keyMistrusted:(PEPIdentity * _Nonnull)identity
                error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
    return [session keyMistrusted:identity error:error];
}

- (BOOL)keyResetTrust:(PEPIdentity * _Nonnull)identity
                error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
    return [session keyResetTrust:identity error:error];
}

- (BOOL)enableSyncForIdentity:(PEPIdentity * _Nonnull)identity
                        error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
    return [session enableSyncForIdentity:identity error:error];
}

- (BOOL)disableSyncForIdentity:(PEPIdentity * _Nonnull)identity
                         error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
    return [session disableSyncForIdentity:identity error:error];
}

- (NSNumber * _Nullable)queryKeySyncEnabledForIdentity:(PEPIdentity * _Nonnull)identity
                                                 error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, nil);
    return [session queryKeySyncEnabledForIdentity:identity error:error];
}

#pragma mark Internal API (testing etc.)

- (NSArray * _Nullable)importKey:(NSString * _Nonnull)keydata
                           error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, nil);
    return [session importKey:keydata error:error];
}

- (BOOL)logTitle:(NSString * _Nonnull)title
          entity:(NSString * _Nonnull)entity
     description:(NSString * _Nullable)description
         comment:(NSString * _Nullable)comment
           error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
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
    RETURN_ON_ERROR(session, error, nil);
    return [session getLogWithError:error];
}

- (NSString * _Nullable)getTrustwordsIdentity1:(PEPIdentity * _Nonnull)identity1
                                     identity2:(PEPIdentity * _Nonnull)identity2
                                      language:(NSString * _Nullable)language
                                          full:(BOOL)full
                                         error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, nil);
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
    RETURN_ON_ERROR(session, error, nil);
    return [session getTrustwordsFpr1:fpr1 fpr2:fpr2 language:language full:full error:error];
}

- (NSArray<PEPLanguage *> * _Nullable)languageListWithError:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, nil);
    return [session languageListWithError:error];
}

- (PEPRating)ratingFromString:(NSString * _Nonnull)string
{
    PEPInternalSession *session = [PEPSessionProvider session];
    if (session == nil) {
        return PEPRatingUndefined;
    }
    return [session ratingFromString:string];
}

- (NSString * _Nonnull)stringFromRating:(PEPRating)rating
{
    PEPInternalSession *session = [PEPSessionProvider session];
    if (session == nil) {
        return kUndefined;
    }
    return [session stringFromRating:rating];
}

- (NSNumber * _Nullable)isPEPUser:(PEPIdentity * _Nonnull)identity
                            error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, nil);
    return [session isPEPUser:identity error:error];
}

- (BOOL)setOwnKey:(PEPIdentity * _Nonnull)identity fingerprint:(NSString * _Nonnull)fingerprint
            error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
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
    RETURN_ON_ERROR(session, error, NO);
    return [session setFlags:flags forIdentity:identity error:error];
}

- (BOOL)trustOwnKeyIdentity:(PEPIdentity * _Nonnull)identity
                      error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
    return [session trustOwnKeyIdentity:identity error:error];
}

- (BOOL)deliverHandshakeResult:(PEPSyncHandshakeResult)result
             identitiesSharing:(NSArray<PEPIdentity *> * _Nullable)identitiesSharing
                         error:(NSError * _Nullable * _Nullable)error;
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
    return [session deliverHandshakeResult:result identitiesSharing:identitiesSharing error:error];
}

- (PEPColor)colorFromRating:(PEPRating)rating
{
    PEPInternalSession *session = [PEPSessionProvider session];
    if (session == nil) {
        return PEPColorNoColor;
    }
    return [session colorFromRating:rating];
}

- (BOOL)keyReset:(PEPIdentity * _Nonnull)identity
     fingerprint:(NSString * _Nullable)fingerprint
           error:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
    return [session keyReset:identity fingerprint:fingerprint error:error];
}

- (BOOL)leaveDeviceGroup:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
    return [session leaveDeviceGroup:error];
}

- (BOOL)keyResetAllOwnKeysError:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    RETURN_ON_ERROR(session, error, NO);
    return [session keyResetAllOwnKeysError:error];
}

@end
