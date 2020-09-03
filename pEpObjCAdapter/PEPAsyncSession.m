//
//  PEPAsyncSession.m
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 17.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPAsyncSession.h"

#import "PEPMessage.h"
#import "PEPEngineTypes.h"
#import "PEPInternalSession.h"
#import "NSNumber+PEPRating.h"
#import "PEPIdentity.h"
#import "PEPSessionProvider.h"
#import "PEPInternalConstants.h"
#import "NSError+PEP+Internal.h"

static dispatch_queue_t queue;

@interface PEPAsyncSession ()
@end

@implementation PEPAsyncSession

+ (void)initialize
{
    if (self == [PEPAsyncSession class]) {
        dispatch_queue_attr_t attr = DISPATCH_QUEUE_SERIAL;
        attr = dispatch_queue_attr_make_with_qos_class(attr, QOS_CLASS_USER_INITIATED, -1);
        queue = dispatch_queue_create("PEPAsyncSession.queue", attr);
    }
}

+ (void)cleanup
{
    [PEPSessionProvider cleanup];
}

- (void)decryptMessage:(PEPMessage *)message
                 flags:(PEPDecryptFlags)flags
             extraKeys:(PEPStringList * _Nullable)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *dstMessage,
                                 PEPStringList *keyList,
                                 PEPRating rating,
                                 PEPDecryptFlags flags))successCallback
{
    dispatch_async(queue, ^{
        PEPMessage *theMessage = [[PEPMessage alloc] initWithMessage:message];

        PEPDecryptFlags theFlags = flags;
        PEPRating theRating;
        PEPStringList *theExtraKeys = extraKeys;
        PEPStatus status;
        NSError *error = nil;

        PEPMessage *newMessage = [[PEPSessionProvider session] decryptMessage:theMessage
                                                                        flags:&theFlags
                                                                       rating:&theRating
                                                                    extraKeys:&theExtraKeys
                                                                       status:&status
                                                                        error:&error];

        if (newMessage) {
            successCallback(theMessage, newMessage, theExtraKeys, theRating, theFlags);
        } else {
            errorCallback(error);
        }
    });
}

- (void)reEvaluateMessage:(PEPMessage *)message
                 xKeyList:(PEPStringList *_Nullable)xKeyList
                   originalRating:(PEPRating)originalRating
            errorCallback:(void (^)(NSError *error))errorCallback
          successCallback:(void (^)(PEPRating rating))successCallback
{
    dispatch_async(queue, ^{
        PEPRating theRating = originalRating;
        NSError *error = nil;

        BOOL result = [[PEPSessionProvider session]
                       reEvaluateMessage:message
                       xKeyList:xKeyList
                       rating:&theRating
                       status:nil
                       error:&error];

        if (result) {
            successCallback(theRating);
        } else {
            errorCallback(error);
        }
    });
}

- (void)encryptMessage:(PEPMessage *)message
             extraKeys:(PEPStringList * _Nullable)extraKeys
             encFormat:(PEPEncFormat)encFormat
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback
{
    dispatch_async(queue, ^{
        PEPMessage *theMessage = [[PEPMessage alloc] initWithMessage:message];
        NSError *error = nil;
        PEPMessage *destMessage = [[PEPSessionProvider session]
                                   encryptMessage:theMessage
                                   extraKeys:extraKeys
                                   encFormat:encFormat
                                   status:nil
                                   error:&error];
        if (destMessage) {
            successCallback(theMessage, destMessage);
        } else {
            errorCallback(error);
        }
    });
}

- (void)encryptMessage:(PEPMessage *)message
             extraKeys:(PEPStringList * _Nullable)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback
{
    dispatch_async(queue, ^{
        PEPMessage *theMessage = [[PEPMessage alloc] initWithMessage:message];
        NSError *error = nil;
        PEPMessage *destMessage = [[PEPSessionProvider session]
                                   encryptMessage:theMessage
                                   extraKeys:extraKeys
                                   status:nil
                                   error:&error];
        if (destMessage) {
            successCallback(theMessage, destMessage);
        } else {
            errorCallback(error);
        }
    });
}

- (void)encryptMessage:(PEPMessage *)message
               forSelf:(PEPIdentity *)ownIdentity
             extraKeys:(PEPStringList * _Nullable)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback
{
    dispatch_async(queue, ^{
        PEPMessage *theMessage = [[PEPMessage alloc] initWithMessage:message];
        NSError *error = nil;
        PEPMessage *destMessage = [[PEPSessionProvider session]
                                   encryptMessage:theMessage
                                   forSelf:ownIdentity
                                   extraKeys:extraKeys
                                   status:nil
                                   error:&error];
        if (destMessage) {
            successCallback(theMessage, destMessage);
        } else {
            errorCallback(error);
        }
    });
}

- (void)encryptMessage:(PEPMessage *)message
                 toFpr:(NSString *)toFpr
             encFormat:(PEPEncFormat)encFormat
                 flags:(PEPDecryptFlags)flags
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback
{
    dispatch_async(queue, ^{
        PEPMessage *theMessage = [[PEPMessage alloc] initWithMessage:message];
        NSError *error = nil;
        PEPMessage *destMessage = [[PEPSessionProvider session]
                                   encryptMessage:theMessage
                                   toFpr:toFpr
                                   encFormat:encFormat
                                   flags:flags
                                   status:nil
                                   error:&error];
        if (destMessage) {
            successCallback(theMessage, destMessage);
        } else {
            errorCallback(error);
        }
    });
}

- (void)outgoingRatingForMessage:(PEPMessage *)theMessage
                   errorCallback:(void (^)(NSError *error))errorCallback
                 successCallback:(void (^)(PEPRating rating))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSNumber *ratingNum = [[PEPSessionProvider session]
                               outgoingRatingForMessage:theMessage
                               error:&error];
        if (ratingNum) {
            successCallback(ratingNum.pEpRating);
        } else {
            errorCallback(error);
        }
    });
}

- (void)ratingForIdentity:(PEPIdentity *)identity
            errorCallback:(void (^)(NSError *error))errorCallback
          successCallback:(void (^)(PEPRating rating))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSNumber *ratingNum = [[PEPSessionProvider session]
                               ratingForIdentity:identity
                               error:&error];
        if (ratingNum) {
            successCallback(ratingNum.pEpRating);
        } else {
            errorCallback(error);
        }
    });
}

- (void)trustwordsForFingerprint:(NSString *)fingerprint
                      languageID:(NSString *)languageID
                       shortened:(BOOL)shortened
                   errorCallback:(void (^)(NSError *error))errorCallback
                 successCallback:(void (^)(NSArray<NSString *> *trustwords))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSArray *trustwords = [[PEPSessionProvider session]
                               trustwordsForFingerprint:fingerprint
                               languageID:languageID
                               shortened:shortened
                               error:&error];
        if (!error) {
            successCallback(trustwords);
        } else {
            errorCallback(error);
        }
    });
}

- (void)mySelf:(PEPIdentity *)identity
 errorCallback:(void (^)(NSError *error))errorCallback
successCallback:(void (^)(PEPIdentity *identity))successCallback
{
    __block PEPIdentity *theIdentity = [[PEPIdentity alloc] initWithIdentity:identity];

    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] mySelf:theIdentity error:&error];
        if (success) {
            successCallback(theIdentity);
        } else {
            errorCallback(error);
        }
    });
}

- (void)updateIdentity:(PEPIdentity *)identity
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPIdentity *identity))successCallback
{
    __block PEPIdentity *theIdentity = [[PEPIdentity alloc] initWithIdentity:identity];

    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] updateIdentity:theIdentity error:&error];
        if (success) {
            successCallback(theIdentity);
        } else {
            errorCallback(error);
        }
    });
}

- (void)trustPersonalKey:(PEPIdentity *)identity
           errorCallback:(void (^)(NSError *error))errorCallback
         successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] trustPersonalKey:identity error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)keyMistrusted:(PEPIdentity *)identity
        errorCallback:(void (^)(NSError *error))errorCallback
      successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] keyMistrusted:identity error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)keyResetTrust:(PEPIdentity *)identity
        errorCallback:(void (^)(NSError *error))errorCallback
      successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] keyResetTrust:identity error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)enableSyncForIdentity:(PEPIdentity *)identity
                errorCallback:(void (^)(NSError *error))errorCallback
              successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] enableSyncForIdentity:identity error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)disableSyncForIdentity:(PEPIdentity *)identity
                 errorCallback:(void (^)(NSError *error))errorCallback
               successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] disableSyncForIdentity:identity error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)queryKeySyncEnabledForIdentity:(PEPIdentity *)identity
                         errorCallback:(void (^)(NSError *error))errorCallback
                       successCallback:(void (^)(BOOL enabled))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSNumber *boolNum = [[PEPSessionProvider session]
                             queryKeySyncEnabledForIdentity:identity
                             error:&error];
        if (boolNum) {
            successCallback(boolNum.boolValue);
        } else {
            errorCallback(error);
        }
    });
}

- (void)importKey:(NSString *)keydata
    errorCallback:(void (^)(NSError *error))errorCallback
  successCallback:(void (^)(NSArray<PEPIdentity *> *identities))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSArray *identities = [[PEPSessionProvider session] importKey:keydata error:&error];
        if (identities) {
            successCallback(identities);
        } else {
            errorCallback(error);
        }
    });
}

- (void)logTitle:(NSString *)title
          entity:(NSString *)entity
     description:(NSString * _Nullable)description
         comment:(NSString * _Nullable)comment
   errorCallback:(void (^)(NSError *error))errorCallback
 successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] logTitle:title
                                                       entity:entity
                                                  description:description
                                                      comment:comment
                                                        error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}


- (void)getLog:(void (^)(NSError *error))errorCallback
successCallback:(void (^)(NSString *log))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSString *log = [[PEPSessionProvider session] getLogWithError:&error];
        if (log) {
            successCallback(log);
        } else {
            errorCallback(error);
        }
    });
}

- (void)getTrustwordsIdentity1:(PEPIdentity *)identity1
                     identity2:(PEPIdentity *)identity2
                      language:(NSString * _Nullable)language
                          full:(BOOL)full
                 errorCallback:(void (^)(NSError *error))errorCallback
               successCallback:(void (^)(NSString *trustwords))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSString *trustwords = [[PEPSessionProvider session] getTrustwordsIdentity1:identity1
                                                                          identity2:identity2
                                                                           language:language
                                                                               full:full
                                                                              error:&error];
        if (trustwords) {
            successCallback(trustwords);
        } else {
            errorCallback(error);
        }
    });
}

- (void)getTrustwordsFpr1:(NSString *)fpr1
                     fpr2:(NSString *)fpr2
                 language:(NSString * _Nullable)language
                     full:(BOOL)full
            errorCallback:(void (^)(NSError *error))errorCallback
          successCallback:(void (^)(NSString *trustwords))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSString *trustwords = [[PEPSessionProvider session] getTrustwordsFpr1:fpr1
                                                                          fpr2:fpr2
                                                                      language:language
                                                                          full:full
                                                                         error:&error];
        if (trustwords) {
            successCallback(trustwords);
        } else {
            errorCallback(error);
        }
    });
}

- (void)languageList:(void (^)(NSError *error))errorCallback
     successCallback:(void (^)(NSArray<PEPLanguage *> *languages))successCallback

{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSArray *languages = [[PEPSessionProvider session] languageListWithError:&error];
        if (languages) {
            successCallback(languages);
        } else {
            errorCallback(error);
        }
    });
}

- (void)isPEPUser:(PEPIdentity *)identity
    errorCallback:(void (^)(NSError *error))errorCallback
  successCallback:(void (^)(BOOL enabled))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSNumber *ispEpUserNum = [[PEPSessionProvider session] isPEPUser:identity error:&error];
        if (ispEpUserNum) {
            successCallback(ispEpUserNum.boolValue);
        } else {
            errorCallback(error);
        }
    });
}

- (void)setOwnKey:(PEPIdentity *)identity
      fingerprint:(NSString *)fingerprint
    errorCallback:(void (^)(NSError *error))errorCallback
  successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] setOwnKey:identity
                                                   fingerprint:fingerprint
                                                         error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)deliverHandshakeResult:(PEPSyncHandshakeResult)result
             identitiesSharing:(NSArray<PEPIdentity *> * _Nullable)identitiesSharing
                 errorCallback:(void (^)(NSError *error))errorCallback
               successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] deliverHandshakeResult:result
                                                          identitiesSharing:identitiesSharing
                                                                      error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)trustOwnKeyIdentity:(PEPIdentity *)identity
              errorCallback:(void (^)(NSError *error))errorCallback
            successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] trustOwnKeyIdentity:identity error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)keyReset:(PEPIdentity *)identity
     fingerprint:(NSString * _Nullable)fingerprint
   errorCallback:(void (^)(NSError *error))errorCallback
 successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] keyReset:identity
                                                  fingerprint:fingerprint
                                                        error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)leaveDeviceGroup:(void (^)(NSError *error))errorCallback
         successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] leaveDeviceGroup:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)keyResetAllOwnKeys:(void (^)(NSError *error))errorCallback
           successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] keyResetAllOwnKeysError:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

// MARK: - Configuration

- (void)configurePassiveModeEnabled:(BOOL)enabled
{
    PEPInternalSession *session = [PEPSessionProvider session];
    if (session == nil) {
        return;
    }
    return [session configurePassiveModeEnabled:enabled];
}

- (BOOL)configurePassphrase:(NSString * _Nonnull)passphrase
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    PEPInternalSession *session = [PEPSessionProvider session];
    if (session == nil) {
        if (error) {
            *error = [NSError errorWithPEPStatusInternal:PEP_UNKNOWN_ERROR];
        }
        return NO;
    }
    return [session configurePassphrase:passphrase error:error];
}

- (BOOL)configurePassphraseForNewKeys:(NSString * _Nullable)passphrase
                               enable:(BOOL)enable
                                error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    PEPInternalSession *session = [PEPSessionProvider session];
    if (session == nil) {
        if (error) {
            *error = [NSError errorWithPEPStatusInternal:PEP_UNKNOWN_ERROR];
        }
        return NO;
    }
    return [session configurePassphraseForNewKeys:passphrase enable:enable error:error];
}

// MARK: - Methods that can be executed syncronously

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

- (PEPColor)colorFromRating:(PEPRating)rating
{
    PEPInternalSession *session = [PEPSessionProvider session];
    if (session == nil) {
        return PEPColorNoColor;
    }
    return [session colorFromRating:rating];
}

@end
