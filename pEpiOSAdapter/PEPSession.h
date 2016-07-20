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

#pragma mark -- Constants

extern NSString *const _Nonnull kPepUsername;
extern NSString *const _Nonnull kPepAddress;
extern NSString *const _Nonnull kPepUserID;
extern NSString *const _Nonnull kPepFingerprint;
extern NSString *const _Nonnull kPepIsMe;

extern NSString *const _Nonnull kPepFrom;
extern NSString *const _Nonnull kPepTo;
extern NSString *const _Nonnull kPepShortMessage;
extern NSString *const _Nonnull kPepLongMessage;
extern NSString *const _Nonnull kPepOutgoing;
extern NSString *const _Nonnull kPepSent;
extern NSString *const _Nonnull kPepReceived;
extern NSString *const _Nonnull kPepReceivedBy;
extern NSString *const _Nonnull kPepCC;
extern NSString *const _Nonnull kPepBCC;
extern NSString *const _Nonnull kPepReplyTo;
extern NSString *const _Nonnull kPepInReplyTo;
extern NSString *const _Nonnull kPepReferences;
extern NSString *const _Nonnull kPepOptFields;
extern NSString *const _Nonnull kPepLongMessageFormatted;
extern NSString *const _Nonnull kPepAttachments;
extern NSString *const _Nonnull kPepID;

extern NSString *const _Nonnull kPepMimeData;
extern NSString *const _Nonnull kPepMimeFilename;
extern NSString *const _Nonnull kPepMimeType;

extern NSString *const _Nonnull kPepCommType;

/** NSError parameters will use this domain */
extern NSString *const _Nonnull PEPSessionErrorDomain;

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
- (PEP_color)decryptMessageDict:(nonnull NSDictionary *)src
                           dest:(NSDictionary * _Nonnull * _Nonnull)dst
                           keys:(NSArray * _Nonnull * _Nullable)keys;

/** Encrypt a message */
- (PEP_STATUS)encryptMessageDict:(nonnull NSDictionary *)src
                           extra:(nullable NSArray *)keys
                            dest:(NSDictionary * _Nonnull * _Nullable)dst;

/** Determine the status color of a message to be sent */
- (PEP_color)outgoingMessageColor:(nonnull NSDictionary *)msg;

/** Determine the status color of a message to be sent */
- (PEP_color)identityColor:(nonnull NSDictionary *)identity;

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
- (void)mySelf:(nonnull NSMutableDictionary *)identity;

/**
 Supplement missing information for an arbitrary identity (used for communication partners).
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)updateIdentity:(nonnull NSMutableDictionary *)identity;

/**
 Mark a key as trusted with a person.
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)trustPersonalKey:(nonnull NSDictionary *)identity;

/**
 if a key gets comprimized tell this using this message
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)keyCompromized:(nonnull NSDictionary *)identity;

/**
 Use this to undo keyCompromized or trustPersonalKey
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
*/
- (void)keyResetTrust:(nonnull NSDictionary*)identity;

#pragma mark -- Internal API (testing etc.)

/** For testing purpose, manual key import */
- (void)importKey:(nonnull NSString *)keydata;

- (void)resetPeptestHack;

- (void)logTitle:(nonnull NSString *)title entity:(nonnull NSString *)entity
     description:(nullable NSString *)description comment:(nullable NSString *)comment;

- (nonnull NSString *)getLog;

@end
