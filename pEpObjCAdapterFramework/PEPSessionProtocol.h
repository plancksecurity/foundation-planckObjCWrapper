//
//  PEPSessionProtocol.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPTypes.h"
#import "PEPEngineTypes.h"

@class PEPLanguage;
@class PEPIdentity;
@class PEPMessage;

@protocol PEPSessionProtocol <NSObject>

/** Decrypt a message */
- (PEPMessage * _Nullable)decryptMessage:(PEPMessage * _Nonnull)message
                                   flags:(PEPDecryptFlags * _Nullable)flags
                                  rating:(PEPRating * _Nullable)rating
                               extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Re-evaluate rating of decrypted message */
- (BOOL)reEvaluateMessage:(PEPMessage * _Nonnull)message
                 xKeyList:(PEPStringList *_Nullable)xKeyList
                   rating:(PEPRating * _Nonnull)rating
                   status:(PEPStatus * _Nullable)status
                    error:(NSError * _Nullable * _Nullable)error;

/**
 Encrypt a message, indicating the encoding format
 @note The resulting message dict could be the input one.
 */
- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                               encFormat:(PEPEncFormat)encFormat
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Encrypt a message with default encryption format (PEP_enc_PEP) */
- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Encrypt a message for the given own identity */
- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                                 forSelf:(PEPIdentity * _Nonnull)ownIdentity
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Encrypt a message to the given recipient FPR, attaching the private key */
- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                                   toFpr:(NSString * _Nonnull)toFpr
                               encFormat:(PEPEncFormat)encFormat
                                   flags:(PEPDecryptFlags)flags
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Determine the status color of a message to be sent */
- (NSNumber * _Nullable)outgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                                           error:(NSError * _Nullable * _Nullable)error;

/** Determine the preview status color of a message to be sent */
- (NSNumber * _Nullable)outgoingRatingPreviewForMessage:(PEPMessage * _Nonnull)theMessage
                                                  error:(NSError * _Nullable * _Nullable)error;

/**
 Determine the rating of an identity.
 The rating is the rating a _message_ would have, if it is sent to this (and only this) identity.
 It is *not* a rating of the identity. In fact, there is no rating for identities.
 */
- (NSNumber * _Nullable)ratingForIdentity:(PEPIdentity * _Nonnull)identity
                                    error:(NSError * _Nullable * _Nullable)error;

/** Get trustwords for a fingerprint */
- (NSArray * _Nullable)trustwordsForFingerprint:(NSString * _Nonnull)fingerprint
                                     languageID:(NSString * _Nonnull)languageID
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
- (BOOL)mySelf:(PEPIdentity * _Nonnull)identity
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
- (BOOL)updateIdentity:(PEPIdentity * _Nonnull)identity
                 error:(NSError * _Nullable * _Nullable)error;

/**
 Mark a key as trusted with a person.
 */
- (BOOL)trustPersonalKey:(PEPIdentity * _Nonnull)identity
                   error:(NSError * _Nullable * _Nullable)error;

/**
 if a key is not trusted by the user tell this using this message
 */
- (BOOL)keyMistrusted:(PEPIdentity * _Nonnull)identity
                error:(NSError * _Nullable * _Nullable)error;

/**
 Use this to undo keyCompromized or trustPersonalKey
 */
- (BOOL)keyResetTrust:(PEPIdentity * _Nonnull)identity
                error:(NSError * _Nullable * _Nullable)error;

/**
 Enables key sync.

 Wraps enable_identity_for_sync.

 @param identity The (own) identity to enable key sync for.
 @param error The usual cocoa error handling.
 @return The usual cocoa error handling.
 */
- (BOOL)enableSyncForIdentity:(PEPIdentity * _Nonnull)identity
                        error:(NSError * _Nullable * _Nullable)error;

/**
 Disables key sync.

 Wraps disable_identity_for_sync.

 @param identity The (own) identity to disable key sync for.
 @param error The usual cocoa error handling.
 @return The usual cocoa error handling.
 */
- (BOOL)disableSyncForIdentity:(PEPIdentity * _Nonnull)identity
                         error:(NSError * _Nullable * _Nullable)error;

/**
 Queries the given own identity on whether it has key sync disabled or not.

 @param identity The (own) identity to query.
 @param error The usual cocoa error handling.
 @return An NSNumber containing a boolean denoting whether key sync is enabled or not, or
         nil on error. YES means that key sync is allowed for this identity, otherwise it's NO.
 */
- (NSNumber * _Nullable)queryKeySyncEnabledForIdentity:(PEPIdentity * _Nonnull)identity
                                                 error:(NSError * _Nullable * _Nullable)error;

#pragma mark -- Internal API (testing etc.)

/** For testing purpose, manual key import */
- (NSArray<PEPIdentity *> * _Nullable)importKey:(NSString * _Nonnull)keydata
                                          error:(NSError * _Nullable * _Nullable)error;

- (BOOL)logTitle:(NSString * _Nonnull)title
          entity:(NSString * _Nonnull)entity
     description:(NSString * _Nullable)description
         comment:(NSString * _Nullable)comment
           error:(NSError * _Nullable * _Nullable)error;

/**
 Retrieves the log from the engine, or nil, if there is nothing yet.
 */
- (NSString * _Nullable)getLogWithError:(NSError * _Nullable * _Nullable)error;

/** Determine trustwords for two identities */
- (NSString * _Nullable)getTrustwordsIdentity1:(PEPIdentity * _Nonnull)identity1
                                     identity2:(PEPIdentity * _Nonnull)identity2
                                      language:(NSString * _Nullable)language
                                          full:(BOOL)full
                                         error:(NSError * _Nullable * _Nullable)error;

/** Determine trustwords for two fprs */
- (NSString * _Nullable)getTrustwordsFpr1:(NSString * _Nonnull)fpr1
                                     fpr2:(NSString * _Nonnull)fpr2
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
- (PEPRating)ratingFromString:(NSString * _Nonnull)string;

/**
 Can convert a pEp rating like PEPRating_cannot_decrypt
 into its equivalent string "cannot_decrypt" .
 */
- (NSString * _Nonnull)stringFromRating:(PEPRating)rating;

/**
 Is the given identity really a pEp user?
 If the engine indicates an error, or the identity is not a pEp user, returns false.
 */
- (NSNumber * _Nullable)isPEPUser:(PEPIdentity * _Nonnull)identity
                            error:(NSError * _Nullable * _Nullable)error;

/**
 When (manually) importing (secret) keys, associate them with the given own identity.
 */
- (BOOL)setOwnKey:(PEPIdentity * _Nonnull)identity fingerprint:(NSString * _Nonnull)fingerprint
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
     forIdentity:(PEPIdentity * _Nonnull)identity
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
- (BOOL)trustOwnKeyIdentity:(PEPIdentity * _Nonnull)identity
                      error:(NSError * _Nullable * _Nullable)error;

/**
 Wraps color_from_rating.
 */
- (PEPColor)colorFromRating:(PEPRating)rating;

/**
 Wraps key_reset_identity.
 */
- (BOOL)keyReset:(PEPIdentity * _Nonnull)identity
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

@end
