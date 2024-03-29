//
//  PEPSessionProtocol.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PEPObjCTypes;

#import "PEPSessionProtocolTKA.h"

NS_ASSUME_NONNULL_BEGIN

/// Domain for errors indicated by the pEp adapter itself.
extern NSString *const _Nonnull PEPObjCAdapterErrorDomain;

@protocol PEPSessionProtocol <NSObject, PEPSessionProtocolTKA>

/// You must call this method once before your process gets terminated to be able to gracefully shutdown.
/// You must not make any calls to PEPSession in between the last call to `cleanup()` and getting terminated.
///
/// Only for performance reasons: call this method only if you have to.
+ (void)cleanup;

- (void)decryptMessage:(PEPMessage *)message
                 flags:(PEPDecryptFlags)flags
             extraKeys:(PEPStringList *_Nullable)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *dstMessage,
                                 PEPStringList *keyList,
                                 PEPRating rating,
                                 PEPDecryptFlags flags,
                                 BOOL isFormerlyEncryptedReuploadedMessage))successCallback;

- (void)reEvaluateMessage:(PEPMessage *)message
                 xKeyList:(PEPStringList *_Nullable)xKeyList
           originalRating:(PEPRating)originalRating
            errorCallback:(void (^)(NSError *error))errorCallback
          successCallback:(void (^)(PEPRating rating))successCallback;

/// Encrypt a message with explicit encryption format.
- (void)encryptMessage:(PEPMessage *)message
             extraKeys:(PEPStringList *_Nullable)extraKeys
             encFormat:(PEPEncFormat)encFormat
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback;

/// Encrypt a message with the default encryption format.
- (void)encryptMessage:(PEPMessage *)message
             extraKeys:(PEPStringList *_Nullable)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback;

/// Encrypt a message to an own identity.
- (void)encryptMessage:(PEPMessage *)message
               forSelf:(PEPIdentity *)ownIdentity
             extraKeys:(PEPStringList *_Nullable)extraKeys
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

- (void)importKey:(NSString *)keydata
      errorCallback:(void (^)(NSError *error))errorCallback
    successCallback:(void (^)(NSArray<PEPIdentity *> *identities))successCallback;

- (void)importExtraKey:(NSString *)keydata
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(NSArray<NSString *> *fingerprints))successCallback;

- (void)getLog:(void (^)(NSError *error))errorCallback
    successCallback:(void (^)(NSString *log))successCallback;

- (void)getTrustwordsIdentity1:(PEPIdentity *)identity1
                     identity2:(PEPIdentity *)identity2
                      language:(NSString *_Nullable)language
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

- (void)deliverHandshakeResult:(PEPSyncHandshakeResult)result
             identitiesSharing:(NSArray<PEPIdentity *> *_Nullable)identitiesSharing
                 errorCallback:(void (^)(NSError *error))errorCallback
               successCallback:(void (^)(void))successCallback;

- (void)trustOwnKeyIdentity:(PEPIdentity *)identity
              errorCallback:(void (^)(NSError *error))errorCallback
            successCallback:(void (^)(void))successCallback;

/// Can convert a pEp rating like PEPRating_cannot_decrypt
/// into its equivalent string like "cannot_decrypt".
/// @Note Does not invoke the engine, can be safely used synchronously
/// on the main thread.
- (NSString *_Nonnull)stringFromRating:(PEPRating)rating;

- (void)keyReset:(PEPIdentity *)identity
        fingerprint:(NSString *_Nullable)fingerprint
      errorCallback:(void (^)(NSError *error))errorCallback
    successCallback:(void (^)(void))successCallback;

- (void)leaveDeviceGroup:(void (^)(NSError *error))errorCallback
         successCallback:(void (^)(void))successCallback;

- (void)keyResetAllOwnKeys:(void (^)(NSError *error))errorCallback
           successCallback:(void (^)(void))successCallback;

/// Wraps `sync_reinit` (sync_api.h).
- (void)syncReinit:(void (^)(NSError *error))errorCallback
   successCallback:(void (^)(void))successCallback;

// MARK: - Configuration

/// Add a passphrase for secret keys to the cache.
///
/// You can add as many passphrases to the cache as needed by calling this method.
/// Every passphrase is valid for 10 min (default, compile-time configurable),
/// after that it gets removed from memory. The maximum count of passphrases is 20.
/// Setting the 21st replaces the 1st.
/// On error, `NO` is returned and the (optional) parameter `error`
/// is set to the error that occurred.
/// On every engine call that returns PEPStatusPassphraseRequired, or PEPStatusWrongPassphrase,
/// the adapter will automatically repeat the call after setting the next cached passphrase
/// (using the engine's `config_passphrase`). The first attempet as always with an empty password.
/// This will be repeated until the call either succeeds, or until
/// the adapter runs out of usable passwords.
/// When the adapter runs out of passwords to try, PEPStatusWrongPassphrase will be thrown.
/// If the engine indicates PEPStatusPassphraseRequired, and there are no passwords,
/// the adapter will throw PEPStatusPassphraseRequired.
/// The passphrase can have a "maximum number of code points of 250", which is
/// approximated by checking the string length.
/// If the passphrase exceeds this limit, the adapter throws PEPAdapterErrorPassphraseTooLong
/// with a domain of PEPObjCAdapterErrorDomain.
/// @Throws PEPAdapterErrorPassphraseTooLong (with a domain of PEPObjCAdapterErrorDomain)
/// or PEPStatusOutOfMemory (with PEPObjCAdapterEngineStatusErrorDomain)
- (BOOL)configurePassphrase:(NSString * _Nonnull)passphrase
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error;

// MARK: - Methods that can be executed syncronously

/// Converts a string like "cannot_decrypt" into its equivalent PEPRating_cannot_decrypt.
- (PEPRating)ratingFromString:(NSString *_Nonnull)string;

/// Wraps color_from_rating.
- (PEPColor)colorFromRating:(PEPRating)rating;

/// Wraps `disable_all_sync_channels` (sync_api.h).
- (BOOL)disableAllSyncChannels:(NSError * _Nullable * _Nullable)error;

#pragma mark - Signing

- (void)signText:(NSString *)stringToSign
   errorCallback:(void (^)(NSError *error))errorCallback
 successCallback:(void (^)(NSString *signature))successCallback;

- (void)verifyText:(NSString *)textToVerify
         signature:(NSString *)signature
     errorCallback:(void (^)(NSError *error))errorCallback
   successCallback:(void (^)(BOOL verified))successCallback;

@end

NS_ASSUME_NONNULL_END
