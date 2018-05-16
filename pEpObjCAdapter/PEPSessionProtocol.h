//
//  PEPSessionProtocol.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPMessageUtil.h"

typedef NSDictionary<NSString *, id> PEPDict;
typedef NSMutableDictionary<NSString *, id> PEPMutableDict;
typedef NSArray<NSString *> PEPStringList;

@class PEPLanguage;
@class PEPIdentity;
@class PEPMessage;

@protocol PEPSessionProtocol <NSObject>

/** Decrypt a message */
- (PEPDict * _Nullable)decryptMessageDict:(PEPMutableDict * _Nonnull)messageDict
                                    flags:(PEP_decrypt_flags * _Nullable)flags
                                   rating:(PEP_rating * _Nullable)rating
                                extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                   status:(PEP_STATUS * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error __deprecated;

/** Decrypt a message */
- (PEPMessage * _Nullable)decryptMessage:(PEPMessage * _Nonnull)message
                                   flags:(PEP_decrypt_flags * _Nullable)flags
                                  rating:(PEP_rating * _Nullable)rating
                               extraKeys:(PEPStringList * _Nullable * _Nullable)extraKeys
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Re-evaluate rating of decrypted message */
- (BOOL)reEvaluateMessageDict:(PEPDict * _Nonnull)messageDict
                       rating:(PEP_rating * _Nullable)rating
                       status:(PEP_STATUS * _Nullable)status
                        error:(NSError * _Nullable * _Nullable)error __deprecated;

/** Re-evaluate rating of decrypted message */
- (BOOL)reEvaluateMessage:(PEPMessage * _Nonnull)message
                   rating:(PEP_rating * _Nullable)rating
                   status:(PEP_STATUS * _Nullable)status
                    error:(NSError * _Nullable * _Nullable)error;

/**
 Encrypt a message dictionary, indicating the encoding format.
 @note The resulting message dict could be the input one.
 */
- (PEPDict * _Nullable)encryptMessageDict:(PEPDict * _Nonnull)messageDict
                                extraKeys:(PEPStringList * _Nullable)extraKeys
                                encFormat:(PEP_enc_format)encFormat
                                   status:(PEP_STATUS * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error __deprecated;

/**
 Encrypt a message, indicating the encoding format
 @note The resulting message dict could be the input one.
 */
- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                               encFormat:(PEP_enc_format)encFormat
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Encrypt a message with default encryption format (PEP_enc_PEP) */
- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Encrypt a message dict for the given own identity */
- (PEPDict * _Nullable)encryptMessageDict:(PEPDict * _Nonnull)messageDict
                                  forSelf:(PEPIdentity * _Nonnull)ownIdentity
                                extraKeys:(PEPStringList * _Nullable)extraKeys
                                   status:(PEP_STATUS * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error __deprecated;

/** Encrypt a message for the given own identity */
- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                                 forSelf:(PEPIdentity * _Nonnull)ownIdentity
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Encrypt a message dict to the given recipient FPR, attaching the private key */
- (PEPDict * _Nullable)encryptMessageDict:(PEPDict * _Nonnull)messageDict
                                    toFpr:(NSString * _Nonnull)toFpr
                                encFormat:(PEP_enc_format)encFormat
                                    flags:(PEP_decrypt_flags)flags
                                   status:(PEP_STATUS * _Nullable)status
                                    error:(NSError * _Nullable * _Nullable)error __deprecated;

/** Encrypt a message dict to the given recipient FPR, attaching the private key */
- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                                   toFpr:(NSString * _Nonnull)toFpr
                               encFormat:(PEP_enc_format)encFormat
                                   flags:(PEP_decrypt_flags)flags
                                  status:(PEP_STATUS * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

/** Determine the status color of a message to be sent */
- (NSNumber * _Nullable)outgoingRatingForMessage:(PEPMessage * _Nonnull)message
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

/**
 Supply an account used by our user himself. The identity is supplemented with the missing parts

 An identity is a `NSDictionary` mapping a field name as `NSString` to different values.
 An identity can have the following fields (all other keys are ignored).
 It is not necessary to supply all fields; missing fields are supplemented by p≡p engine.

 @"username": real name or nick name (if pseudonymous) of identity
 @"address": URI or SMTP address
 @"user_id": persistent unique ID for the *user* that belongs to the identity.
                A user can have multiple identities which all of them MUST use the same user_id.
 @"lang": preferred languageID for communication with this ID (default: @"en")
 @"fpr": fingerprint of key to use for communication with this ID
 @"comm_type": communication type code (usually not needed)

 As an example:

 User has a mailbox. The mail address is "Dipul Khatri <dipul@inboxcube.com>". Then this would be:

 NSDictionary *ident = [NSDictionary dictionaryWithObjectsAndKeys:
 @"Dipul Khatri", @"username", @"dipul@inboxcube.com", @"address",
 @"23", @"user_id", nil];

 */
- (BOOL)mySelf:(PEPIdentity * _Nonnull)identity error:(NSError * _Nullable * _Nullable)error;

/**
 Supplement missing information for an arbitrary identity (used for communication partners).
 Will call the engine's myself() or update_identity() internally, depending on the given
 identity.
 */
- (BOOL)updateIdentity:(PEPIdentity * _Nonnull)identity
                 error:(NSError * _Nullable * _Nullable)error;

/**
 Mark a key as trusted with a person.
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (BOOL)trustPersonalKey:(PEPIdentity * _Nonnull)identity
                   error:(NSError * _Nullable * _Nullable)error;

/**
 if a key is not trusted by the user tell this using this message
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (BOOL)keyMistrusted:(PEPIdentity * _Nonnull)identity
                error:(NSError * _Nullable * _Nullable)error;

/**
 Use this to undo keyCompromized or trustPersonalKey
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (BOOL)keyResetTrust:(PEPIdentity * _Nonnull)identity
                error:(NSError * _Nullable * _Nullable)error;

#pragma mark -- Internal API (testing etc.)

/** For testing purpose, manual key import */
- (BOOL)importKey:(NSString * _Nonnull)keydata error:(NSError * _Nullable * _Nullable)error;

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

/**
 @returns The list of supported languages for trustwords.
 */
- (NSArray<PEPLanguage *> * _Nullable)languageListWithError:(NSError * _Nullable * _Nullable)error;

/**
 Directly invokes the engine's undo_last_mistrust() function
 */
- (BOOL)undoLastMistrustWithError:(NSError * _Nullable * _Nullable)error;

/**
 Can convert a string like "cannot_decrypt" into its equivalent PEP_rating_cannot_decrypt.
 */
- (PEP_rating)ratingFromString:(NSString * _Nonnull)string;

/**
 Can convert a pEp rating like PEP_rating_cannot_decrypt
 into its equivalent string "cannot_decrypt" .
 */
- (NSString * _Nonnull)stringFromRating:(PEP_rating)rating;

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

@end
