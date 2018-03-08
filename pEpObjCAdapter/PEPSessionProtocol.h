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
- (BOOL)decryptMessageDict:(nonnull PEPDict *)src
                      dest:(PEPDict * _Nullable * _Nullable)dst
                    rating:(PEP_rating * _Nullable)rating
                      keys:(PEPStringList * _Nullable * _Nullable)keys
                     error:(NSError * _Nullable * _Nullable)error __deprecated;

/** Decrypt a message */
- (BOOL)decryptMessage:(nonnull PEPMessage *)src
                  dest:(PEPMessage * _Nullable * _Nullable)dst
                rating:(PEP_rating * _Nullable)rating
                  keys:(PEPStringList * _Nullable * _Nullable)keys
                 error:(NSError * _Nullable * _Nullable)error;

/** Re-evaluate rating of decrypted message */
- (PEP_rating)reEvaluateMessageRating:(nonnull PEPDict *)src __deprecated;

/** Re-evaluate rating of decrypted message */
- (PEP_rating)reEvaluateRatingForMessage:(nonnull PEPMessage *)src;

/** Encrypt a message dictionary */
- (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                           extra:(nullable PEPStringList *)keys
                       encFormat:(PEP_enc_format)encFormat
                            dest:(PEPDict * _Nullable * _Nullable)dst __deprecated;

/** Encrypt a message with default encryption format (PEP_enc_PEP) */
- (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                           extra:(nullable PEPStringList *)keys
                            dest:(PEPMessage * _Nullable * _Nullable)dst;

/** Encrypt a message */
- (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                       extra:(nullable PEPStringList *)keys
                   encFormat:(PEP_enc_format)encFormat
                        dest:(PEPMessage * _Nullable * _Nullable)dst;

/** Encrypt a message for the given identity, which is usually a mySelf identity */
- (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                        identity:(nonnull PEPIdentity *)identity
                            dest:(PEPDict * _Nullable * _Nullable)dst __deprecated;

/** Encrypt a message for the given identity, which is usually a mySelf identity */
- (PEP_STATUS)encryptMessage:(nonnull PEPMessage *)src
                        identity:(nonnull PEPIdentity *)identity
                            dest:(PEPMessage * _Nullable * _Nullable)dst;

/** Determine the status color of a message to be sent */
- (PEP_rating)outgoingColorForMessage:(nonnull PEPMessage *)message;

/**
 Determine the rating of an identity.
 The rating is the rating a _message_ would have, if it is sent to this (and only this) identity.
 It is *not* a rating of the identity. In fact, there is no rating for identities.
 */
- (PEP_rating)identityRating:(nonnull PEPIdentity *)identity;

/** Get trustwords for a fingerprint */
- (nonnull NSArray *)trustwords:(nonnull NSString *)fpr forLanguage:(nonnull NSString *)languageID
                      shortened:(BOOL)shortened;

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
- (void)mySelf:(nonnull PEPIdentity *)identity;

/**
 Supplement missing information for an arbitrary identity (used for communication partners).
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)updateIdentity:(nonnull PEPIdentity *)identity;

/**
 Mark a key as trusted with a person.
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)trustPersonalKey:(nonnull PEPIdentity *)identity;

/**
 if a key is not trusted by the user tell this using this message
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)keyMistrusted:(nonnull PEPIdentity *)identity;

/**
 Use this to undo keyCompromized or trustPersonalKey
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)keyResetTrust:(nonnull PEPIdentity *)identity;

#pragma mark -- Internal API (testing etc.)

/** For testing purpose, manual key import */
- (void)importKey:(nonnull NSString *)keydata;

- (void)logTitle:(nonnull NSString *)title entity:(nonnull NSString *)entity
     description:(nullable NSString *)description comment:(nullable NSString *)comment;

/**
 Retrieves the log from the engine, or nil, if there is nothing yet.
 */
- (nullable NSString *)getLog;

/** Determine trustwords for two identities */
- (nullable NSString *)getTrustwordsIdentity1:(nonnull PEPIdentity *)identity1
                                    identity2:(nonnull PEPIdentity *)identity2
                                     language:(nullable NSString *)language
                                         full:(BOOL)full;

/**
 @returns The list of supported languages for trustwords.
 */
- (NSArray<PEPLanguage *> * _Nonnull)languageList;

/**
 Directly invokes the engine's undo_last_mistrust() function
 */
- (PEP_STATUS)undoLastMistrust;

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
- (BOOL)isPEPUser:(PEPIdentity * _Nonnull)identity;

/**
 When (manually) importing (secret) keys, associate them with the given own identity.
 */
- (BOOL)setOwnKey:(PEPIdentity * _Nonnull)identity fingerprint:(NSString * _Nonnull)fingerprint
            error:(NSError * _Nullable * _Nullable)error;

@end
