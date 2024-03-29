//
//  PEPSession.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 08.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PEPObjCTypes;

#import "sync_api.h"

@class PEPPassphraseCache;

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a real pEp session (in contrast to PEPSession, which is a fake session to handle to the client).
 Never expose this class to the client.
 - You must use one session on one thread only to assure no concurrent calls to one session take place.
 - As long as you can assure the session is not accessed from anywhere else, it is OK to init/deinit a session on another thread than the one it is used on.
 - N threads <-> N sessions, with the constraint that a session is never used in a pEpEngine call more than once at the same time.

 Also the Engine requires that the first session is created on the main thread and is kept allive until all other created sessions have been terminated.
 */
@interface PEPInternalSession : NSObject

@property (nonatomic) PEP_SESSION _Nullable session;

- (_Nullable instancetype)init;

/**
 Configures the session's unecryptedSubjectEnabled value.

 @param enabled Whether or not mail subjects should be encrypted when using this session
 */
- (void)configUnEncryptedSubjectEnabled:(BOOL)enabled;

/// Get the (global) passphrase cache, convenience method.
- (PEPPassphraseCache *)passphraseCache;

/** Decrypt a message */
- (PEPMessage * _Nullable)decryptMessage:(PEPMessage *)message
                                   flags:(PEPDecryptFlags * _Nullable)flags
                                  rating:(PEPRating * _Nullable)rating
                               extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Re-evaluate rating of decrypted message */
- (BOOL)reEvaluateMessage:(PEPMessage *)message
                 xKeyList:(PEPStringList *_Nullable)xKeyList
                   rating:(PEPRating *)rating
                   status:(PEPStatus * _Nullable)status
                    error:(NSError * _Nullable * _Nullable)error;

/**
 Encrypt a message, indicating the encoding format
 @note The resulting message dict could be the input one.
 */
- (PEPMessage * _Nullable)encryptMessage:(PEPMessage *)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                               encFormat:(PEPEncFormat)encFormat
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Encrypt a message with default encryption format (PEP_enc_PEP) */
- (PEPMessage * _Nullable)encryptMessage:(PEPMessage *)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Encrypt a message for the given own identity */
- (PEPMessage * _Nullable)encryptMessage:(PEPMessage *)message
                                 forSelf:(PEPIdentity *)ownIdentity
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Encrypt a message to the given recipient FPR, attaching the private key */
- (PEPMessage * _Nullable)encryptMessage:(PEPMessage *)message
                                   toFpr:(NSString *)toFpr
                               encFormat:(PEPEncFormat)encFormat
                                   flags:(PEPDecryptFlags)flags
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Determine the status color of a message to be sent */
- (NSNumber * _Nullable)outgoingRatingForMessage:(PEPMessage *)theMessage
                                           error:(NSError * _Nullable * _Nullable)error;

/** Determine the preview status color of a message to be sent */
- (NSNumber * _Nullable)outgoingRatingPreviewForMessage:(PEPMessage *)theMessage
                                                  error:(NSError * _Nullable * _Nullable)error;

/**
 Determine the rating of an identity.
 The rating is the rating a _message_ would have, if it is sent to this (and only this) identity.
 It is *not* a rating of the identity. In fact, there is no rating for identities.
 */
- (NSNumber * _Nullable)ratingForIdentity:(PEPIdentity *)identity
                                    error:(NSError * _Nullable * _Nullable)error;

/** Get trustwords for a fingerprint */
- (NSArray<NSString *> * _Nullable)trustwordsForFingerprint:(NSString *)fingerprint
                                                 languageID:(NSString *)languageID
                                                  shortened:(BOOL)shortened
                                                      error:(NSError * _Nullable * _Nullable)error;

/// Marks an identity as an own identity, not changing its participation in pEp sync.
///
/// @return Returns YES on success, NO on error, setting `*error` accordingly if possible.
///
/// @note See the engine's myself function for details.
///
/// @param identity The identity to mark as own.
///
/// @param error Standard cocoa error handling.
- (BOOL)mySelf:(PEPIdentity *)identity
         error:(NSError * _Nullable * _Nullable)error;

/// Calls the engine's update_identity on the given identity.
///
/// @note Prior this was invoking myself if the identity was identified as being an own
/// identity, but this not the case anymore, since it cannot decide if the identity should
/// participate in pEp sync or not.
///
/// @return Returns YES on success, NO on error, setting `*error` accordingly if possible.
///
/// @param identity The identity for which to call update_identity.
///
/// @param error Standart cocoa error handling.
- (BOOL)updateIdentity:(PEPIdentity *)identity
                 error:(NSError * _Nullable * _Nullable)error;

/**
 Mark a key as trusted with a person.
 */
- (BOOL)trustPersonalKey:(PEPIdentity *)identity
                   error:(NSError * _Nullable * _Nullable)error;

/**
 if a key is not trusted by the user tell this using this message
 */
- (BOOL)keyMistrusted:(PEPIdentity *)identity
                error:(NSError * _Nullable * _Nullable)error;

/**
 Use this to undo keyCompromized or trustPersonalKey
 */
- (BOOL)keyResetTrust:(PEPIdentity *)identity
                error:(NSError * _Nullable * _Nullable)error;

/**
 Enables key sync.

 Wraps enable_identity_for_sync.

 @param identity The (own) identity to enable key sync for.
 @param error The usual cocoa error handling.
 @return The usual cocoa error handling.
 */
- (BOOL)enableSyncForIdentity:(PEPIdentity *)identity
                        error:(NSError * _Nullable * _Nullable)error;

/**
 Disables key sync.

 Wraps `disable_identity_for_sync`.

 @param identity The (own) identity to disable key sync for.
 @param error The usual cocoa error handling.
 @return The usual cocoa error handling.
 */
- (BOOL)disableSyncForIdentity:(PEPIdentity *)identity
                         error:(NSError * _Nullable * _Nullable)error;

#pragma mark -- Internal API (testing etc.)

/** For testing purpose, manual key import */
- (NSArray<PEPIdentity *> * _Nullable)importKey:(NSString *)keydata
                                          error:(NSError * _Nullable * _Nullable)error;

/** Wraps `import_extrakey_with_fpr_return`. */
- (NSArray<NSString *> * _Nullable)importExtraKey:(NSString *)keydata
                                            error:(NSError * _Nullable * _Nullable)error;

/**
 Retrieves the log from the engine, or nil, if there is nothing yet.
 */
- (NSString * _Nullable)getLogWithError:(NSError * _Nullable * _Nullable)error;

/** Determine trustwords for two identities */
- (NSString * _Nullable)getTrustwordsIdentity1:(PEPIdentity *)identity1
                                     identity2:(PEPIdentity *)identity2
                                      language:(NSString * _Nullable)language
                                          full:(BOOL)full
                                         error:(NSError * _Nullable * _Nullable)error;

/**
 @returns The list of supported languages for trustwords.
 */
- (NSArray<PEPLanguage *> * _Nullable)languageListWithError:(NSError * _Nullable * _Nullable)error;

/**
 Can convert a string like "cannot_decrypt" into its equivalent PEPRating_cannot_decrypt.
 */
- (PEPRating)ratingFromString:(NSString *)string;

/**
 Can convert a pEp rating like PEPRating_cannot_decrypt
 into its equivalent string "cannot_decrypt" .
 */
- (NSString *)stringFromRating:(PEPRating)rating;

/**
 Is the given identity really a pEp user?
 If the engine indicates an error, or the identity is not a pEp user, returns false.
 */
- (NSNumber * _Nullable)isPEPUser:(PEPIdentity *)identity
                            error:(NSError * _Nullable * _Nullable)error;

/**
 When (manually) importing (secret) keys, associate them with the given own identity.
 */
- (BOOL)setOwnKey:(PEPIdentity *)identity fingerprint:(NSString *)fingerprint
            error:(NSError * _Nullable * _Nullable)error;

/**
 Wraps the engine's `config_passive_mode`.
 @note That there's absolutely no error handling.
 */
- (void)configurePassiveModeEnabled:(BOOL)enabled;

/**
 Wraps set_identity_flags.
 */
- (BOOL)setFlags:(PEPIdentityFlags)flags
     forIdentity:(PEPIdentity *)identity
           error:(NSError * _Nullable * _Nullable)error;

/**
 Indicate the user's choice during a handshake dialog display.

 Wraps the engine's deliverHandshakeResult. Should be called in response to
 [PEPNotifyHandshakeDelegate notifyHandshake:me:partner:signal
 in accordance with the user's choices.

 @param result The choice the user made with regards to the currently active handshake dialog.
 @param identitiesSharing The identities that are involved for the user's choice.
 That is, the user can chose to respond only for a subset of the
 identities that were originally involved in the handshake.
 @param error The default cocoa error handling.
 @return `YES` when the call succedded, `NO` otherwise. In the `NO` case, see `error` for details.
 */
- (BOOL)deliverHandshakeResult:(PEPSyncHandshakeResult)result
             identitiesSharing:(NSArray<PEPIdentity *> * _Nullable)identitiesSharing
                         error:(NSError * _Nullable * _Nullable)error;

/**
 Wraps trust_own_key.
 */
- (BOOL)trustOwnKeyIdentity:(PEPIdentity *)identity
                      error:(NSError * _Nullable * _Nullable)error;

/**
 Wraps color_from_rating.
 */
- (PEPColor)colorFromRating:(PEPRating)rating;

/**
 Wraps key_reset_user.
 */
- (BOOL)keyReset:(PEPIdentity *)identity
     fingerprint:(NSString * _Nullable)fingerprint
           error:(NSError * _Nullable * _Nullable)error;

/** Wraps leave_device_group. */
- (BOOL)leaveDeviceGroup:(NSError * _Nullable * _Nullable)error;

/**
 Revoke and mistrust all own keys. See key_reset_all_own_keys for details.

 @param error The default cocoa error handling.
 @return YES on success, NO if there were errors.
 */
- (BOOL)keyResetAllOwnKeysError:(NSError * _Nullable * _Nullable)error;

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
- (BOOL)configurePassphrase:(NSString *)passphrase
                      error:(NSError * _Nullable * _Nullable)error;

/// Wraps `disable_all_sync_channels` (`sync_api.h`).
- (BOOL)disableAllSyncChannels:(NSError * _Nullable * _Nullable)error;

/// Wraps `sync_reinit` (sync_api.h).
- (BOOL)syncReinit:(NSError * _Nullable * _Nullable)error;

- (BOOL)setTrustIdentity:(const PEPIdentity *)identity
                   error:(NSError * _Nullable * _Nullable)error;

#pragma mark - Media Key / Echo Protocol

/// Wraps `config_media_keys`.
/// @Note The media keys can be nil, which should make the session not use any media keys.
- (BOOL)configureMediaKeys:(NSArray<PEPMediaKeyPair *> * _Nullable)mediaKeys
                     error:(NSError * _Nullable * _Nullable)error;

- (void)configureEchoProtocolEnabled:(BOOL)enabled;

- (void)configureEchoInOutgoingMessageRatingPreviewEnabled:(BOOL)enabled;

#pragma mark - Signing

- (NSString *)signText:(NSString *)stringToSign
                 error:(NSError **)error;

- (BOOL)verifyText:(NSString *)textToVerify
         signature:(NSString *)signature
          verified:(BOOL *)verified
             error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
