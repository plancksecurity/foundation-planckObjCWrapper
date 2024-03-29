//
//  PEPSession.m
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 17.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

@import PEPObjCAdapterProtocols;
@import PEPObjCTypeUtils;

#import "PEPSession.h"

#import "PEPInternalSession.h"
#import "PEPInternalSession+TKA.h"
#import "NSNumber+PEPRating.h"
#import "PEPSessionProvider.h"
#import "PEPInternalConstants.h"

static dispatch_queue_t queue;

@implementation PEPSession

+ (void)initialize
{
    if (self == [PEPSession class]) {
        queue = dispatch_queue_create("security.pep.PEPAsyncSession.queue", DISPATCH_QUEUE_SERIAL);
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
                                 PEPDecryptFlags flags,
                                 BOOL isFormerlyEncryptedReuploadedMessage))successCallback
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
            // See IOS-2414 for details
            BOOL isFormerlyEncryptedReuploadedMessage = (status == PEPStatusUnencrypted) && theRating >= PEPRatingUnreliable;
            successCallback(theMessage,
                            newMessage,
                            theExtraKeys,
                            theRating,
                            theFlags,
                            isFormerlyEncryptedReuploadedMessage);
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
        if (ratingNum != nil) {
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
        if (ratingNum != nil) {
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

- (void)importExtraKey:(NSString *)keydata
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(NSArray<NSString *> *fingerprints))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSArray *fingerprints = [[PEPSessionProvider session] importExtraKey:keydata error:&error];
        if (fingerprints) {
            successCallback(fingerprints);
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
        if (ispEpUserNum != nil) {
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
    return [[PEPSessionProvider session] configurePassiveModeEnabled:enabled];
}

- (BOOL)configurePassphrase:(NSString * _Nonnull)passphrase
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    PEPInternalSession *session = [PEPSessionProvider session];
    if (session == nil) {
        if (error) {
            *error = [PEPStatusNSErrorUtil errorWithPEPStatus:PEPStatusUnknownError];
        }
        return NO;
    }
    return [session configurePassphrase:passphrase error:error];
}

- (void)syncReinit:(void (^)(NSError *error))errorCallback
   successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] syncReinit:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
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

- (BOOL)disableAllSyncChannels:(NSError * _Nullable * _Nullable)error
{
    PEPInternalSession *session = [PEPSessionProvider session];
    if (session == nil) {
        if (error) {
            *error = [PEPStatusNSErrorUtil errorWithPEPStatus:PEPStatusUnknownError];
        }
        return NO;
    }
    return [session disableAllSyncChannels:error];
}

// MARK: - TKA

- (void)tkaSubscribeWithKeychangeDelegate:(nullable id<PEPTKADelegate>)delegate
                            errorCallback:(nonnull void (^)(NSError * _Nonnull))errorCallback
                          successCallback:(nonnull void (^)(void))successCallback {
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] tkaSubscribeWithKeychangeDelegate:delegate
                                                                                 error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)tkaRequestTempKeyForMe:(nonnull PEPIdentity *)me
                       partner:(nonnull PEPIdentity *)partner
                 errorCallback:(nonnull void (^)(NSError * _Nonnull))errorCallback
               successCallback:(nonnull void (^)(void))successCallback {
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] tkaRequestTempKeyForMe:me
                                                                    partner:partner
                                                                      error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

#pragma mark - Signing

- (void)signText:(NSString *)stringToSign
   errorCallback:(void (^)(NSError *error))errorCallback
 successCallback:(void (^)(NSString *signature))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSString *signature = [[PEPSessionProvider session] signText:stringToSign error:&error];
        if (signature) {
            successCallback(signature);
        } else {
            errorCallback(error);
        }
    });
}

- (void)verifyText:(NSString *)textToVerify
         signature:(NSString *)signature
     errorCallback:(void (^)(NSError *error))errorCallback
   successCallback:(void (^)(BOOL verified))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL verified;
        BOOL success = [[PEPSessionProvider session] verifyText:textToVerify
                                                      signature:signature
                                                       verified:&verified
                                                          error:&error];
        if (success) {
            successCallback(verified);
        } else {
            errorCallback(error);
        }
    });
}

@end
