//
//  PEPSession.h
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 11.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPMessage.h"

typedef NSDictionary<NSString *, id> PEPDict;
typedef NSMutableDictionary<NSString *, id> PEPMutableDict;
typedef NSArray<NSString *> PEPStringList;

@class PEPLanguage;

/**
 Fake session to handle to the client.

 Assures all calls are handled on the correct internal session for the thread it is called on.
 You can instatntiate and use this session how often and wherever you want. Also over multiple threads.

 Note: You must call `cleanup()` once before your process gets terminated to be able to gracefully shutdown.
 It is the clients responsibility not to make any calls to PEPSession after calling cleanup.

 Also: The Engine requires that the first session is created on the main thread. It is the responibility of the client to call PEPSession init once on the main thread before any other thread is calling it.
 */
@interface PEPSession : NSObject

/**
 You must call this method once before your process gets terminated to be able to gracefully shutdown.
 You must not make any calls to PEPSession after calling cleanup.
 */
+ (void)cleanup;

/** Decrypt a message */
- (PEP_rating)decryptMessageDict:(nonnull PEPDict *)src
                            dest:(PEPDict * _Nullable * _Nullable)dst
                            keys:(PEPStringList * _Nullable * _Nullable)keys;

/** Re-evaluate rating of decrypted message */
- (PEP_rating)reEvaluateMessageRating:(nonnull PEPDict *)src;

/** Encrypt a message */
- (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                           extra:(nullable PEPStringList *)keys
                            dest:(PEPDict * _Nullable * _Nullable)dst;

/** Encrypt a message for the given identity, which is usually a mySelf identity */
- (PEP_STATUS)encryptMessageDict:(nonnull PEPDict *)src
                        identity:(nonnull PEPDict *)identity
                            dest:(PEPDict * _Nullable * _Nullable)dst;

/** Determine the status color of a message to be sent */
- (PEP_rating)outgoingMessageColor:(nonnull PEPDict *)msg;

/** Determine the rating of an identity */
- (PEP_rating)identityRating:(nonnull PEPDict *)identity;

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
 @"user_id": persistent unique ID for identity
 @"lang": preferred languageID for communication with this ID (default: @"en")
 @"fpr": fingerprint of key to use for communication with this ID
 @"comm_type": communication type code (usually not needed)

 As an example:

 User has a mailbox. The mail address is "Dipul Khatri <dipul@inboxcube.com>". Then this would be:

 NSDictionary *ident = [NSDictionary dictionaryWithObjectsAndKeys:
 @"Dipul Khatri", @"username", @"dipul@inboxcube.com", @"address",
 @"23", @"user_id", nil];

 */
- (void)mySelf:(nonnull PEPMutableDict *)identity;

/**
 Supplement missing information for an arbitrary identity (used for communication partners).
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)updateIdentity:(nonnull PEPMutableDict *)identity;

/**
 Mark a key as trusted with a person.
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)trustPersonalKey:(nonnull PEPMutableDict *)identity;

/**
 if a key is not trusted by the user tell this using this message
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)keyMistrusted:(nonnull PEPMutableDict *)identity;

/**
 Use this to undo keyCompromized or trustPersonalKey
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)keyResetTrust:(nonnull PEPMutableDict *)identity;

#pragma mark -- Internal API (testing etc.)

/** For testing purpose, manual key import */
- (void)importKey:(nonnull NSString *)keydata;

- (void)logTitle:(nonnull NSString *)title entity:(nonnull NSString *)entity
     description:(nullable NSString *)description comment:(nullable NSString *)comment;

/**
 Retrieves the log from the engine.
 */
- (nonnull NSString *)getLog;

/** Determine trustwords for two identities */
- (nullable NSString *)getTrustwordsIdentity1:(nonnull PEPDict *)identity1
                                    identity2:(nonnull PEPDict *)identity2
                                     language:(nullable NSString *)language
                                         full:(BOOL)full;

/** Determine trustwords between sender of a message and receiving identity */
- (nullable NSString *)getTrustwordsMessageDict:(nonnull PEPDict *)messageDict
                                   receiverDict:(nonnull PEPDict *)receiverDict
                                      keysArray:(PEPStringList * _Nullable)keysArray
                                       language:(nullable NSString *)language
                                           full:(BOOL)full
                                resultingStatus:(PEP_STATUS * _Nullable)resultingStatus;

/**
 @returns The list of supported languages for trustwords.
 */
- (NSArray<PEPLanguage *> * _Nonnull)languageList;

/**
 Directly invokes the engine's undo_last_mistrust() function
 */
- (PEP_STATUS)undoLastMistrust;

@end
