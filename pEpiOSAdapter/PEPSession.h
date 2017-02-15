//
//  PEPSession.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 08.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "pEpiOSAdapter.h"
#import "PEPMessage.h"

@class PEPSession;

/** Callback type for doing something with a session */
typedef void (^PEPSessionBlock)(PEPSession * _Nonnull session);

@interface PEPSession : NSObject

#pragma mark -- Public API

+ (nonnull PEPSession *)session;

/**
 Execute a block concurrently on a session.
 The session is created solely for execution of the block.
 */
+ (void)dispatchAsyncOnSession:(nonnull PEPSessionBlock)block;

/**
 Execute a block on a session and wait for it.
 The session is created solely for execution of the block.
 */
+ (void)dispatchSyncOnSession:(nonnull PEPSessionBlock)block;

/** Decrypt a message */
- (PEP_rating)decryptMessageDict:(nonnull NSDictionary<NSString *, id> *)src
                            dest:(NSDictionary<NSString *, id> * _Nullable * _Nullable)dst
                            keys:(NSArray * _Nullable * _Nullable)keys;

/** Encrypt a message */
- (PEP_STATUS)encryptMessageDict:(nonnull NSDictionary<NSString *, id> *)src
                           extra:(nullable NSArray *)keys
                            dest:(NSDictionary<NSString *, id> * _Nullable * _Nullable)dst;

/** Encrypt a message for the given identity, which is usually a mySelf identity */
- (PEP_STATUS)encryptMessageDict:(nonnull NSDictionary<NSString *, id> *)src
                        identity:(nonnull NSDictionary<NSString *, id> *)identity
                            dest:(NSDictionary<NSString *, id> * _Nullable * _Nullable)dst;

/** Determine the status color of a message to be sent */
- (PEP_rating)outgoingMessageColor:(nonnull NSDictionary<NSString *, id> *)msg;

/** Determine the rating of an identity */
- (PEP_rating)identityRating:(nonnull NSDictionary<NSString *, id> *)identity;

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
 @"me": YES if this is an identity of our user, NO if it is one of a communication partner (default: NO)
 
 As an example:
 
 User has a mailbox. The mail address is "Dipul Khatri <dipul@inboxcube.com>". Then this would be:
 
 NSDictionary *ident = [NSDictionary dictionaryWithObjectsAndKeys:
 @"Dipul Khatri", @"username", @"dipul@inboxcube.com", @"address", 
 @"23", @"user_id", nil];
 
*/
- (void)mySelf:(nonnull NSMutableDictionary<NSString *, id> *)identity;

/**
 Supplement missing information for an arbitrary identity (used for communication partners).
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)updateIdentity:(nonnull NSMutableDictionary<NSString *, id> *)identity;

/**
 Mark a key as trusted with a person.
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)trustPersonalKey:(nonnull NSMutableDictionary<NSString *, id> *)identity;

/**
 if a key is not trusted by the user tell this using this message
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)keyMistrusted:(nonnull NSMutableDictionary<NSString *, id> *)identity;

/**
 Use this to undo keyCompromized or trustPersonalKey
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
*/
- (void)keyResetTrust:(nonnull NSMutableDictionary<NSString *, id> *)identity;

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
- (nullable NSString *)getTrustwordsIdentity1:(nonnull NSDictionary<NSString *, id> *)identity1
                                    identity2:(nonnull NSDictionary<NSString *, id> *)identity2
                                     language:(nullable NSString *)language
                                         full:(BOOL)full;

@end
