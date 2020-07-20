//
//  PEPAsyncSession.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 17.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPEngineTypes.h"
#import "PEPTypes.h"

@class PEPMessage;
@class PEPIdentity;
@class PEPLanguage;

NS_ASSUME_NONNULL_BEGIN

@interface PEPAsyncSession : NSObject

- (instancetype)init;

- (void)decryptMessage:(PEPMessage *)message
                 flags:(PEPDecryptFlags)flags
             extraKeys:(PEPStringList * _Nullable)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *dstMessage,
                                 PEPStringList *keyList,
                                 PEPRating rating,
                                 PEPDecryptFlags flags))successCallback;

- (void)reEvaluateMessage:(PEPMessage *)message
                 xKeyList:(PEPStringList *_Nullable)xKeyList
                   rating:(PEPRating)originalRating
            errorCallback:(void (^)(NSError *error))errorCallback
          successCallback:(void (^)(PEPRating rating))successCallback;

/// Encrypt a message with explicit encryption format.
- (void)encryptMessage:(PEPMessage *)message
             extraKeys:(PEPStringList * _Nullable)extraKeys
             encFormat:(PEPEncFormat)encFormat
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback;

/// Encrypt a message with the default encryption format.
- (void)encryptMessage:(PEPMessage *)message
             extraKeys:(PEPStringList * _Nullable)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback;

/// Encrypt a message to an own identity.
- (void)encryptMessage:(PEPMessage *)message
               forSelf:(PEPIdentity *)ownIdentity
             extraKeys:(PEPStringList * _Nullable)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback;

/// Encrypt a message to a fingerprint.
- (void)encryptMessage:(PEPMessage *)message
                 toFpr:(NSString *)toFpr
             encFormat:(PEPEncFormat)encFormat
                 flags:(PEPDecryptFlags)flags
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback;

- (void)outgoingRatingForMessage:(PEPMessage *)theMessage
                   errorCallback:(void (^)(NSError *error))errorCallback
                 successCallback:(void (^)(PEPRating rating))successCallback;

- (void)ratingForIdentity:(PEPIdentity *)identity
            errorCallback:(void (^)(NSError *error))errorCallback
          successCallback:(void (^)(PEPRating rating))successCallback;

- (void)trustwordsForFingerprint:(NSString *)fingerprint
                      languageID:(NSString *)languageID
                       shortened:(BOOL)shortened
                   errorCallback:(void (^)(NSError *error))errorCallback
                 successCallback:(void (^)(NSArray<NSString *> *trustwords))successCallback;

- (void)mySelf:(PEPIdentity *)identity
 errorCallback:(void (^)(NSError *error))errorCallback
successCallback:(void (^)(PEPIdentity *identity))successCallback;

- (void)updateIdentity:(PEPIdentity *)identity
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPIdentity *identity))successCallback;

- (void)trustPersonalKey:(PEPIdentity *)identity
           errorCallback:(void (^)(NSError *error))errorCallback
         successCallback:(void (^)(void))successCallback;

- (void)keyMistrusted:(PEPIdentity *)identity
        errorCallback:(void (^)(NSError *error))errorCallback
      successCallback:(void (^)(void))successCallback;

- (void)keyResetTrust:(PEPIdentity *)identity
        errorCallback:(void (^)(NSError *error))errorCallback
      successCallback:(void (^)(void))successCallback;

- (void)enableSyncForIdentity:(PEPIdentity *)identity
                errorCallback:(void (^)(NSError *error))errorCallback
              successCallback:(void (^)(void))successCallback;

- (void)disableSyncForIdentity:(PEPIdentity *)identity
                 errorCallback:(void (^)(NSError *error))errorCallback
               successCallback:(void (^)(void))successCallback;

- (void)queryKeySyncEnabledForIdentity:(PEPIdentity *)identity
                         errorCallback:(void (^)(NSError *error))errorCallback
                       successCallback:(void (^)(BOOL enabled))successCallback;

- (void)importKey:(NSString *)keydata
    errorCallback:(void (^)(NSError *error))errorCallback
  successCallback:(void (^)(NSArray<PEPIdentity *> *identities))successCallback;

- (void)getLog:(void (^)(NSError *error))errorCallback
successCallback:(void (^)(NSString *log))successCallback;

- (void)getTrustwordsIdentity1:(PEPIdentity *)identity1
                     identity2:(PEPIdentity *)identity2
                      language:(NSString * _Nullable)language
                          full:(BOOL)full
                 errorCallback:(void (^)(NSError *error))errorCallback
               successCallback:(void (^)(NSString *trustwords))successCallback;

- (void)getTrustwordsFpr1:(NSString *)fpr1
                     fpr2:(NSString *)fpr2
                 language:(NSString * _Nullable)language
                     full:(BOOL)full
            errorCallback:(void (^)(NSError *error))errorCallback
          successCallback:(void (^)(NSString *trustwords))successCallback;

- (void)languageList:(void (^)(NSError *error))errorCallback
     successCallback:(void (^)(NSArray<PEPLanguage *> *languages))successCallback;

- (void)isPEPUser:(PEPIdentity *)identity
    errorCallback:(void (^)(NSError *error))errorCallback
  successCallback:(void (^)(BOOL enabled))successCallback;

- (void)setOwnKey:(PEPIdentity *)identity
      fingerprint:(NSString *)fingerprint
    errorCallback:(void (^)(NSError *error))errorCallback
  successCallback:(void (^)(void))successCallback;

- (void)setFlags:(PEPIdentityFlags)flags
     forIdentity:(PEPIdentity *)identity
   errorCallback:(void (^)(NSError *error))errorCallback
 successCallback:(void (^)(void))successCallback;

- (void)deliverHandshakeResult:(PEPSyncHandshakeResult)result
             identitiesSharing:(NSArray<PEPIdentity *> * _Nullable)identitiesSharing
                 errorCallback:(void (^)(NSError *error))errorCallback
               successCallback:(void (^)(void))successCallback;

- (void)trustOwnKeyIdentity:(PEPIdentity *)identity
              errorCallback:(void (^)(NSError *error))errorCallback
            successCallback:(void (^)(void))successCallback;

- (void)keyReset:(PEPIdentity *)identity
     fingerprint:(NSString * _Nullable)fingerprint
   errorCallback:(void (^)(NSError *error))errorCallback
 successCallback:(void (^)(void))successCallback;

- (void)leaveDeviceGroup:(void (^)(NSError *error))errorCallback
         successCallback:(void (^)(void))successCallback;

- (void)keyResetAllOwnKeys:(void (^)(NSError *error))errorCallback
           successCallback:(void (^)(void))successCallback;

@end

NS_ASSUME_NONNULL_END
